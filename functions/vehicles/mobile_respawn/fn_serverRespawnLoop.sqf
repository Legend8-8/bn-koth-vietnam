/*
    File: fn_serverRespawnLoop.sqf
    Author: tylervip
    Description: Tracks command vehicles for the active location and enforces same-side access.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: No
*/

if (!isServer) exitWith {};

private _vehicleCfg = missionConfigFile >> "CfgBnKothVehicles";
private _westCommandClass = if (isClass _vehicleCfg) then {getText (_vehicleCfg >> "westCommandVehicleClass")} else {""};
private _eastCommandClass = if (isClass _vehicleCfg) then {getText (_vehicleCfg >> "eastCommandVehicleClass")} else {""};

private _spawnClearRadius = missionNamespace getVariable ["BN_KOTH_vehicleSpawnClearRadiusMeters", 8];
private _spawnBlockedRetrySeconds = (missionNamespace getVariable ["BN_KOTH_vehicleSpawnBlockedRetrySeconds", 5]) max 1;
private _spawnIncludePlayers = missionNamespace getVariable ["BN_KOTH_vehicleSpawnIncludePlayers", true];
private _spawnIncludeVehicles = missionNamespace getVariable ["BN_KOTH_vehicleSpawnIncludeVehicles", true];
private _commandCooldownSeconds = (missionNamespace getVariable ["BN_KOTH_commandVehicleRespawnCooldownSeconds", 30]) max 1;

if (isClass _vehicleCfg) then {
    _commandCooldownSeconds = (getNumber (_vehicleCfg >> "commandVehicleRespawnCooldownSeconds")) max 1;
};

private _trackVehicle = {
    params ["_vehicle", "_side", "_sideToken"];

    if (isNull _vehicle || {!alive _vehicle}) exitWith {};

    _vehicle setVariable ["BN_KOTH_commandVehicleSide", _side, true];
    _vehicle setVariable ["BN_KOTH_commandVehicleSideToken", _sideToken, true];

    if (_vehicle getVariable ["BN_KOTH_commandGetInEhAdded", false]) exitWith {};

    _vehicle setVariable ["BN_KOTH_commandGetInEhAdded", true];
    _vehicle addEventHandler ["GetIn", {
        params ["_vehicle", "_role", "_unit", "_turret"];

        private _allowedSide = _vehicle getVariable ["BN_KOTH_commandVehicleSide", sideUnknown];
        if (_allowedSide isEqualTo sideUnknown) exitWith {};

        if ((side _unit) isEqualTo _allowedSide) exitWith {};

        moveOut _unit;
        ["Enemy team cannot enter this command vehicle."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _unit];
    }];
};

private _resolveSpawnTransform = {
    params ["_spawnRef"];

    if (_spawnRef isEqualTo "") exitWith {[]};

    if !((markerShape _spawnRef) isEqualTo "") exitWith {
        [markerPos _spawnRef, markerDir _spawnRef]
    };

    private _spawnObj = missionNamespace getVariable [_spawnRef, objNull];
    if (isNull _spawnObj) exitWith {[]};

    [getPosATL _spawnObj, getDir _spawnObj]
};

private _respawnAtBySide = createHashMapFromArray [["WEST", -1], ["EAST", -1]];
private _pendingCommandWrecks = createHashMapFromArray [["WEST", objNull], ["EAST", objNull]];
private _lastActiveLocationId = "";

while {missionNamespace getVariable ["BN_KOTH_commandTeleportMonitorRunning", false]} do {
    private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];

    if !(_lastActiveLocationId isEqualTo _activeLocationId) then {
        private _previousVehicles = missionNamespace getVariable ["BN_KOTH_commandVehicles", createHashMap];
        {
            private _oldVehicle = _previousVehicles getOrDefault [_x, objNull];
            if (!isNull _oldVehicle) then {
                deleteVehicle _oldVehicle;
            };
        } forEach ["WEST", "EAST"];

        _respawnAtBySide = createHashMapFromArray [["WEST", -1], ["EAST", -1]];
        _lastActiveLocationId = _activeLocationId;
    };

    if (_activeLocationId isEqualTo "") then {
        missionNamespace setVariable ["BN_KOTH_commandBoardDefs", [], true];
        missionNamespace setVariable ["BN_KOTH_commandVehicles", createHashMap, true];
        uiSleep 2;
        continue;
    };

    private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
    private _activeCfg = _locationsCfg >> _activeLocationId;
    if !(isClass _activeCfg) then {
        missionNamespace setVariable ["BN_KOTH_commandBoardDefs", [], true];
        missionNamespace setVariable ["BN_KOTH_commandVehicles", createHashMap, true];
        uiSleep 2;
        continue;
    };

    private _westSpawnRef = getText (_activeCfg >> "westCommand_spawnpoint");
    private _eastSpawnRef = getText (_activeCfg >> "eastCommand_spawnpoint");
    private _westBoardRef = getText (_activeCfg >> "westCommand_mapboard");
    private _eastBoardRef = getText (_activeCfg >> "eastCommand_mapboard");

    private _vehiclesBySide = createHashMap;
    private _currentVehiclesBySide = missionNamespace getVariable ["BN_KOTH_commandVehicles", createHashMap];
    private _specs = [
        [west, "WEST", _westSpawnRef, _westCommandClass],
        [east, "EAST", _eastSpawnRef, _eastCommandClass]
    ];

    {
        _x params ["_side", "_sideToken", "_spawnRef", "_vehicleClass"];

        if (_spawnRef isEqualTo "" || {_vehicleClass isEqualTo ""}) then {
            _vehiclesBySide set [_sideToken, objNull];
            continue;
        };

        private _spawnTransform = [_spawnRef] call _resolveSpawnTransform;
        if (_spawnTransform isEqualTo []) then {
            _vehiclesBySide set [_sideToken, objNull];
            continue;
        };
        _spawnTransform params ["_spawnPos", "_spawnDir"];

        private _vehicle = _currentVehiclesBySide getOrDefault [_sideToken, objNull];
        if (!isNull _vehicle && {!alive _vehicle}) then {
            _pendingCommandWrecks set [_sideToken, _vehicle];
            _vehicle = objNull;
            _respawnAtBySide set [_sideToken, serverTime + _commandCooldownSeconds];
        };

        if (isNull _vehicle) then {
            private _respawnAt = _respawnAtBySide getOrDefault [_sideToken, -1];
            if ((_respawnAt >= 0) && {serverTime < _respawnAt}) then {
                _vehiclesBySide set [_sideToken, objNull];
                continue;
            };

            private _candidates = (nearestObjects [_spawnPos, ["LandVehicle"], 30]) select {
                alive _x &&
                ((_x getVariable ["BN_KOTH_commandVehicleSideToken", ""]) isEqualTo _sideToken)
            };

            if !(_candidates isEqualTo []) then {
                _candidates = [_candidates, [], {_spawnPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
                _vehicle = _candidates select 0;
            };
        };

        if (isNull _vehicle) then {
            private _respawnAt = _respawnAtBySide getOrDefault [_sideToken, -1];
            if ((_respawnAt >= 0) && {serverTime < _respawnAt}) then {
                _vehiclesBySide set [_sideToken, objNull];
                continue;
            };

            private _pendingWreck = _pendingCommandWrecks getOrDefault [_sideToken, objNull];
            if (!isNull _pendingWreck && {!alive _pendingWreck}) then {
                deleteVehicle _pendingWreck;
                _pendingCommandWrecks set [_sideToken, objNull];
            };

            private _spawnCheck = [
                _spawnPos,
                _spawnClearRadius,
                objNull,
                _spawnIncludePlayers,
                _spawnIncludeVehicles
            ] call bn_koth_fnc_vehicles_isSpawnAreaClear;

            if !(_spawnCheck getOrDefault ["isClear", true]) then {
                private _currentRespawnAt = _respawnAtBySide getOrDefault [_sideToken, -1];
                private _retryAt = serverTime + _spawnBlockedRetrySeconds;

                if (_currentRespawnAt < 0) then {
                    _respawnAtBySide set [_sideToken, _retryAt];
                } else {
                    _respawnAtBySide set [_sideToken, _currentRespawnAt max _retryAt];
                };

                _vehiclesBySide set [_sideToken, objNull];
                continue;
            };

            _vehicle = createVehicle [_vehicleClass, _spawnPos, [], 0, "NONE"];
            _vehicle setDir _spawnDir;
            _vehicle setPosATL _spawnPos;
            _vehicle lock 0;
            [_vehicle, _side, _sideToken] call _trackVehicle;
            [_vehicle] call bn_koth_fnc_vehicles_clearVehicleInventory;
            [_vehicle] call bn_koth_fnc_vehicles_addVehicleInventory;
            _respawnAtBySide set [_sideToken, -1];
        } else {
            [_vehicle, _side, _sideToken] call _trackVehicle;
        };

        _vehiclesBySide set [_sideToken, _vehicle];
    } forEach _specs;

    private _currentPublishedVehicles = missionNamespace getVariable ["BN_KOTH_commandVehicles", createHashMap];
    if !(_currentPublishedVehicles isEqualTo _vehiclesBySide) then {
        missionNamespace setVariable ["BN_KOTH_commandVehicles", _vehiclesBySide, true];
    };

    private _boardDefs = [["WEST", _westBoardRef], ["EAST", _eastBoardRef]];
    private _currentBoardDefs = missionNamespace getVariable ["BN_KOTH_commandBoardDefs", []];
    if !(_currentBoardDefs isEqualTo _boardDefs) then {
        missionNamespace setVariable ["BN_KOTH_commandBoardDefs", _boardDefs, true];
    };
    uiSleep 2;
};
