/*
    File: fn_publicState.sqf
    Author: tylervip
    Description: Sets and broadcasts mission namespace state when changed.
    Execution: Server
    Parameters:
        0: State key <STRING>
        1: State value <ANY>
        2: Force publish even if unchanged <BOOL> (default: false)
    Returns:
        True when published, false when unchanged and skipped <BOOL>
    Public: Yes
*/

params ["_key", "_value", ["_forcePublish", false, [true]]];

if (!isServer) exitWith {};

private _sentinel = createHashMap;
private _existing = missionNamespace getVariable [_key, _sentinel];

if (!_forcePublish && {!(_existing isEqualType _sentinel && {_existing isEqualTo _sentinel})} && {_existing isEqualTo _value}) exitWith {
    false
};

missionNamespace setVariable [_key, _value, true];

[format ["Published state %1", _key]] call bn_koth_fnc_common_log;
true
