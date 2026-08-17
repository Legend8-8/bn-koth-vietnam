/*
    File: fn_initServer.sqf
    Author: Legend
    Edited: Mongo
    Edited: tylervip
    Description: Registers respawn handlers and starts the authoritative safe-zone manager.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_respawnHandlersInitialized", false]) then {
    private _existingKilledId = missionNamespace getVariable ["BN_KOTH_respawnEntityKilledEhId", -1];
    private _existingRespawnedId = missionNamespace getVariable ["BN_KOTH_respawnEntityRespawnedEhId", -1];
    [format ["Respawn mission EHs already registered: EntityKilled=%1 EntityRespawned=%2", _existingKilledId, _existingRespawnedId], "INFO"] call bn_koth_fnc_common_log;
} else {

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
        [_killed] call bn_koth_fnc_respawn_cleanupSafeZoneEntity;
    };

    if (_isPlayerEntity && {!alive _killed}) then {
        [_killed] spawn bn_koth_fnc_respawn_cleanupDeadBody;
    };

    [_killed] call bn_koth_fnc_respawn_handlePlayerDeath;
    [_killed] call bn_koth_fnc_respawn_cleanupSafeZoneEntity;
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
};

private _existingEntityCreatedId = missionNamespace getVariable ["BN_KOTH_safeZoneEntityCreatedEhId", -1];
if (_existingEntityCreatedId < 0) then {
    private _entityCreatedEhId = addMissionEventHandler ["EntityCreated", {
        params ["_entity"];

        if (!isServer || {isNull _entity}) exitWith {};
        if !(
            (_entity isKindOf "GroundWeaponHolder")
            || {_entity isKindOf "WeaponHolderSimulated"}
            || {_entity isKindOf "WeaponHolder"}
            || {(typeOf _entity) isEqualTo "Weapon_Empty"}
        ) exitWith {};

        [_entity] spawn {
            params ["_entity"];
            sleep 0.01;

            if (!isNull _entity) then {
                [_entity] call bn_koth_fnc_respawn_cleanupSafeZoneEntity;
            };
        };
    }];

    missionNamespace setVariable ["BN_KOTH_safeZoneEntityCreatedEhId", _entityCreatedEhId];
    [format ["Safe-zone EntityCreated cleanup EH registered: %1", _entityCreatedEhId], "INFO"] call bn_koth_fnc_common_log;
};

private _respawnCfg = missionConfigFile >> "CfgBnKothRespawn";
private _safeZoneInterval = if (isNumber (_respawnCfg >> "safeZoneCheckIntervalSeconds")) then {
    (getNumber (_respawnCfg >> "safeZoneCheckIntervalSeconds")) max 0.05
} else {
    5.0
};
private _messageCooldown = if (isNumber (_respawnCfg >> "blockedActionMessageCooldownSeconds")) then {
    (getNumber (_respawnCfg >> "blockedActionMessageCooldownSeconds")) max 0
} else {
    1
};

missionNamespace setVariable ["BN_KOTH_safeZoneCheckIntervalSeconds", _safeZoneInterval];
missionNamespace setVariable ["BN_KOTH_safeZoneMessageCooldownSeconds", _messageCooldown, true];

if !(missionNamespace getVariable ["BN_KOTH_safeZoneManagerRunning", false]) then {
    missionNamespace setVariable ["BN_KOTH_safeZoneManagerRunning", true];
    missionNamespace setVariable ["BN_KOTH_safeZoneTrackedVehicles", []];
    [] spawn bn_koth_fnc_respawn_monitorSafeZones;
    [format ["Safe-zone manager started with %1s interval.", _safeZoneInterval], "INFO"] call bn_koth_fnc_common_log;
};
