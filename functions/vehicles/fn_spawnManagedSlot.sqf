/*
    File: fn_spawnManagedSlot.sqf
    Author: tylervip
    Description: Spawns one managed free vehicle slot at its configured marker.
    Execution: Server
    Parameters:
        0: Managed slot ID <STRING>
    Returns:
        True on successful spawn, otherwise false <BOOL>
    Public: Yes
*/

params [["_slotId", "", [""]]];

if (!isServer) exitWith {false};
if (_slotId isEqualTo "") exitWith {false};

private _slots = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlots", createHashMap];
private _slotData = _slots getOrDefault [_slotId, createHashMap];
if !(_slotData isEqualType createHashMap) exitWith {false};

private _existingVehicle = _slotData getOrDefault ["vehicle", objNull];
if (!isNull _existingVehicle && {alive _existingVehicle}) exitWith {true};

private _markerName = _slotData getOrDefault ["markerName", ""];
private _vehicleClass = _slotData getOrDefault ["vehicleClass", ""];
private _side = _slotData getOrDefault ["side", sideUnknown];
private _category = _slotData getOrDefault ["category", ""];

if (_markerName isEqualTo "" || {_vehicleClass isEqualTo ""}) exitWith {
    _slotData set ["enabled", false];
    _slotData set ["respawnAt", -1];
    _slots set [_slotId, _slotData];
    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

    [format ["Managed slot '%1' spawn blocked: invalid marker/class.", _slotId], "ERROR"] call bn_koth_fnc_common_log;
    false
};

if ((markerShape _markerName) isEqualTo "") exitWith {
    _slotData set ["enabled", false];
    _slotData set ["respawnAt", -1];
    _slots set [_slotId, _slotData];
    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

    [format ["Managed slot '%1' skipped: marker '%2' missing (optional slot disabled).", _slotId, _markerName], "INFO"] call bn_koth_fnc_common_log;
    false
};

private _spawnPos = markerPos _markerName;
private _spawnDir = markerDir _markerName;
private _clearRadius = missionNamespace getVariable ["BN_KOTH_vehicleSpawnClearRadiusMeters", 8];
private _retrySeconds = (missionNamespace getVariable ["BN_KOTH_vehicleSpawnBlockedRetrySeconds", 5]) max 1;
private _includePlayerBlockers = missionNamespace getVariable ["BN_KOTH_vehicleSpawnIncludePlayers", true];
private _includeVehicleBlockers = missionNamespace getVariable ["BN_KOTH_vehicleSpawnIncludeVehicles", true];

private _spawnCheck = [
    _spawnPos,
    _clearRadius,
    _existingVehicle,
    _includePlayerBlockers,
    _includeVehicleBlockers
] call bn_koth_fnc_vehicles_isSpawnAreaClear;

if !(_spawnCheck getOrDefault ["isClear", true]) exitWith {
    private _playerDetails = _spawnCheck getOrDefault ["playerDetails", []];
    private _vehicleDetails = _spawnCheck getOrDefault ["vehicleDetails", []];
    private _sampleLimit = 3;

    private _playerSamples = (_playerDetails select [0, _sampleLimit]) apply {
        format [
            "%1(uid=%2 side=%3 d=%4)",
            _x getOrDefault ["name", "<unknown>"],
            _x getOrDefault ["uid", ""],
            _x getOrDefault ["side", str sideUnknown],
            _x getOrDefault ["distance", -1]
        ]
    };

    private _vehicleSamples = (_vehicleDetails select [0, _sampleLimit]) apply {
        format [
            "%1(netId=%2 var=%3 side=%4 d=%5)",
            _x getOrDefault ["type", "<unknown>"],
            _x getOrDefault ["netId", ""],
            _x getOrDefault ["varName", ""],
            _x getOrDefault ["side", str sideUnknown],
            _x getOrDefault ["distance", -1]
        ]
    };

    _slotData set ["vehicle", objNull];
    _slotData set ["emptySince", -1];
    _slotData set ["respawnAt", serverTime + _retrySeconds];
    _slots set [_slotId, _slotData];
    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

    [format [
        "Managed slot '%1' spawn blocked at marker '%2' category=%3 radius=%4 retry=%5s players=%6 vehicles=%7 playerSamples=[%8] vehicleSamples=[%9]",
        _slotId,
        _markerName,
        _category,
        _clearRadius,
        _retrySeconds,
        count _playerDetails,
        count _vehicleDetails,
        _playerSamples joinString "; ",
        _vehicleSamples joinString "; "
    ], "WARN"] call bn_koth_fnc_common_log;

    false
};

private _vehicle = createVehicle [_vehicleClass, _spawnPos, [], 0, "NONE"];
_vehicle setDir _spawnDir;
_vehicle setPosATL _spawnPos;
_vehicle lock 0;

_vehicle setVariable ["BN_KOTH_isManagedFreeVehicle", true, true];
_vehicle setVariable ["BN_KOTH_managedVehicleSlotId", _slotId, true];
_vehicle setVariable ["BN_KOTH_managedVehicleCategory", _category, true];
_vehicle setVariable ["BN_KOTH_managedVehicleSide", _side, true];

_slotData set ["vehicle", _vehicle];
_slotData set ["respawnAt", -1];
_slotData set ["emptySince", -1];
_slots set [_slotId, _slotData];
missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

[format ["Managed slot '%1' spawned class=%2 marker=%3.", _slotId, _vehicleClass, _markerName], "INFO"] call bn_koth_fnc_common_log;
true
