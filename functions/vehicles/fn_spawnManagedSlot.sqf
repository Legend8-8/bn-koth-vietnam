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

if (!isNull _existingVehicle && {!alive _existingVehicle}) then {
    deleteVehicle _existingVehicle;
    _slotData set ["vehicle", objNull];
    _slots set [_slotId, _slotData];
    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];
};

private _vehicleClass = _slotData getOrDefault ["vehicleClass", ""];
private _side = _slotData getOrDefault ["side", sideUnknown];
private _category = _slotData getOrDefault ["category", ""];
private _sideToken = _slotData getOrDefault ["sideToken", ""];
private _familyName = _slotData getOrDefault ["family", ""];
private _roleName = _slotData getOrDefault ["roleName", ""];
private _locationId = _slotData getOrDefault ["locationId", ""];

if (_vehicleClass isEqualTo "" || {_locationId isEqualTo ""}) exitWith {
    _slotData set ["enabled", false];
    _slotData set ["respawnAt", -1];
    _slots set [_slotId, _slotData];
    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

    [format ["Managed slot '%1' spawn blocked: invalid location/class.", _slotId], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
private _locationData = [_activeLocationId] call bn_koth_fnc_zone_getLocationData;
private _capabilities = [_locationData] call bn_koth_fnc_zone_getVehicleCapabilities;
private _sideCapabilities = (_capabilities getOrDefault ["sides", createHashMap]) getOrDefault [_sideToken, createHashMap];
private _family = (_sideCapabilities getOrDefault ["families", createHashMap]) getOrDefault [_familyName, createHashMap];
private _role = (_sideCapabilities getOrDefault ["roles", createHashMap]) getOrDefault [_roleName, createHashMap];
if !(_activeLocationId isEqualTo _locationId && {_family getOrDefault ["free", false]} && {_role getOrDefault ["exists", false]}) exitWith {
    _slotData set ["enabled", false];
    _slotData set ["respawnAt", -1];
    _slots set [_slotId, _slotData];
    missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

    [format ["Managed slot '%1' disabled: active location or free spawn capability changed.", _slotId], "INFO"] call bn_koth_fnc_common_log;
    false
};

private _spawnRef = _role getOrDefault ["ref", ""];
private _spawnPos = _role getOrDefault ["position", []];
private _spawnDir = _role getOrDefault ["direction", 0];
if ((count _spawnPos) < 2) exitWith {false};
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
        _spawnRef,
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

[_vehicle] call bn_koth_fnc_vehicles_clearVehicleInventory;
[_vehicle] call bn_koth_fnc_vehicles_addVehicleInventory;

_slotData set ["vehicle", _vehicle];
_slotData set ["respawnAt", -1];
_slotData set ["emptySince", -1];
_slots set [_slotId, _slotData];
missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];

[format ["Managed slot '%1' spawned class=%2 role=%3.", _slotId, _vehicleClass, _spawnRef], "INFO"] call bn_koth_fnc_common_log;
true
