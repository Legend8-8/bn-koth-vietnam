/*
    File: fn_initServer.sqf
    Author: tylervip
    Description: Creates the server-owned enemy spotting state and starts the expiry loop.
    Execution: Server
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

private _existingMap = missionNamespace getVariable ["BN_KOTH_enemySpots", createHashMap];
if !(_existingMap isEqualType createHashMap) then {
    _existingMap = createHashMap;
};
missionNamespace setVariable ["BN_KOTH_enemySpots", _existingMap];

private _existingLoop = missionNamespace getVariable ["BN_KOTH_enemySpottingExpireLoop", scriptNull];
if !(isNull _existingLoop) then {
    terminate _existingLoop;
};

private _expireLoop = [] spawn {
    while {true} do {
        sleep 1;
        [] call bn_koth_fnc_enemySpotting_serverExpireMarks;
    };
};
missionNamespace setVariable ["BN_KOTH_enemySpottingExpireLoop", _expireLoop];

[] call bn_koth_fnc_enemySpotting_serverExpireMarks;
