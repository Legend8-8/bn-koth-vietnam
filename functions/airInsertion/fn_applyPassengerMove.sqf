/*
    File: fn_applyPassengerMove.sqf
    Author: Legend
    Description: Applies one server-authorized insertion seat, return, or native Eject where the player unit is local.
    Execution: Owning client (server RemoteExec only)
    Parameters:
        0: BOARD, RETURN, or EJECT <STRING>
        1: Insertion aircraft <OBJECT>
        2: Server-selected seat descriptor or return position ASL <ARRAY>
        3: Session ID <STRING>
    Returns: None
    Public: Yes
*/

params [
    ["_mode", "", [""]],
    ["_aircraft", objNull, [objNull]],
    ["_moveData", [], [[]]],
    ["_sessionId", "", [""]]
];

if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
if (isNull player || {!local player} || {_sessionId isEqualTo ""}) exitWith {};

switch (toUpper _mode) do {
    case "BOARD": {
        if (!isNull _aircraft && {alive player} && {(count _moveData) >= 3}) then {
            _moveData params ["_role", "_cargoIndex", "_turretPath"];
            switch (toLower _role) do {
                case "driver": {player moveInDriver _aircraft};
                case "turret": {player moveInTurret [_aircraft, _turretPath]};
                case "commander": {player moveInCommander _aircraft};
                case "gunner": {player moveInGunner _aircraft};
                case "cargo": {
                    player assignAsCargoIndex [_aircraft, _cargoIndex];
                    player moveInCargo [_aircraft, _cargoIndex];
                };
            };
        };
    };
    case "RETURN": {
        unassignVehicle player;
        moveOut player;
        if ((count _moveData) >= 3) then {player setPosASL _moveData};
    };
    case "EJECT": {
        if (!isNull _aircraft && {alive player} && {(vehicle player) isEqualTo _aircraft}) then {
            player action ["Eject", _aircraft];
        };
    };
};
