/*
    File: fn_monitorManagedVehicles.sqf
    Author: tylervip
    Description: Monitors managed free vehicles for destruction and abandonment, then schedules respawns.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

while {missionNamespace getVariable ["BN_KOTH_vehicleMonitorRunning", false]} do {
    if !(missionNamespace getVariable ["BN_KOTH_vehicleSystemEnabled", false]) exitWith {};

    private _slots = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlots", createHashMap];
    private _slotIds = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlotIds", []];
    private _abandonmentTimeout = missionNamespace getVariable ["BN_KOTH_vehicleAbandonmentTimeoutSeconds", 300];

    {
        private _slotId = _x;
        private _slotData = _slots getOrDefault [_slotId, createHashMap];
        if !(_slotData isEqualType createHashMap) then {
            continue;
        };

        if !(_slotData getOrDefault ["enabled", true]) then {
            continue;
        };

        private _vehicle = _slotData getOrDefault ["vehicle", objNull];
        private _cooldown = (_slotData getOrDefault ["cooldownSeconds", 10]) max 1;
        private _respawnAt = _slotData getOrDefault ["respawnAt", -1];
        private _spawnPosition = _slotData getOrDefault ["spawnPosition", []];

        if (isNull _vehicle || {!alive _vehicle}) then {
            if (_respawnAt < 0) then {
                _slotData set ["emptySince", -1];
                _slotData set ["respawnAt", serverTime + _cooldown];
                _slots set [_slotId, _slotData];

                [format ["Managed slot '%1' scheduled respawn in %2s.", _slotId, _cooldown], "INFO"] call bn_koth_fnc_common_log;
                continue;
            };

            if (serverTime >= _respawnAt) then {
                [_slotId] call bn_koth_fnc_vehicles_spawnManagedSlot;
                continue;
            };

            continue;
        };

        private _playerOccupants = (crew _vehicle) select {isPlayer _x};
        if ((count _playerOccupants) <= 0) then {
            private _emptySince = _slotData getOrDefault ["emptySince", -1];

            if (_emptySince < 0) then {
                _slotData set ["emptySince", serverTime];
                _slots set [_slotId, _slotData];
                continue;
            };

            if ((serverTime - _emptySince) >= _abandonmentTimeout) then {
                private _isAtSpawn = false;

                if ((count _spawnPosition) >= 2) then {
                    private _spawnTolerance = (missionNamespace getVariable ["BN_KOTH_vehicleSpawnClearRadiusMeters", 8]) max 1;
                    _isAtSpawn = (_vehicle distance2D _spawnPosition) <= _spawnTolerance;
                };

                if (_isAtSpawn) then {
                    _slotData set ["emptySince", -1];
                    _slots set [_slotId, _slotData];
                    continue;
                };

                deleteVehicle _vehicle;
                _slotData set ["vehicle", objNull];
                _slotData set ["emptySince", -1];
                _slotData set ["respawnAt", serverTime + _cooldown];
                _slots set [_slotId, _slotData];

                [format ["Managed slot '%1' recycled after abandonment; respawn in %2s.", _slotId, _cooldown], "INFO"] call bn_koth_fnc_common_log;
                continue;
            };
        } else {
            if ((_slotData getOrDefault ["emptySince", -1]) >= 0) then {
                _slotData set ["emptySince", -1];
                _slots set [_slotId, _slotData];
            };
        };
    } forEach _slotIds;

    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

    private _interval = (missionNamespace getVariable ["BN_KOTH_vehicleMonitorIntervalSeconds", 1]) max 1;
    sleep _interval;
};

missionNamespace setVariable ["BN_KOTH_vehicleMonitorRunning", false];
["Managed vehicle monitor stopped.", "INFO"] call bn_koth_fnc_common_log;
