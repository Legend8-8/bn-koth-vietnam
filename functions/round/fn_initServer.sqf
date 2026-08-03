/*
    File: fn_initServer.sqf
    Description: Initializes authoritative round and score state.
    Execution: Server
*/

if (!isServer) exitWith {};

missionNamespace setVariable ["BN_KOTH_teamScores", createHashMapFromArray [[west, 0], [east, 0]], true];
missionNamespace setVariable ["BN_KOTH_winningSide", sideUnknown, true];

["BN_KOTH_roundState", "WAITING"] call bn_koth_fnc_publicState;
["BN_KOTH_zoneState", "NEUTRAL"] call bn_koth_fnc_publicState;
["BN_KOTH_zoneController", sideUnknown] call bn_koth_fnc_publicState;
