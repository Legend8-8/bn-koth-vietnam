/*
    File: fn_publicState.sqf
    Description: Sets and broadcasts mission namespace state.
    Execution: Server
*/

params ["_key", "_value"];

if (!isServer) exitWith {};

missionNamespace setVariable [_key, _value, true];
[format ["Published state %1", _key]] call bn_koth_fnc_log;
