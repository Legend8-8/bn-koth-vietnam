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
    [] call _clearPlacementState;
};
if !(call bn_koth_fnc_build_canBuild) exitWith {
    [] call _clearPlacementState;
};

private _uid = getPlayerUID player;
[_position, _direction, _catalogKey, _className, _uid] remoteExecCall ["bn_koth_fnc_build_serverPlace", 2];
[] call _clearPlacementState;
