/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes the server-owned tactical air-insertion session state.
    Execution: Server
    Parameters: None
    Returns: True when initialized <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

missionNamespace setVariable ["BN_KOTH_airInsertionSessions", createHashMap];
missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap];
missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
missionNamespace setVariable ["BN_KOTH_airInsertionNextId", 1];

private _cfg = missionConfigFile >> "CfgBnKothAirInsertion";
private _enabled = isClass _cfg && {(getNumber (_cfg >> "enabled")) > 0};
private _aircraftClass = if (isClass _cfg) then {getText (_cfg >> "aircraftClass")} else {""};
private _parachuteClass = if (isClass _cfg) then {getText (_cfg >> "parachuteBackpackClass")} else {""};
if (_enabled && {!isClass (configFile >> "CfgVehicles" >> _aircraftClass)}) then {
    _enabled = false;
    [format ["Air insertion disabled: configured aircraft class '%1' is unavailable.", _aircraftClass], "ERROR"] call bn_koth_fnc_common_log;
};
if (_enabled && {!isClass (configFile >> "CfgVehicles" >> _parachuteClass)}) then {
    _enabled = false;
    [format ["Air insertion disabled: configured parachute backpack class '%1' is unavailable.", _parachuteClass], "ERROR"] call bn_koth_fnc_common_log;
};

missionNamespace setVariable ["BN_KOTH_airInsertionEnabled", _enabled];
[format ["Air insertion initialized: enabled=%1 aircraft=%2", _enabled, _aircraftClass]] call bn_koth_fnc_common_log;
true
