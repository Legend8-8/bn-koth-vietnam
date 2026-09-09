/*
    File: fn_awardRevive.sqf
    Author: Legend
    Description: Validates and awards one revive recovery from a future trusted
        native S.O.G. completion record. This function intentionally has no
        production caller until native reviver attribution is proven.
    Execution: Server
    Parameters:
        0: Trusted native completion record <HASHMAP>
    Returns: Structured reward result <HASHMAP>
    Public: No
*/

params [["_completion", createHashMap, [createHashMap]]];

private _reject = {
    params ["_code"];
    createHashMapFromArray [["success", false], ["code", _code]]
};

if (!isServer) exitWith {["NOT_SERVER"] call _reject};
if ((count _completion) == 0) exitWith {["INVALID_COMPLETION"] call _reject};

// These facts may only be authored by the future server-owned native
// attribution boundary. This helper is not RemoteExec-exposed.
if !(_completion getOrDefault ["trustedNativeCompletion", false]) exitWith {["UNTRUSTED_COMPLETION"] call _reject};
if !(_completion getOrDefault ["wasIncapacitated", false]) exitWith {["CASUALTY_NOT_PREVIOUSLY_INCAPACITATED"] call _reject};
if !(_completion getOrDefault ["nativeRecoveryConfirmed", false]) exitWith {["RECOVERY_NOT_CONFIRMED"] call _reject};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {["ROUND_NOT_ACTIVE"] call _reject};

private _reviverUid = _completion getOrDefault ["reviverUid", ""];
private _casualty = _completion getOrDefault ["casualty", objNull];
private _cycleToken = _completion getOrDefault ["cycleToken", ""];
if (_reviverUid isEqualTo "" || {isNull _casualty} || {!(_cycleToken isEqualType "")} || {_cycleToken isEqualTo ""}) exitWith {["INVALID_COMPLETION_IDENTITY"] call _reject};
if !(_casualty isKindOf "Man" && {isPlayer _casualty} && {alive _casualty}) exitWith {["INVALID_CASUALTY"] call _reject};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {["PLAYER_RECORDS_UNAVAILABLE"] call _reject};

private _reviverRecord = _records getOrDefault [_reviverUid, createHashMap];
if !(_reviverRecord isEqualType createHashMap) exitWith {["REVIVER_NOT_REGISTERED"] call _reject};
private _reviver = _reviverRecord getOrDefault ["currentUnit", objNull];
private _reviverSide = _reviverRecord getOrDefault ["assignedSide", sideUnknown];
private _reviverOwner = _reviverRecord getOrDefault ["ownerId", -1];
private _reviverValid = !isNull _reviver
    && {_reviver isKindOf "Man"}
    && {isPlayer _reviver}
    && {alive _reviver}
    && {_reviverOwner > 0}
    && {(owner _reviver) isEqualTo _reviverOwner}
    && {(_reviverRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {_reviverRecord getOrDefault ["deployed", false]}
    && {[_reviverSide] call bn_koth_fnc_teams_validateSide}
    && {!([_reviver] call bn_koth_fnc_respawn_isIncapacitated)};
if (!_reviverValid) exitWith {["REVIVER_NOT_ELIGIBLE"] call _reject};

private _casualtyUid = [_casualty, _records] call bn_koth_fnc_common_resolvePlayerUid;
if (_casualtyUid isEqualTo "" || {_casualtyUid isEqualTo _reviverUid}) exitWith {["SELF_OR_UNKNOWN_CASUALTY"] call _reject};
private _casualtyRecord = _records getOrDefault [_casualtyUid, createHashMap];
if !(_casualtyRecord isEqualType createHashMap) exitWith {["CASUALTY_NOT_REGISTERED"] call _reject};
private _casualtySide = _casualtyRecord getOrDefault ["assignedSide", sideUnknown];
private _casualtyOwner = _casualtyRecord getOrDefault ["ownerId", -1];
private _casualtyValid = (_casualtyRecord getOrDefault ["currentUnit", objNull]) isEqualTo _casualty
    && {_casualtyOwner > 0}
    && {(owner _casualty) isEqualTo _casualtyOwner}
    && {(_casualtyRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {_casualtyRecord getOrDefault ["deployed", false]}
    && {[_casualtySide] call bn_koth_fnc_teams_validateSide}
    && {!([_casualty] call bn_koth_fnc_respawn_isIncapacitated)};
if (!_casualtyValid) exitWith {["CASUALTY_NOT_RECOVERED"] call _reject};
if !(_reviverSide isEqualTo _casualtySide) exitWith {["CROSS_TEAM_REVIVE"] call _reject};

// Tokens are minted once per native incapacitation/recovery cycle by the
// future trusted owner. Keeping them on the casualty representation bounds
// dedupe state to that representation's lifetime.
private _rewardedTokens = _casualty getVariable ["BN_KOTH_reviveRewardedCycleTokensServer", []];
if !(_rewardedTokens isEqualType []) then {_rewardedTokens = []};
if (_cycleToken in _rewardedTokens) exitWith {["DUPLICATE_RECOVERY"] call _reject};
_rewardedTokens pushBack _cycleToken;
_casualty setVariable ["BN_KOTH_reviveRewardedCycleTokensServer", _rewardedTokens, false];

private _xp = missionNamespace getVariable ["BN_KOTH_xpPerRevive", 25];
private _cash = missionNamespace getVariable ["BN_KOTH_cashPerRevive", 25];
private _xpResult = if (_xp > 0) then {[_reviverUid, _xp, "revive"] call bn_koth_fnc_progression_xp_addXp} else {createHashMap};
private _cashResult = if (_cash > 0) then {[_reviverUid, _cash, "revive"] call bn_koth_fnc_progression_cash_addCash} else {createHashMapFromArray [["success", true]]};
private _xpOk = _xp <= 0 || {_xpResult isEqualType createHashMap && {(count _xpResult) > 0}};
private _cashOk = _cash <= 0 || {_cashResult isEqualType createHashMap && {_cashResult getOrDefault ["success", false]}};
private _success = _xpOk && {_cashOk};

[format [
    "Revive reward UID=%1 target=%2 xp=%3 cash=%4 token=%5 xpOk=%6 cashOk=%7",
    _reviverUid,
    _casualtyUid,
    _xp,
    _cash,
    _cycleToken,
    _xpOk,
    _cashOk
], if (_success) then {"INFO"} else {"WARN"}] call bn_koth_fnc_common_log;

createHashMapFromArray [
    ["success", _success],
    ["code", if (_success) then {"REVIVE_REWARDED"} else {"REVIVE_REWARD_PARTIAL"}],
    ["reviverUid", _reviverUid],
    ["casualtyUid", _casualtyUid],
    ["cycleToken", _cycleToken],
    ["xp", _xp],
    ["cash", _cash]
]
