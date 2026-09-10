/*
    File: fn_applyBackpack.sqf
    Author: Legend
    Description: Covers insertion preparation, applies the temporary parachute backpack, and performs verified backpack-only restoration where the player is local.
    Execution: Owning client (server RemoteExec only)
    Parameters:
        0: PREPARE, RESTORE, or CLEAR <STRING>
        1: Insertion session ID <STRING>
        2: Original Unit Loadout backpack slot for RESTORE <ARRAY>
        3: Server-authoritative player representation <OBJECT>
    Returns: None
    Public: Yes
*/

params [
    ["_mode", "", [""]],
    ["_sessionId", "", [""]],
    ["_backpackSlot", [], [[]]],
    ["_expectedUnit", objNull, [objNull]]
];

if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2} || {!canSuspend}) exitWith {};
if (isNull player || {!local player} || {_sessionId isEqualTo ""}) exitWith {};

private _transitionLayer = "BN_KOTH_AirInsertionTransition" call BIS_fnc_rscLayer;
private _showTransition = {_transitionLayer cutText ["", "BLACK OUT", 0.2]};
private _hideTransition = {_transitionLayer cutText ["", "BLACK IN", 0.45]};
if ((toUpper _mode) in ["PREPARE", "RESTORE"] && {isNull _expectedUnit || {!(_expectedUnit isEqualTo player)}}) exitWith {
    [format ["Air insertion backpack command rejected for an invalid player representation. mode=%1 session=%2", toUpper _mode, _sessionId], "WARNING"] call bn_koth_fnc_common_log;
    call _hideTransition;
};

private _waitForLoadoutChange = {
    private _deadline = diag_tickTime + 10;
    waitUntil {
        sleep 0.1;
        !isSwitchingWeapon player || {diag_tickTime >= _deadline}
    };
    !isSwitchingWeapon player
};

private _clearBinding = {
    private _binding = uiNamespace getVariable ["BN_KOTH_airInsertionBackpackBinding", [objNull, -1, ""]];
    _binding params ["_boundUnit", "_getOutEhId", "_boundSessionId"];
    if (!isNull _boundUnit && {_getOutEhId >= 0}) then {
        _boundUnit removeEventHandler ["GetOutMan", _getOutEhId];
        _boundUnit setVariable ["BN_KOTH_airInsertionLandingWatch", "", false];
    };
    uiNamespace setVariable ["BN_KOTH_airInsertionBackpackBinding", [objNull, -1, ""]];
};

switch (toUpper _mode) do {
    case "PREPARE": {
        call _showTransition;
        if !(call _waitForLoadoutChange) exitWith {
            ["Air insertion parachute preparation failed while the player was switching weapons.", "WARNING"] call bn_koth_fnc_common_log;
            call _hideTransition;
        };
        if (!alive player) exitWith {call _hideTransition};
        private _parachuteClass = getText (missionConfigFile >> "CfgBnKothAirInsertion" >> "parachuteBackpackClass");
        if (_parachuteClass isEqualTo "") exitWith {
            ["Air insertion parachute preparation failed because the configured backpack class is empty.", "WARNING"] call bn_koth_fnc_common_log;
            call _hideTransition;
        };
        call _clearBinding;
        private _getOutEhId = player addEventHandler ["GetOutMan", {
            params ["_unit", "_role", "_vehicle"];
            if (!local _unit || {!(_vehicle isKindOf "ParachuteBase")}) exitWith {};

            private _binding = uiNamespace getVariable ["BN_KOTH_airInsertionBackpackBinding", [objNull, -1, ""]];
            _binding params ["_boundUnit", "_getOutEhId", "_sessionId"];
            if (!(_boundUnit isEqualTo _unit) || {_sessionId isEqualTo ""}) exitWith {};
            if ((_unit getVariable ["BN_KOTH_airInsertionLandingWatch", ""]) isEqualTo _sessionId) exitWith {};
            _unit setVariable ["BN_KOTH_airInsertionLandingWatch", _sessionId, false];

            [_unit, _sessionId] spawn {
                params ["_unit", "_sessionId"];
                private _deadline = diag_tickTime + 15;
                waitUntil {
                    uiSleep 0.25;
                    !alive _unit
                        || {(objectParent _unit) isEqualTo objNull && {isTouchingGround _unit || {((getPosATL _unit) select 2) < 1.5}}}
                        || {diag_tickTime >= _deadline}
                };
                if (alive _unit && {(objectParent _unit) isEqualTo objNull} && {isTouchingGround _unit || {((getPosATL _unit) select 2) < 1.5}}) then {
                    ["LANDED", _sessionId] remoteExec ["bn_koth_fnc_airInsertion_backpackRequest", 2];
                };
            };
        }];
        uiNamespace setVariable ["BN_KOTH_airInsertionBackpackBinding", [player, _getOutEhId, _sessionId]];
        player setUnitLoadout [[nil, nil, nil, nil, nil, [_parachuteClass, []], nil, nil, nil, nil], false];
        ["PREPARED", _sessionId] remoteExec ["bn_koth_fnc_airInsertion_backpackRequest", 2];
    };
    case "RESTORE": {
        private _canApply = call _waitForLoadoutChange;
        if (!_canApply || {!alive player}) exitWith {
            [format ["Air insertion backpack RESTORE CLIENT FAILED session=%1 reason=%2 current=%3", _sessionId, if (!_canApply) then {"WEAPON_SWITCH_TIMEOUT"} else {"PLAYER_DEAD"}, backpack player], "WARNING"] call bn_koth_fnc_common_log;
            ["RESTORED", _sessionId, false] remoteExec ["bn_koth_fnc_airInsertion_backpackRequest", 2];
            call _hideTransition;
        };

        private _updatedLoadout = getUnitLoadout player;
        _updatedLoadout set [5, +_backpackSlot];
        player setUnitLoadout [_updatedLoadout, false];
        private _observedSlot = (getUnitLoadout player) param [5, []];
        private _matches = _observedSlot isEqualTo _backpackSlot;
        if (!_matches) then {
            [format ["Air insertion backpack restore mismatch on owner. expected=%1 actual=%2 session=%3", _backpackSlot param [0, ""], backpack player, _sessionId], "WARNING"] call bn_koth_fnc_common_log;
        };
        if (_matches) then {call _clearBinding};
        ["RESTORED", _sessionId, _matches] remoteExec ["bn_koth_fnc_airInsertion_backpackRequest", 2];
        if (_matches) then {["ORIGINAL BACKPACK RESTORED."] call bn_koth_fnc_ui_notify};
        call _hideTransition;
    };
    case "CLEAR": {
        call _clearBinding;
        call _hideTransition;
    };
};
