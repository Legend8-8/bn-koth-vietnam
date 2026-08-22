/*
    File: fn_updateLeader.sqf
    Author: Legend
    Description: Updates one Live Leaders card when a strictly higher round value is reached.
        Equal values never displace the current leader, implementing the agreed
        "first to reach the value keeps the card" rule.
    Execution: Server
    Parameters:
        0: Leader key <STRING>
        1: Player UID <STRING>
        2: Player display name <STRING>
        3: New value <NUMBER>
    Returns:
        True when the leader changed <BOOL>
    Public: No
*/

params [
    ["_leaderKey", "", [""]],
    ["_uid", "", [""]],
    ["_name", "", [""]],
    ["_value", 0, [0]]
];

if (!isServer) exitWith {false};
if !(_leaderKey in ["mostDeadly", "objective", "bestStreak"]) exitWith {false};
if (_uid isEqualTo "") exitWith {false};
if (_value <= 0) exitWith {false};

private _leaders = missionNamespace getVariable ["BN_KOTH_liveLeaders", createHashMap];
if !(_leaders isEqualType createHashMap) then {_leaders = createHashMap};

private _current = _leaders getOrDefault [_leaderKey, createHashMap];
if !(_current isEqualType createHashMap) then {_current = createHashMap};

private _currentValue = _current getOrDefault ["value", 0];

// Tie rule: existing leader keeps the card. Only a strict improvement replaces them.
if (_value <= _currentValue) exitWith {false};

private _next = createHashMapFromArray [
    ["uid", _uid],
    ["name", _name],
    ["value", _value]
];

// Publish a fresh top-level hashmap. Mutating the missionNamespace-owned map in
// place makes common_publicState compare the value against itself and skip the
// broadcast as "unchanged".
private _nextLeaders = createHashMap;
{
    _nextLeaders set [_x, _leaders get _x];
} forEach (keys _leaders);

_nextLeaders set [_leaderKey, _next];
["BN_KOTH_liveLeaders", _nextLeaders] call bn_koth_fnc_common_publicState;

[format [
    "Live leader changed: category=%1 uid=%2 name=%3 value=%4",
    _leaderKey, _uid, _name, _value
], "INFO"] call bn_koth_fnc_common_log;

true
