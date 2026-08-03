/*
    File: fn_setState.sqf
    Description: Sets authoritative round state.
    Execution: Server
*/

params ["_newState"];

if (!isServer) exitWith {};

["BN_KOTH_roundState", _newState] call bn_koth_fnc_publicState;
[format ["Round state -> %1", _newState]] call bn_koth_fnc_log;
