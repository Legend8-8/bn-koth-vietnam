/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Registers server-global respawn mission event handlers exactly once.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_respawnHandlersInitialized", false]) exitWith {
    private _existingKilledId = missionNamespace getVariable ["BN_KOTH_respawnEntityKilledEhId", -1];
    private _existingRespawnedId = missionNamespace getVariable ["BN_KOTH_respawnEntityRespawnedEhId", -1];
    [format ["Respawn mission EHs already registered: EntityKilled=%1 EntityRespawned=%2", _existingKilledId, _existingRespawnedId], "INFO"] call bn_koth_fnc_common_log;
};

private _entityKilledEhId = addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer", "_instigator", "_useEffects"];

    if (!isServer) exitWith {};
    if (isNull _killed) exitWith {};

    private _ownerId = owner _killed;
    private _isPlayerEntity = isPlayer _killed;
    private _uidFromEntity = getPlayerUID _killed;
    private _matchedUid = "";

    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    if (_records isEqualType createHashMap) then {
        {
            private _candidateUid = _x;
            private _candidateRecord = _records get _candidateUid;
            if !(_candidateRecord isEqualType createHashMap) then {
                continue;
            };

            private _candidateUnit = _candidateRecord getOrDefault ["currentUnit", objNull];
            if (!isNull _candidateUnit && {_candidateUnit isEqualTo _killed}) exitWith {
                _matchedUid = _candidateUid;
            };
        } forEach (keys _records);
    };

    [format [
        "EntityKilled EH: obj=%1 type=%2 owner=%3 isPlayer=%4 uid='%5' matchedCurrentUnit=%6 matchedUid='%7'",
        _killed,
        typeOf _killed,
        _ownerId,
        _isPlayerEntity,
        _uidFromEntity,
        !(_matchedUid isEqualTo ""),
        _matchedUid
    ], "INFO"] call bn_koth_fnc_common_log;

    if (!_isPlayerEntity && {_matchedUid isEqualTo ""}) exitWith {
        [format ["EntityKilled EH ignored non-player unmatched entity type=%1 owner=%2", typeOf _killed, _ownerId], "INFO"] call bn_koth_fnc_common_log;
    };

    [_killed] call bn_koth_fnc_respawn_handlePlayerDeath;
}];

private _entityRespawnedEhId = addMissionEventHandler ["EntityRespawned", {
    params ["_newEntity", "_oldEntity"];

    if (!isServer) exitWith {};
    if (isNull _newEntity) exitWith {};

    private _ownerId = owner _newEntity;
    private _isPlayerEntity = isPlayer _newEntity;
    private _uidFromEntity = getPlayerUID _newEntity;
    private _matchedUid = "";

    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    if (_records isEqualType createHashMap) then {
        {
            private _candidateUid = _x;
            private _candidateRecord = _records get _candidateUid;
            if !(_candidateRecord isEqualType createHashMap) then {
                continue;
            };

            private _candidateUnit = _candidateRecord getOrDefault ["currentUnit", objNull];
            if (!isNull _candidateUnit && {_candidateUnit isEqualTo _newEntity || {_candidateUnit isEqualTo _oldEntity}}) exitWith {
                _matchedUid = _candidateUid;
            };
        } forEach (keys _records);
    };

    [format [
        "EntityRespawned EH: new=%1 type=%2 owner=%3 isPlayer=%4 uid='%5' old=%6 oldType=%7 matchedCurrentUnit=%8 matchedUid='%9'",
        _newEntity,
        typeOf _newEntity,
        _ownerId,
        _isPlayerEntity,
        _uidFromEntity,
        _oldEntity,
        if (isNull _oldEntity) then {"<null>"} else {typeOf _oldEntity},
        !(_matchedUid isEqualTo ""),
        _matchedUid
    ], "INFO"] call bn_koth_fnc_common_log;

    if (!_isPlayerEntity && {_matchedUid isEqualTo ""}) exitWith {
        [format ["EntityRespawned EH ignored non-player unmatched entity type=%1 owner=%2", typeOf _newEntity, _ownerId], "INFO"] call bn_koth_fnc_common_log;
    };

    // Respawn redeployment can suspend (handoff wait/retry), so run scheduled.
    [_newEntity, _oldEntity] spawn bn_koth_fnc_respawn_handlePlayerRespawn;
}];

missionNamespace setVariable ["BN_KOTH_respawnEntityKilledEhId", _entityKilledEhId];
missionNamespace setVariable ["BN_KOTH_respawnEntityRespawnedEhId", _entityRespawnedEhId];
missionNamespace setVariable ["BN_KOTH_respawnHandlersInitialized", true];

[format ["Respawn mission EHs registered: EntityKilled=%1 EntityRespawned=%2", _entityKilledEhId, _entityRespawnedEhId], "INFO"] call bn_koth_fnc_common_log;
