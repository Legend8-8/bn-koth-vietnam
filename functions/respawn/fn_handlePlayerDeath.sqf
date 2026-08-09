/*
    File: fn_handlePlayerDeath.sqf
    Author: Legend
    Description: Server-authoritative death handling for active-round eligibility.
    Execution: Server
    Parameters:
        0: Dead player unit <OBJECT>
    Returns:
        True when authoritative state was updated, otherwise false <BOOL>
    Public: Yes
*/

params ["_deadUnit"];

if (!isServer) exitWith {false};
if (isNull _deadUnit) exitWith {false};

private _uid = getPlayerUID _deadUnit;
private _ownerId = owner _deadUnit;
private _isPlayerEntity = isPlayer _deadUnit;

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    ["Death handler rejected: BN_KOTH_playerRecords missing/invalid", "WARN"] call bn_koth_fnc_common_log;
    false
};

[format [
    "Death handler entered: obj=%1 type=%2 owner=%3 isPlayer=%4 uid='%5'",
    _deadUnit,
    typeOf _deadUnit,
    _ownerId,
    _isPlayerEntity,
    _uid
], "INFO"] call bn_koth_fnc_common_log;

if !(_uid isEqualTo "") then {
    private _uidRecord = _records getOrDefault [_uid, createHashMap];
    if !(_uidRecord isEqualType createHashMap) then {
        [format ["Death handler UID from entity not in records uid='%1'; attempting currentUnit match", _uid], "INFO"] call bn_koth_fnc_common_log;
        _uid = "";
    };
};

if (_uid isEqualTo "") then {
    {
        private _candidateUid = _x;
        private _candidateRecord = _records get _candidateUid;

        if (_candidateRecord isEqualType createHashMap) then {
            private _candidateUnit = _candidateRecord getOrDefault ["currentUnit", objNull];
            if (!isNull _candidateUnit && {_candidateUnit isEqualTo _deadUnit}) exitWith {
                _uid = _candidateUid;
            };
        };
    } forEach (keys _records);
};

if (_uid isEqualTo "") exitWith {
    [format ["Death ignored: unresolved UID owner=%1 type=%2 isPlayer=%3", _ownerId, typeOf _deadUnit, _isPlayerEntity], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    [format ["Death ignored: missing player record UID=%1", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
private _stateBefore = _record getOrDefault ["state", "LOBBY"];
private _roundState = [] call bn_koth_fnc_round_getState;

_record set ["currentUnit", _deadUnit];
_record set ["deployed", false];

if (_stateBefore in ["ACTIVE", "DEPLOYING", "RESPAWNING"]) then {
    _record set ["state", "RESPAWNING"];
};

_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _wasParticipant = _uid in _activeParticipants;
if (_wasParticipant) then {
    _activeParticipants = _activeParticipants - [_uid];
    ["BN_KOTH_activeParticipants", _activeParticipants] call bn_koth_fnc_common_publicState;
};

[] call bn_koth_fnc_teams_publishState;

if (_roundState isEqualTo "ACTIVE") then {
    [] call bn_koth_fnc_zone_evaluateControl;
};

[format [
    "Authoritative death UID=%1 owner=%2 side=%3 state=%4 participantRemoved=%5 round=%6",
    _uid,
    _ownerId,
    _assignedSide,
    _stateBefore,
    _wasParticipant,
    _roundState
], "INFO"] call bn_koth_fnc_common_log;

true
