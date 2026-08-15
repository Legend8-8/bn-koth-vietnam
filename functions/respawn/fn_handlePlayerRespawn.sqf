/*
    File: fn_handlePlayerRespawn.sqf
    Author: Legend
    Edited: Mongo
    Description: Server-authoritative respawn redeployment for active-round participants.
    Execution: Server (scheduled)
    Parameters:
        0: Respawned player unit <OBJECT>
        1: Previous dead player unit <OBJECT>
    Returns:
        True when redeployment succeeded, otherwise false <BOOL>
    Public: Yes
*/

params ["_newUnit", ["_oldUnit", objNull, [objNull]]];

if (!isServer) exitWith {false};
if (isNull _newUnit) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    ["Respawn handler rejected: BN_KOTH_playerRecords missing/invalid", "WARN"] call bn_koth_fnc_common_log;
    false
};

private _uid = getPlayerUID _newUnit;
private _ownerId = owner _newUnit;
private _isPlayerEntity = isPlayer _newUnit;

[format [
    "Respawn handler entered: new=%1 type=%2 owner=%3 isPlayer=%4 uid='%5' old=%6 oldType=%7",
    _newUnit,
    typeOf _newUnit,
    _ownerId,
    _isPlayerEntity,
    _uid,
    _oldUnit,
    if (isNull _oldUnit) then {"<null>"} else {typeOf _oldUnit}
], "INFO"] call bn_koth_fnc_common_log;

if !(_uid isEqualTo "") then {
    private _uidRecord = _records getOrDefault [_uid, createHashMap];
    if !(_uidRecord isEqualType createHashMap) then {
        [format ["Respawn handler UID from entity not in records uid='%1'; attempting fallback resolution", _uid], "INFO"] call bn_koth_fnc_common_log;
        _uid = "";
    };
};

if (_uid isEqualTo "") then {
    {
        private _candidateUid = _x;
        private _candidateRecord = _records get _candidateUid;

        if (_candidateRecord isEqualType createHashMap) then {
            private _candidateUnit = _candidateRecord getOrDefault ["currentUnit", objNull];
            if (!isNull _candidateUnit && {_candidateUnit isEqualTo _newUnit || {_candidateUnit isEqualTo _oldUnit}}) exitWith {
                _uid = _candidateUid;
            };
        };
    } forEach (keys _records);
};

if (_uid isEqualTo "") then {
    {
        private _candidateUid = _x;
        private _candidateRecord = _records get _candidateUid;

        if (_candidateRecord isEqualType createHashMap) then {
            private _candidateOwner = _candidateRecord getOrDefault ["ownerId", -1];
            if (_candidateOwner isEqualTo _ownerId) exitWith {
                _uid = _candidateUid;
            };
        };
    } forEach (keys _records);
};

if (_uid isEqualTo "") exitWith {
    [format ["Respawn ignored: unresolved UID owner=%1 type=%2 isPlayer=%3", _ownerId, typeOf _newUnit, _isPlayerEntity], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    [format ["Respawn ignored: missing player record UID=%1", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
private _roundState = [] call bn_koth_fnc_round_getState;

_newUnit setVariable ["BN_KOTH_teamSide", _assignedSide, true];
_newUnit setVariable ["BN_KOTH_safeZoneProtected", false, true];
_newUnit setVariable ["BN_KOTH_enemySafeZoneIntruder", false, true];
_newUnit setVariable ["BN_KOTH_safeZoneCorpsePendingCleanup", false, true];

_record set ["currentUnit", _newUnit];
_record set ["deployed", false];
_record set ["state", "RESPAWNING"];
_record set ["safeZoneProtected", false];
_record set ["enemySafeZoneIntruder", false];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[] call bn_koth_fnc_teams_publishState;

if (!isNull _oldUnit) then {
    [_oldUnit] call bn_koth_fnc_respawn_cleanupSafeZoneEntity;
};

if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    [format ["Respawn redeploy aborted: invalid assigned side UID=%1 side=%2", _uid, _assignedSide], "WARN"] call bn_koth_fnc_common_log;
    false
};

if !(_roundState isEqualTo "ACTIVE") exitWith {
    [format ["Respawn redeploy aborted: round not ACTIVE UID=%1 state=%2", _uid, _roundState], "INFO"] call bn_koth_fnc_common_log;
    false
};

private _starterResult = [_assignedSide] call bn_koth_fnc_loadouts_getStarterLoadout;
if !(_starterResult getOrDefault ["success", false]) exitWith {
    [
        format [
            "Respawn redeploy failed UID=%1 side=%2: starter lookup failed (%3)",
            _uid,
            _assignedSide,
            _starterResult getOrDefault ["code", "ERR_STARTER_LOOKUP"]
        ],
        "WARN"
    ] call bn_koth_fnc_common_log;
    false
};

private _starterLoadout = _starterResult getOrDefault ["loadout", []];
if !((_starterLoadout isEqualType []) && {(count _starterLoadout) >= 10}) exitWith {
    [
        format [
            "Respawn redeploy failed UID=%1 side=%2: starter loadout shape invalid",
            _uid,
            _assignedSide
        ],
        "WARN"
    ] call bn_koth_fnc_common_log;
    false
};

_newUnit setUnitLoadout _starterLoadout;

_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    [format ["Respawn redeploy failed UID=%1: missing player record after starter apply", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

_record set ["currentUnit", _newUnit];
_record set ["deployed", true];
_record set ["state", "ACTIVE"];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_uid in _activeParticipants) then {
    _activeParticipants pushBackUnique _uid;
    ["BN_KOTH_activeParticipants", _activeParticipants] call bn_koth_fnc_common_publicState;
};

[] call bn_koth_fnc_teams_publishState;
[_newUnit] call bn_koth_fnc_curator_init;

[format ["Respawn redeploy success UID=%1 side=%2", _uid, _assignedSide], "INFO"] call bn_koth_fnc_common_log;
true
