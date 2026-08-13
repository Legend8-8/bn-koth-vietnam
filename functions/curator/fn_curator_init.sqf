/*
    File: fn_curator_init.sqf
    Author: tylervip
    Edited: Legend
    Description: Assigns Zeus curator access to whitelisted players.
    Execution: Server
    Parameters:
        0: Player unit <OBJECT>
        1: Known player UID <STRING> (optional)
    Returns:
        None
    Public: Yes
*/

params ["_player", ["_knownUID", "", [""]]];

if (!isServer) exitWith {};

if (isNull _player) exitWith {
    ["Curator init rejected: player object is null.", "WARN"] call bn_koth_fnc_common_log;
};

private _curatorUIDs = [
    "76561198074552443", // Tyler
    "76561198976258425"  // Legend
];

private _playerUID = if (_knownUID isEqualTo "") then {
    getPlayerUID _player
} else {
    _knownUID
};
if (_playerUID isEqualTo "") exitWith {
    [format ["Curator init rejected: could not resolve UID for %1", _player], "WARN"] call bn_koth_fnc_common_log;
};

if (!(_playerUID in _curatorUIDs)) exitWith {
    [format ["Curator init skipped for non-whitelisted player %1 (%2).", name _player, _playerUID], "INFO"] call bn_koth_fnc_common_log;
};

[_player, _playerUID] spawn {
    params ["_thePlayer", "_playerUID"];

    private _curVarName = format ["BN_KOTH_curator_%1", _playerUID];
    private _myCurObject = missionNamespace getVariable [_curVarName, objNull];

    if (isNull _myCurObject) then {
        if (isNil "BN_KOTH_Curator_Group") then {
            BN_KOTH_Curator_Group = createGroup sideLogic;
        };

        _myCurObject = BN_KOTH_Curator_Group createUnit ["ModuleCurator_F", [0, 0, 0], [], 0.5, "NONE"];
        _myCurObject setVariable ["showNotification", false];

        private _cfg = configFile >> "CfgPatches";
        private _newAddons = [];
        for "_i" from 0 to (count _cfg - 1) do {
            _newAddons pushBack (configName (_cfg select _i));
        };

        if ((count _newAddons) > 0) then {
            _myCurObject addCuratorAddons _newAddons;
        };

        missionNamespace setVariable [_curVarName, _myCurObject, true];
        [format ["Created curator object %1 for %2 (%3)", _myCurObject, name _thePlayer, _playerUID], "INFO"] call bn_koth_fnc_common_log;
    };

    unassignCurator _myCurObject;

    private _timeout = diag_tickTime + 5;
    waitUntil {
        sleep 0.1;
        isNull (getAssignedCuratorUnit _myCurObject) || diag_tickTime > _timeout
    };

    _thePlayer assignCurator _myCurObject;

    _timeout = diag_tickTime + 10;
    waitUntil {
        sleep 0.3;
        getAssignedCuratorUnit _myCurObject == _thePlayer || diag_tickTime > _timeout
    };

    if (getAssignedCuratorUnit _myCurObject == _thePlayer) then {
        _myCurObject setVariable ["owner", _playerUID];
        [format ["SUCCESS: %1 (%2) assigned to %3", name _thePlayer, _playerUID, _myCurObject], "INFO"] call bn_koth_fnc_common_log;
    } else {
        [format ["ERROR: Failed to assign %1 (%2) to %3. Current assigned unit: %4", name _thePlayer, _playerUID, _myCurObject, getAssignedCuratorUnit _myCurObject], "ERROR"] call bn_koth_fnc_common_log;
    };
};
