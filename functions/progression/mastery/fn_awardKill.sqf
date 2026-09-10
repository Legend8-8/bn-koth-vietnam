/*
    File: fn_awardKill.sqf
    Author: Legend
    Description: Awards one canonical weapon mastery kill from an already
        validated PvP kill record containing fail-closed server attribution.
    Execution: Server
    Parameters:
        0: Canonical combat kill record <HASHMAP>
    Returns: Structured mastery result <HASHMAP>
    Public: No
*/

params [["_killRecord", createHashMap, [createHashMap]]];

private _reject = {
    params ["_code"];
    createHashMapFromArray [["awarded", false], ["code", _code]]
};

if (!isServer) exitWith {["NOT_SERVER"] call _reject};
if !(_killRecord getOrDefault ["roundActive", false]) exitWith {["ROUND_INACTIVE"] call _reject};
if !(_killRecord getOrDefault ["validPvp", false]) exitWith {["INVALID_PVP_KILL"] call _reject};
if (_killRecord getOrDefault ["suicide", false]) exitWith {["SUICIDE"] call _reject};
if (_killRecord getOrDefault ["teamkill", false]) exitWith {["TEAMKILL"] call _reject};

private _uid = _killRecord getOrDefault ["killerUid", ""];
private _victimUid = _killRecord getOrDefault ["victimUid", ""];
if (_uid isEqualTo "" || {_victimUid isEqualTo ""}) exitWith {["INVALID_KILL_IDENTITY"] call _reject};

private _attribution = _killRecord getOrDefault ["weaponAttribution", createHashMap];
if !(_attribution isEqualType createHashMap) exitWith {["INVALID_ATTRIBUTION"] call _reject};
if !((_attribution getOrDefault ["result", ""]) isEqualTo "ATTRIBUTED") exitWith {["ATTRIBUTION_NOT_UNIQUE"] call _reject};
private _canonical = _attribution getOrDefault ["canonicalCandidates", []];
if !(_canonical isEqualType [] && {(count _canonical) isEqualTo 1}) exitWith {["ATTRIBUTION_NOT_UNIQUE"] call _reject};
if !((_canonical select 0) isEqualType "") exitWith {["INVALID_CANONICAL_WEAPON"] call _reject};
private _weapon = toLower (_canonical select 0);
if (_weapon isEqualTo "") exitWith {["INVALID_CANONICAL_WEAPON"] call _reject};

private _projectiles = _attribution getOrDefault ["projectiles", []];
if !(_projectiles isEqualType []) then {_projectiles = []};
_projectiles = _projectiles select {_x isEqualType "" && {!(_x isEqualTo "")}};
_projectiles sort true;
if ((count _projectiles) isEqualTo 0) exitWith {["ATTRIBUTION_EVENT_ID_MISSING"] call _reject};
private _awardId = format ["%1|%2|%3", _uid, _victimUid, _projectiles joinString ","];

private _now = diag_tickTime;
private _processed = missionNamespace getVariable ["BN_KOTH_weaponMasteryProcessedKills", createHashMap];
if !(_processed isEqualType createHashMap) then {_processed = createHashMap};
{
    if ((_now - (_processed getOrDefault [_x, _now])) > 10) then {_processed deleteAt _x};
} forEach (keys _processed);
if !(isNil {_processed get _awardId}) exitWith {
    missionNamespace setVariable ["BN_KOTH_weaponMasteryProcessedKills", _processed];
    ["DUPLICATE_KILL_EVENT"] call _reject
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = if (_records isEqualType createHashMap) then {_records getOrDefault [_uid, createHashMap]} else {createHashMap};
if !(_record isEqualType createHashMap) exitWith {["PLAYER_NOT_REGISTERED"] call _reject};
private _eligible = (_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"
    && {_record getOrDefault ["deployed", false]};
if (!_eligible) exitWith {["PLAYER_NOT_DEPLOYED"] call _reject};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_byUid isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE"] call _reject};
private _progression = _byUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};
private _previous = (_weaponKills getOrDefault [_weapon, 0]) max 0;
private _next = _previous + 1;

_weaponKills set [_weapon, _next];
_progression set ["uid", _uid];
_progression set ["weaponKills", _weaponKills];
_byUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
[_uid, "mastery"] call bn_koth_fnc_persistence_markDirty;
_processed set [_awardId, _now];
missionNamespace setVariable ["BN_KOTH_weaponMasteryProcessedKills", _processed];

private _metadata = [_weapon] call bn_koth_fnc_loadouts_getWeaponMetadata;
private _required = (_metadata getOrDefault ["masteryKillsRequired", 0]) max 0;
private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
private _displayName = if (isClass _weaponCfg) then {getText (_weaponCfg >> "displayName")} else {""};
if (_displayName isEqualTo "") then {_displayName = toUpper _weapon};
private _masteryComplete = _required > 0 && {_next >= _required};
private _reason = if (_required > 0 && {_next < _required}) then {
    format ["%1  %2 / %3 KILLS", _displayName, _next, _required]
} else {
    if (_required > 0 && {_previous < _required} && {_masteryComplete}) then {
        private _entitlement = [_uid, _weapon] call bn_koth_fnc_progression_evaluateWeaponEntitlement;
        private _availability = switch (_entitlement getOrDefault ["code", ""]) do {
            case "REQUIRES_ACQUISITION": {
                private _options = [];
                if (_entitlement getOrDefault ["canPurchase", false]) then {_options pushBack "PURCHASE"};
                if (_entitlement getOrDefault ["canRent", false]) then {_options pushBack "RENTAL"};
                if ((count _options) > 0) then {format [" — %1 ELIGIBLE", _options joinString " / "]} else {""}
            };
            case "LOCKED_LEVEL": {format [" — LEVEL %1 STILL REQUIRED", _entitlement getOrDefault ["minLevel", 1]]};
            case "LOCKED_PERK": {" — PERK STILL REQUIRED"};
            default {""};
        };
        format ["MASTERY COMPLETE: %1  %2 / %3%4", _displayName, _next, _required, _availability]
    } else {
        format ["%1  %2 MASTERY KILLS", _displayName, _next]
    }
};
[_uid, "mastery", 1, _reason] call bn_koth_fnc_progression_publishUpdate;
[format ["Weapon mastery award UID=%1 weapon=%2 previous=%3 new=%4 attribution=ATTRIBUTED victim=%5", _uid, _weapon, _previous, _next, _victimUid]] call bn_koth_fnc_common_log;

createHashMapFromArray [
    ["awarded", true], ["code", "MASTERY_AWARDED"], ["uid", _uid],
    ["canonicalClass", _weapon], ["displayName", _displayName],
    ["previousKills", _previous], ["weaponKills", _next],
    ["masteryKillsRequired", _required], ["masteryComplete", _masteryComplete],
    ["awardId", _awardId]
]
