/*
    File: fn_recordKill.sqf
    Author: Legend
    Description: Consumes the canonical combat kill record to maintain round kills,
        deaths, current streak and best streak. Combat remains the sole authority
        for kill identity and PvP validity.
    Execution: Server
    Parameters:
        0: Canonical combat kill record <HASHMAP>
    Returns:
        True when the record was processed <BOOL>
    Public: No
*/

params [["_killRecord", createHashMap, [createHashMap]]];

if (!isServer) exitWith {false};
if ((count _killRecord) == 0) exitWith {false};
if !(_killRecord getOrDefault ["roundActive", false]) exitWith {false};

private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
if !(_stats isEqualType createHashMap) then {_stats = createHashMap};

private _victimUid = _killRecord getOrDefault ["victimUid", ""];
private _victimName = _killRecord getOrDefault ["victimName", ""];

if !(_victimUid isEqualTo "") then {
    private _victimStats = _stats getOrDefault [_victimUid, createHashMap];
    if !(_victimStats isEqualType createHashMap) then {_victimStats = createHashMap};

    _victimStats set ["name", _victimName];
    _victimStats set ["deaths", (_victimStats getOrDefault ["deaths", 0]) + 1];
    _victimStats set ["currentStreak", 0];
    _stats set [_victimUid, _victimStats];
};

private _validPvp = _killRecord getOrDefault ["validPvp", false];
private _suicide = _killRecord getOrDefault ["suicide", false];
private _teamkill = _killRecord getOrDefault ["teamkill", false];

if (_validPvp && {!_suicide} && {!_teamkill}) then {
    private _killerUid = _killRecord getOrDefault ["killerUid", ""];
    private _killerName = _killRecord getOrDefault ["killerName", ""];

    if !(_killerUid isEqualTo "") then {
        private _killerStats = _stats getOrDefault [_killerUid, createHashMap];
        if !(_killerStats isEqualType createHashMap) then {_killerStats = createHashMap};

        private _kills = (_killerStats getOrDefault ["kills", 0]) + 1;
        private _currentStreak = (_killerStats getOrDefault ["currentStreak", 0]) + 1;
        private _bestStreak = (_killerStats getOrDefault ["bestStreak", 0]) max _currentStreak;

        _killerStats set ["name", _killerName];
        _killerStats set ["kills", _kills];
        _killerStats set ["currentStreak", _currentStreak];
        _killerStats set ["bestStreak", _bestStreak];
        _stats set [_killerUid, _killerStats];

        ["mostDeadly", _killerUid, _killerName, _kills] call bn_koth_fnc_roundStats_updateLeader;
        ["bestStreak", _killerUid, _killerName, _bestStreak] call bn_koth_fnc_roundStats_updateLeader;
    };
};

missionNamespace setVariable ["BN_KOTH_roundStats", _stats];
true
