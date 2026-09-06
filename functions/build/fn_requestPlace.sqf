/*
    File: fn_requestPlace.sqf
    Author: tylervip
    Description: Sends the client placement request to the authoritative server.
    Execution: Client
    Parameters:
        0: Classname <STRING>
        1: Position ATL <ARRAY>
        2: Direction <NUMBER>
        3: Catalog key <STRING>
    Returns: None
    Public: Yes
*/

params [
    ["_className", "", [""]],
    ["_position", [0,0,0], [[]]],
    ["_direction", 0, [0]],
    ["_catalogKey", "", [""]]
];

private _clearPlacementState = {
    private _ghost = missionNamespace getVariable ["BN_KOTH_buildGhost", objNull];
    if !(isNull _ghost) then {
        deleteVehicle _ghost;
    };

    missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
    missionNamespace setVariable ["BN_KOTH_buildGhost", objNull];
    missionNamespace setVariable ["BN_KOTH_buildPlacementClass", ""];
    missionNamespace setVariable ["BN_KOTH_buildPlacementKey", ""];
    missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", 0];
};

if (_className isEqualTo "") exitWith {
    diag_log "[BN_KOTH Build] fn_requestPlace rejected empty classname.";
    [] call _clearPlacementState;
};
if (_catalogKey isEqualTo "") exitWith {
    diag_log "[BN_KOTH Build] fn_requestPlace rejected empty catalog key.";
    hint "No valid build item selected.";
    [] call _clearPlacementState;
};
if !(isClass (missionConfigFile >> "CfgBnKothBuild" >> "Objects" >> _catalogKey)) exitWith {
    diag_log format ["[BN_KOTH Build] fn_requestPlace rejected invalid catalog key: %1", _catalogKey];
    hint "Selected build item is not configured.";
    [] call _clearPlacementState;
};
if !(call bn_koth_fnc_build_canBuild) exitWith {
    [] call _clearPlacementState;
};

private _cooldown = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placeCooldown");
if (_cooldown > 0) then {
    private _lastRequestAt = missionNamespace getVariable ["BN_KOTH_buildLastRequestAt", -9999];
    private _now = diag_tickTime;
    if ((_now - _lastRequestAt) < _cooldown) exitWith {
        hint "Please wait a moment before placing another object.";
        [] call _clearPlacementState;
    };
    missionNamespace setVariable ["BN_KOTH_buildLastRequestAt", _now];
};

diag_log format ["[BN_KOTH Build] fn_requestPlace sending key=%1 class=%2 pos=%3 dir=%4", _catalogKey, _className, _position, _direction];
[_position, _direction, _catalogKey, _className] remoteExecCall ["bn_koth_fnc_build_serverPlace", 2];
[] call _clearPlacementState;
