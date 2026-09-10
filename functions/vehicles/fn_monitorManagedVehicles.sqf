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

    private _rentalSweepInterval = missionNamespace getVariable ["BN_KOTH_vehicleRentalMonitorIntervalSeconds", 30];
    private _lastRentalSweep = missionNamespace getVariable ["BN_KOTH_vehicleRentalLastSweepAt", -1];
    if (_lastRentalSweep < 0 || {(serverTime - _lastRentalSweep) >= _rentalSweepInterval}) then {
        missionNamespace setVariable ["BN_KOTH_vehicleRentalLastSweepAt", serverTime];
        private _connectedUids = [];
        {_connectedUids pushBackUnique (getPlayerUID _x)} forEach allPlayers;
        private _rentals = missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals", createHashMap];
        private _emptyLimit = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "rentedAbandonmentSeconds")) max 60;
        private _disconnectLimit = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "rentedOwnerDisconnectCleanupSeconds")) max 60;
        {
            private _uid = _x;
            private _rental = _rentals getOrDefault [_uid, createHashMap];
            if !(_rental isEqualType createHashMap) then {
                private _currentRentals = missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals", createHashMap];
                if (_currentRentals isEqualType createHashMap) then {
                    _currentRentals deleteAt _uid;
                    missionNamespace setVariable ["BN_KOTH_vehicleActiveRentals", _currentRentals];
                };
                continue;
            };
            private _vehicle = _rental getOrDefault ["vehicle", objNull];
            if (isNull _vehicle || {!alive _vehicle}) then {
                [_uid, _vehicle, "LIFECYCLE_SWEEP"] call bn_koth_fnc_vehicles_endRentalLife;
                continue;
            };

            private _hasPlayerCrew = (crew _vehicle findIf {isPlayer _x}) >= 0;
            private _emptySince = _rental getOrDefault ["emptySince", -1];
            private _disconnectedSince = _rental getOrDefault ["disconnectedSince", -1];
            if (_hasPlayerCrew) then {_emptySince = -1} else {if (_emptySince < 0) then {_emptySince = serverTime}};
            if (_uid in _connectedUids) then {_disconnectedSince = -1} else {if (_disconnectedSince < 0) then {_disconnectedSince = serverTime}};

            private _abandoned = _emptySince >= 0 && {(serverTime - _emptySince) >= _emptyLimit};
            private _ownerGone = _disconnectedSince >= 0
                && {(serverTime - _disconnectedSince) >= _disconnectLimit}
                && {!_hasPlayerCrew};
            if (_abandoned || {_ownerGone}) then {
                [_uid, _vehicle, if (_ownerGone) then {"OWNER_DISCONNECTED"} else {"ABANDONED"}] call bn_koth_fnc_vehicles_endRentalLife;
                deleteVehicle _vehicle;
            } else {
                _rental set ["emptySince", _emptySince];
                _rental set ["disconnectedSince", _disconnectedSince];
                private _currentRentals = missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals", createHashMap];
                private _currentRental = _currentRentals getOrDefault [_uid, createHashMap];
                if (_currentRental isEqualType createHashMap && {(_currentRental getOrDefault ["vehicle", objNull]) isEqualTo _vehicle}) then {
                    _currentRentals set [_uid, _rental];
                    missionNamespace setVariable ["BN_KOTH_vehicleActiveRentals", _currentRentals];
                };
            };
        } forEach +(keys _rentals);
    };

    private _interval = (missionNamespace getVariable ["BN_KOTH_vehicleMonitorIntervalSeconds", 1]) max 1;
    sleep _interval;
};

missionNamespace setVariable ["BN_KOTH_vehicleMonitorRunning", false];
["Managed vehicle monitor stopped.", "INFO"] call bn_koth_fnc_common_log;
