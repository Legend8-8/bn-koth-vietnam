/*
    File: fn_monitorSafeZones.sqf
    Author: Mongo
    Edited: tylervip
    Description: Maintains authoritative player and vehicle safe-zone state.
    Execution: Server (scheduled)
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

while {missionNamespace getVariable ["BN_KOTH_safeZoneManagerRunning", false]} do {
    private _roundState = [] call bn_koth_fnc_round_getState;
    private _westMarker = missionNamespace getVariable ["BN_KOTH_activeWestBaseZoneMarker", ""];
    private _eastMarker = missionNamespace getVariable ["BN_KOTH_activeEastBaseZoneMarker", ""];
    private _markersValid = !(_westMarker isEqualTo "")
        && {!(_eastMarker isEqualTo "")}
        && {!((markerShape _westMarker) isEqualTo "")}
        && {!((markerShape _eastMarker) isEqualTo "")};
    private _systemActive = (_roundState in ["PREPARING", "ACTIVE"]) && {_markersValid};

    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    private _vehicleCandidates = [];
    private _occupiedVehicles = [];

    if (_records isEqualType createHashMap) then {
        {
            private _uid = _x;
            private _record = _records getOrDefault [_uid, createHashMap];

            if (_record isEqualType createHashMap) then {
                _record = [_uid, _record, _systemActive, _westMarker, _eastMarker] call bn_koth_fnc_respawn_updatePlayerProtection;
                _records set [_uid, _record];

                private _unit = _record getOrDefault ["currentUnit", objNull];
                if (!isNull _unit) then {
                    private _platform = vehicle _unit;
                    if (_platform != _unit) then {
                        _vehicleCandidates pushBackUnique _platform;
                        _occupiedVehicles pushBackUnique _platform;
                    };
                };
            };
        } forEach (keys _records);

        missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
    };

    private _managedSlots = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlots", createHashMap];
    if (_managedSlots isEqualType createHashMap) then {
        {
            private _slot = _managedSlots getOrDefault [_x, createHashMap];
            if (_slot isEqualType createHashMap) then {
                private _vehicle = _slot getOrDefault ["vehicle", objNull];
                if (!isNull _vehicle) then {
                    _vehicleCandidates pushBackUnique _vehicle;
                };
            };
        } forEach (keys _managedSlots);
    };

    private _commandVehicles = missionNamespace getVariable ["BN_KOTH_commandVehicles", createHashMap];
    if (_commandVehicles isEqualType createHashMap) then {
        {
            private _vehicle = _commandVehicles getOrDefault [_x, objNull];
            if (!isNull _vehicle) then {
                _vehicleCandidates pushBackUnique _vehicle;
            };
        } forEach (keys _commandVehicles);
    };

    private _previouslyTracked = missionNamespace getVariable ["BN_KOTH_safeZoneTrackedVehicles", []];
    {
        if (!isNull _x) then {
            _vehicleCandidates pushBackUnique _x;
        };
    } forEach _previouslyTracked;

    private _nextTracked = [];
    {
        private _vehicle = _x;
        if (isNull _vehicle) then {
            continue;
        };

        private _vehicleSide = _vehicle getVariable ["BN_KOTH_managedVehicleSide", sideUnknown];
        if !([_vehicleSide] call bn_koth_fnc_teams_validateSide) then {
            _vehicleSide = _vehicle getVariable ["BN_KOTH_commandVehicleSide", sideUnknown];
        };
        if !([_vehicleSide] call bn_koth_fnc_teams_validateSide) then {
            _vehicleSide = _vehicle getVariable ["BN_KOTH_safeZoneVehicleSide", sideUnknown];
        };

        if !([_vehicleSide] call bn_koth_fnc_teams_validateSide) then {
            {
                private _crewUnit = _x;
                private _crewUid = getPlayerUID _crewUnit;
                private _crewRecord = _records getOrDefault [_crewUid, createHashMap];
                if (_crewRecord isEqualType createHashMap) then {
                    private _crewSide = _crewRecord getOrDefault ["assignedSide", sideUnknown];
                    if ([_crewSide] call bn_koth_fnc_teams_validateSide) exitWith {
                        _vehicleSide = _crewSide;
                    };
                };
            } forEach ((crew _vehicle) select {isPlayer _x});
        };

        if ([_vehicleSide] call bn_koth_fnc_teams_validateSide) then {
            _vehicle setVariable ["BN_KOTH_safeZoneVehicleSide", _vehicleSide, false];
        };

        private _membership = [_vehicle, _systemActive, _westMarker, _eastMarker] call bn_koth_fnc_respawn_getSafeZoneMembership;
        private _insideWest = _membership select 0;
        private _insideEast = _membership select 1;
        private _insideOwn = if (_vehicleSide isEqualTo west) then {_insideWest} else {_insideEast};
        private _insideOpposing = if (_vehicleSide isEqualTo west) then {_insideEast} else {_insideWest};
        private _protected = _systemActive
            && {alive _vehicle}
            && {[_vehicleSide] call bn_koth_fnc_teams_validateSide}
            && {_insideOwn};
        private _restricted = _systemActive
            && {alive _vehicle}
            && {[_vehicleSide] call bn_koth_fnc_teams_validateSide}
            && {_insideOpposing};
        private _wasProtected = _vehicle getVariable ["BN_KOTH_safeZoneVehicleProtected", false];

        if (_protected != _wasProtected) then {
            _vehicle setVariable ["BN_KOTH_safeZoneVehicleProtected", _protected, true];
        };
        if ((_vehicle getVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", false]) != _restricted) then {
            _vehicle setVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", _restricted, true];
        };

        private _currentOwner = owner _vehicle;
        private _appliedOwner = _vehicle getVariable ["BN_KOTH_safeZoneAppliedOwnerServer", -1];
        if (_protected != _wasProtected || {_currentOwner != _appliedOwner}) then {
            if (local _vehicle) then {
                [_vehicle, _protected] call bn_koth_fnc_respawn_applyVehicleProtection;
            } else {
                [_vehicle, _protected] remoteExecCall ["bn_koth_fnc_respawn_applyVehicleProtection", _currentOwner];
            };
            _vehicle setVariable ["BN_KOTH_safeZoneAppliedOwnerServer", _currentOwner, false];
        };

        private _managed = _vehicle getVariable ["BN_KOTH_isManagedFreeVehicle", false];
        private _commandSide = _vehicle getVariable ["BN_KOTH_commandVehicleSide", sideUnknown];
        private _isCommand = [_commandSide] call bn_koth_fnc_teams_validateSide;
        private _occupied = _vehicle in _occupiedVehicles;
        if (_managed || {_isCommand} || {_occupied} || {_protected} || {_restricted}) then {
            _nextTracked pushBackUnique _vehicle;
        };
    } forEach _vehicleCandidates;

    missionNamespace setVariable ["BN_KOTH_safeZoneTrackedVehicles", _nextTracked];
    sleep (missionNamespace getVariable ["BN_KOTH_safeZoneCheckIntervalSeconds", 5.0]);
};

missionNamespace setVariable ["BN_KOTH_safeZoneManagerRunning", false];
["Safe-zone manager stopped.", "WARN"] call bn_koth_fnc_common_log;
