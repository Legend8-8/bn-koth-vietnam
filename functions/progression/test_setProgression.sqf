/*
    File: test_setProgression.sqf
    Author: Legend
    Description: Standalone developer/debug script for hosted testing. Sets
        one registered player's XP (deriving level from the existing curve),
        cash, and optionally one canonical weapon's mastery kill count,
        through the existing authoritative progression state and side-effect
        APIs (persistence dirty-marking, targeted client publish). This file
        is not registered as a runtime function and grants no client-callable
        endpoint; paste it into the SERVER-side hosted/dedicated debug
        console.
    Execution: Server debug console only
    Returns: None (prints RPT + systemChat)
*/

// ---- Configure before running ----
_targetPlayer = player;
_targetLevel = 100;
_targetCash = 500000;

// Optional canonical weapon mastery test. Leave classname empty to skip.
_debugWeaponClass = "";
_debugMasteryKills = -1;
// ----------------------------------

if (!isServer) exitWith {["Rental/progression debug script must run on the server."] call bn_koth_fnc_common_log};
if (isNull _targetPlayer) exitWith {["Debug progression target player is null."] call bn_koth_fnc_common_log};

private _uid = getPlayerUID _targetPlayer;
if (_uid isEqualTo "") exitWith {["Debug progression target player has no resolvable UID."] call bn_koth_fnc_common_log};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !((_records isEqualType createHashMap) && {(_records getOrDefault [_uid, createHashMap]) isEqualType createHashMap}) exitWith {
    [format ["Debug progression target UID=%1 is not registered in BN_KOTH_playerRecords.", _uid]] call bn_koth_fnc_common_log
};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_byUid isEqualType createHashMap) exitWith {["BN_KOTH_playerProgression is unavailable."] call bn_koth_fnc_common_log};
private _progression = _byUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {
    [format ["Debug progression target UID=%1 is not registered in BN_KOTH_playerProgression.", _uid]] call bn_koth_fnc_common_log
};

// Target level -> cumulative XP threshold, using the existing curve only.
private _targetXp = [_targetLevel] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;
private _currentXp = _progression getOrDefault ["xp", 0];
if (_targetXp > _currentXp) then {
    [_uid, _targetXp - _currentXp, "debug_set_level"] call bn_koth_fnc_progression_xp_addXp;
} else {
    if (_targetXp < _currentXp) then {
        // fn_addXp only accepts positive deltas; lowering XP for debug reuses the
        // same field/derivation/dirty/publish steps addXp performs internally.
        _progression set ["uid", _uid];
        _progression set ["xp", _targetXp];
        _progression set ["level", [_targetXp] call bn_koth_fnc_progression_xp_getLevel];
        _byUid set [_uid, _progression];
        missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
        [_uid, "xp"] call bn_koth_fnc_persistence_markDirty;
        [_uid, "xp", _targetXp - _currentXp, "debug_set_level"] call bn_koth_fnc_progression_publishUpdate;
    };
};

// Cash: reuse fn_addCash for increases; reuse the same mutation/dirty/publish
// steps directly for decreases, since fn_addCash also only accepts positives.
private _byUidCash = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _progressionCash = _byUidCash getOrDefault [_uid, createHashMap];
private _currentCash = _progressionCash getOrDefault ["cash", 0];
if (_targetCash > _currentCash) then {
    [_uid, _targetCash - _currentCash, "debug_set_cash"] call bn_koth_fnc_progression_cash_addCash;
} else {
    if (_targetCash < _currentCash) then {
        _progressionCash set ["cash", _targetCash max 0];
        _byUidCash set [_uid, _progressionCash];
        missionNamespace setVariable ["BN_KOTH_playerProgression", _byUidCash];
        [_uid, "cash"] call bn_koth_fnc_persistence_markDirty;
        [_uid, "cash", _targetCash - _currentCash, "debug_set_cash"] call bn_koth_fnc_progression_publishUpdate;
    };
};

// Optional canonical weapon mastery kill-count override.
if !(_debugWeaponClass isEqualTo "" || {_debugMasteryKills < 0}) then {
    private _metadata = [_debugWeaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
    if !(_metadata getOrDefault ["success", false]) then {
        [format ["Debug mastery weapon %1 is not a configured canonical weapon.", _debugWeaponClass]] call bn_koth_fnc_common_log;
    } else {
        private _canonical = _metadata getOrDefault ["canonicalClass", ""];
        private _byUidMastery = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
        private _progressionMastery = _byUidMastery getOrDefault [_uid, createHashMap];
        private _weaponKills = _progressionMastery getOrDefault ["weaponKills", createHashMap];
        if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};
        _weaponKills set [_canonical, _debugMasteryKills max 0];
        _progressionMastery set ["uid", _uid];
        _progressionMastery set ["weaponKills", _weaponKills];
        _byUidMastery set [_uid, _progressionMastery];
        missionNamespace setVariable ["BN_KOTH_playerProgression", _byUidMastery];
        [_uid, "mastery"] call bn_koth_fnc_persistence_markDirty;
        [_uid, "mastery", 0, "debug_set_mastery"] call bn_koth_fnc_progression_publishUpdate;
    };
};

private _final = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) getOrDefault [_uid, createHashMap];
private _finalXp = _final getOrDefault ["xp", 0];
private _finalLevel = [_finalXp] call bn_koth_fnc_progression_xp_getLevel;
private _finalCash = _final getOrDefault ["cash", 0];
private _report = format [
    "Debug progression set: UID=%1 xp=%2 level=%3 cash=%4",
    _uid, _finalXp, _finalLevel, _finalCash
];
[_report] call bn_koth_fnc_common_log;
systemChat _report;
