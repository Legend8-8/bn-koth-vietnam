/*
    File: fn_selectControlledUnit.sqf
    Author: Legend
    Edited: Mongo
    Description: Performs local player-unit handoff to a server-selected representation,
        initializes the newly selected unit's S.O.G. Advanced Revive lifecycle, then
        reports the observed local outcome back to the server so the transfer contract
        can commit only on a confirmed handoff rather than inferred locality.
    Execution: Client
    Parameters:
        0: Target unit <OBJECT>
        1: Server-issued transfer token (optional) <STRING>
    Returns:
        True when switched or already on target, otherwise false <BOOL>
    Public: Yes
*/

params ["_targetUnit", ["_token", "", [""]]];

if (!hasInterface) exitWith {false};

private _reportAck = {
    params ["_targetUnit", "_token", "_confirmed"];
    if (_token isEqualTo "") exitWith {};
    [_token, _targetUnit, _confirmed] remoteExecCall ["bn_koth_fnc_teams_receiveTransferHandoffAck", 2];
};

private _initializeAdvancedRevive = {
    params ["_unit"];

    if (isNull _unit || {_unit getVariable ["BN_KOTH_advancedReviveCoreInitializedLocal", false]}) exitWith {};

    if (local _unit) exitWith {
        [_unit] call VN_fnc_revive_coreinit;
        _unit setVariable ["BN_KOTH_advancedReviveCoreInitializedLocal", true, false];
        diag_log format [
            "[BN_KOTH][INFO] Advanced Revive coreinit executed target=%1 deferred=false local=%2",
            typeOf _unit,
            local _unit
        ];
    };

    if (_unit getVariable ["BN_KOTH_advancedReviveCoreInitPendingLocal", false]) exitWith {};
    _unit setVariable ["BN_KOTH_advancedReviveCoreInitPendingLocal", true, false];
    diag_log format [
        "[BN_KOTH][INFO] Advanced Revive coreinit deferred target=%1 local=false",
        typeOf _unit
    ];

    [_unit] spawn {
        params ["_unit"];
        private _deadline = diag_tickTime + 5;

        waitUntil {
            uiSleep 0.05;
            isNull _unit
            || {player isNotEqualTo _unit}
            || {local _unit}
            || {diag_tickTime >= _deadline}
        };

        private _canInitialize = !isNull _unit
            && {player isEqualTo _unit}
            && {local _unit};
        if (_canInitialize && {!(_unit getVariable ["BN_KOTH_advancedReviveCoreInitializedLocal", false])}) then {
            [_unit] call VN_fnc_revive_coreinit;
            _unit setVariable ["BN_KOTH_advancedReviveCoreInitializedLocal", true, false];
            diag_log format [
                "[BN_KOTH][INFO] Advanced Revive coreinit executed target=%1 deferred=true local=%2",
                typeOf _unit,
                local _unit
            ];
        };

        if (!isNull _unit) then {
            _unit setVariable ["BN_KOTH_advancedReviveCoreInitPendingLocal", false, false];
        };

        if (!_canInitialize) then {
            diag_log format [
                "[BN_KOTH][WARN] Advanced Revive coreinit defer ended without initialization target=%1 playerMatches=%2 local=%3",
                if (isNull _unit) then {"<null>"} else {typeOf _unit},
                !isNull _unit && {player isEqualTo _unit},
                !isNull _unit && {local _unit}
            ];
        };
    };
};

if (isNull _targetUnit) exitWith {
    diag_log "[BN_KOTH][WARN] ui_selectControlledUnit rejected null target unit";
    [_targetUnit, _token, false] call _reportAck;
    false
};

if (player isEqualTo _targetUnit) exitWith {
    diag_log format [
        "[BN_KOTH][INFO] ui_selectControlledUnit result playerMatches=true localAtHandoff=%1 current=%2 target=%3",
        local _targetUnit,
        typeOf player,
        typeOf _targetUnit
    ];
    [_targetUnit] call _initializeAdvancedRevive;
    [] call bn_koth_fnc_respawn_initPlayerLocal;
    [] call bn_koth_fnc_loadouts_initPlayerLocal;
    [] call bn_koth_fnc_escMenu_initPlayerLocal;
    [_targetUnit, _token, true] call _reportAck;
    true
};

diag_log format [
    "[BN_KOTH][INFO] ui_selectControlledUnit switching from %1 to %2",
    typeOf player,
    typeOf _targetUnit
];

private _enteringLobby = (side group _targetUnit) isEqualTo civilian;
if (_enteringLobby) then {
    [true] call bn_koth_fnc_ui_updateLobbyBlackout;
};

[true] call bn_koth_fnc_respawn_updateDownedPresentation;
selectPlayer _targetUnit;

private _switched = player isEqualTo _targetUnit;
diag_log format [
    "[BN_KOTH][INFO] ui_selectControlledUnit result playerMatches=%1 localAtHandoff=%2 current=%3 target=%4",
    _switched,
    local _targetUnit,
    typeOf player,
    typeOf _targetUnit
];

if (_switched) then {
    [_targetUnit] call _initializeAdvancedRevive;

    [] call bn_koth_fnc_respawn_updateDownedPresentation;
    [] call bn_koth_fnc_respawn_initPlayerLocal;
    [] call bn_koth_fnc_loadouts_initPlayerLocal;
    [] call bn_koth_fnc_escMenu_initPlayerLocal;
    [_enteringLobby] call bn_koth_fnc_ui_updateLobbyBlackout;
    [] call bn_koth_fnc_ui_evaluateStateReadiness;
    [] call bn_koth_fnc_ui_updateLobbyRepresentationContainment;
} else {
    if (_enteringLobby) then {
        [] call bn_koth_fnc_ui_updateLobbyBlackout;
    };
};

[_targetUnit, _token, _switched] call _reportAck;

_switched
