/*
    File: fn_rentVehicle.sqf
    Author: Legend
    Description: Existing paid-vehicle transaction owner generalized for RENT,
        PURCHASE (durable family ownership plus included first spawn), and
        SPAWN (paid owned replacement). Cash and ownership share one persisted
        projection; failed saves restore session state and require a confirmed
        compensating save before rollback is reported as durable.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: vehicle classname <STRING>,
        2: RENT | PURCHASE | SPAWN <STRING>
    Returns: Transaction result <HASHMAP>
    Public: No
*/
params [["_uid", "", [""]], ["_vehicleClass", "", [""]], ["_operation", "RENT", [""]]];
_operation = toUpper _operation;
private _fail = {
    params ["_code", "_message"];
    [format ["Personal vehicle FAILED UID=%1 operation=%2 requested=%3 code=%4 reason=%5", _uid, _operation, toLower _vehicleClass, _code, _message], "WARN"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", _code], ["message", _message], ["vehicleClass", toLower _vehicleClass], ["operation", _operation]]
};
if (!isServer) exitWith {["NOT_SERVER", "Server authority required."] call _fail};
if !(_operation in ["RENT", "PURCHASE", "SPAWN"]) exitWith {["INVALID_OPERATION", "Invalid vehicle transaction."] call _fail};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {["PLAYER_NOT_REGISTERED", "Player state is not ready."] call _fail};
private _playerObj = _record getOrDefault ["currentUnit", objNull];
if (isNull _playerObj || {!alive _playerObj} || {!(_record getOrDefault ["deployed", false])} || {!((_record getOrDefault ["state", ""]) isEqualTo "ACTIVE")} || {!((missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE")}) exitWith {["NOT_DEPLOYED", "Paid vehicles require an alive, actively deployed player."] call _fail};
if !((getPlayerUID _playerObj) isEqualTo _uid) exitWith {["PLAYER_NOT_REGISTERED", "Current representation does not match the vehicle owner."] call _fail};

private _activeMap = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap];
private _activeVehicle = (_activeMap getOrDefault [_uid, createHashMap]) getOrDefault ["vehicle", objNull];
if (!isNull _activeVehicle && {alive _activeVehicle}) exitWith {["VEHICLE_ALREADY_ACTIVE", "Your personal paid vehicle is still active."] call _fail};
private _cooldown = (missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", createHashMap]) getOrDefault [_uid, 0];
if (serverTime < _cooldown) exitWith {["VEHICLE_COOLDOWN", format ["Available in %1 seconds.", ceil (_cooldown - serverTime)]] call _fail};

private _metadata = [_vehicleClass] call bn_koth_fnc_vehicles_getProgressionMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {["INVALID_VEHICLE", "Vehicle product is invalid."] call _fail};
private _canonical = _metadata getOrDefault ["canonicalClass", ""];
private _familyId = _metadata getOrDefault ["familyId", ""];
private _loadoutId = _metadata getOrDefault ["loadoutId", ""];
private _sideToken = if ((_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo west) then {"WEST"} else {if ((_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo east) then {"EAST"} else {""}};
private _progressions = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _progression = _progressions getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE", "Player progression is not ready."] call _fail};
private _loadedUids = missionNamespace getVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
if (_loadedUids isEqualType createHashMap && {(_loadedUids getOrDefault [_uid, ""]) isEqualTo "SESSION_FALLBACK"}) exitWith {
    ["PERSISTENCE_UNAVAILABLE", "Durable vehicle transactions are unavailable for this session."] call _fail
};
private _level = [_progression getOrDefault ["xp", 0]] call bn_koth_fnc_progression_xp_getLevel;
private _rules = [_sideToken, _level, _progression getOrDefault ["activePerks", []], _metadata] call bn_koth_fnc_vehicles_evaluateProgressionRules;
if !(_rules getOrDefault ["eligible", false]) exitWith {[_rules getOrDefault ["code", "INVALID_VEHICLE"], _rules getOrDefault ["message", "Vehicle unavailable."]] call _fail};
private _ownedLoadoutRules = [_progression, _metadata, true] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
private _rentalLoadoutRules = [_progression, _metadata, false] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
private _owned = _ownedLoadoutRules getOrDefault ["owned", false];
private _firstSpawnUsed = _familyId in (_progression getOrDefault ["vehicleFirstSpawnsUsed", []]);
if (_operation isEqualTo "PURCHASE" && {_owned}) exitWith {["ALREADY_OWNED", "This vehicle family is already owned."] call _fail};
if (_operation isEqualTo "PURCHASE" && {!(_ownedLoadoutRules getOrDefault ["purchaseEligible", false])}) exitWith {["BASE_LOADOUT_REQUIRED", "Purchase begins with the base family loadout."] call _fail};
if (_operation isEqualTo "SPAWN" && {!_owned}) exitWith {["FAMILY_NOT_OWNED", "This vehicle family is not owned."] call _fail};
if (_operation isEqualTo "SPAWN" && {!_firstSpawnUsed}) exitWith {["FIRST_SPAWN_STATE_INVALID", "Owned family first-spawn state is invalid; no charge was made."] call _fail};
if (_operation isEqualTo "SPAWN" && {!(_ownedLoadoutRules getOrDefault ["unlocked", false])}) exitWith {["LOADOUT_LOCKED", _ownedLoadoutRules getOrDefault ["message", "Loadout mastery requirements are incomplete."]] call _fail};
if (_operation isEqualTo "RENT" && {!(_metadata getOrDefault ["rentable", false])}) exitWith {["NOT_RENTABLE", "This mastery loadout cannot be rented."] call _fail};
if (_operation isEqualTo "RENT" && {!(_rentalLoadoutRules getOrDefault ["unlocked", false])}) exitWith {["LOADOUT_LOCKED", _rentalLoadoutRules getOrDefault ["message", "Rental mastery requirements are incomplete."]] call _fail};

private _price = switch (_operation) do {case "PURCHASE": {_metadata getOrDefault ["purchasePrice", -1]}; case "SPAWN": {_metadata getOrDefault ["replacementPrice", -1]}; default {_metadata getOrDefault ["rentalPrice", -1]}};
if (_price <= 0) exitWith {["UNCONFIGURED_PRICE", "Vehicle price is not configured."] call _fail};
if (([_uid] call bn_koth_fnc_progression_cash_getCash) < _price) exitWith {["INSUFFICIENT_CASH", "Insufficient cash for this vehicle transaction."] call _fail};

private _activeLocation = toLower (missionNamespace getVariable ["BN_KOTH_activeLocationId", ""]);
if (_activeLocation isEqualTo "") exitWith {["NOT_DEPLOYED", "Paid vehicles require an active deployed location."] call _fail};
private _category = _metadata getOrDefault ["storeCategory", "GROUND"];
private _padCategory = if (_category isEqualTo "GROUND") then {"GROUND"} else {if (_category in ["ROTARY", "FIXED_WING"]) then {"AIR"} else {"SEA"}};
if (_padCategory isEqualTo "SEA") exitWith {["NO_SAFE_SPAWN", "No curated sea paid-vehicle policy is available."] call _fail};
private _locationData = [_activeLocation] call bn_koth_fnc_zone_getLocationData;
private _boardRef = if (_sideToken isEqualTo "WEST") then {_locationData getOrDefault ["westCommand_mapboard", ""]} else {_locationData getOrDefault ["eastCommand_mapboard", ""]};
private _boardTarget = missionNamespace getVariable [_boardRef, objNull];
private _mapboardDistance = (getNumber (missionConfigFile >> "CfgBnKothInteractions" >> "teamMapboardAccessDistance")) max 1;
if (isNull _boardTarget && {!(_boardRef isEqualTo "")} && {!((markerShape _boardRef) isEqualTo "")}) then {
    private _boardPos = markerPos _boardRef;
    private _boardCandidates = nearestObjects [_boardPos, ["Static", "Thing", "House", "LandVehicle"], _mapboardDistance];
    if !(_boardCandidates isEqualTo []) then {_boardCandidates = [_boardCandidates, [], {_boardPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy; _boardTarget = _boardCandidates select 0};
};
if (isNull _boardTarget || {(_playerObj distance2D _boardTarget) > _mapboardDistance}) exitWith {["NOT_AT_TEAM_MAPBOARD", "Paid vehicles require access through your active team mapboard."] call _fail};
private _aoCaps = [_locationData] call bn_koth_fnc_zone_getVehicleCapabilities;
private _sideCaps = (_aoCaps getOrDefault ["sides", createHashMap]) getOrDefault [_sideToken, createHashMap];
if !(((_sideCaps getOrDefault ["families", createHashMap]) getOrDefault [_category, createHashMap]) getOrDefault ["paid", false]) exitWith {["DISABLED_FOR_AO", "This vehicle category is disabled for the active AO."] call _fail};

private _reservations = missionNamespace getVariable ["BN_KOTH_vehiclePaidPadReservations", createHashMap];
private _radius = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "paidSpawnClearanceMeters")) max 1;
private _allPads = (missionNamespace getVariable ["BN_KOTH_vehiclePaidPads", []]) select {(_x getOrDefault ["side", ""]) isEqualTo _sideToken && {(_x getOrDefault ["category", ""]) isEqualTo _padCategory} && {(_x getOrDefault ["location", ""]) isEqualTo _activeLocation}};
private _pads = _allPads select {isNil {_reservations get (_x getOrDefault ["id", ""])}};
private _chosen = createHashMap;
{private _check = [_x getOrDefault ["position", [0,0,0]], _radius, objNull, true, true] call bn_koth_fnc_vehicles_isSpawnAreaClear; if (_check getOrDefault ["isClear", false]) exitWith {_chosen = _x}} forEach _pads;
private _spawnPos = []; private _spawnDir = 0; private _reservationId = "";
if ((count _chosen) > 0) then {_spawnPos = _chosen get "position"; _spawnDir = _chosen get "direction"; _reservationId = _chosen get "id"} else {
    private _anchor = if ((count _allPads) > 0) then {(_allPads select 0) getOrDefault ["position", []]} else {[]};
    if ((count _anchor) > 0) then {
        _spawnPos = _anchor findEmptyPosition [_radius, (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "paidFallbackSpawnRadiusMeters")) max 1, _canonical];
        private _minNormal = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "paidSpawnMinimumSurfaceNormalZ")) max 0 min 1;
        if ((count _spawnPos) > 0 && {!surfaceIsWater _spawnPos} && {(surfaceNormal _spawnPos select 2) >= _minNormal}) then {private _check = [_spawnPos, _radius, objNull, true, true] call bn_koth_fnc_vehicles_isSpawnAreaClear; if !(_check getOrDefault ["isClear", false]) then {_spawnPos = []}} else {_spawnPos = []};
    };
};
if ((count _spawnPos) isEqualTo 0) exitWith {["NO_SAFE_SPAWN", "No safe paid-vehicle position is currently available."] call _fail};
if !(_reservationId isEqualTo "") then {_reservations set [_reservationId, _uid]; missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations", _reservations]};
private _releaseReservation = {if !(_reservationId isEqualTo "") then {_reservations deleteAt _reservationId; missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations", _reservations]}};

private _vehicle = createVehicle [_canonical, _spawnPos, [], 0, "NONE"];
if (isNull _vehicle) exitWith {call _releaseReservation; ["SPAWN_FAILED", "Vehicle creation failed; no charge was made."] call _fail};
_vehicle setDir _spawnDir; _vehicle setPosATL _spawnPos;
if !([_vehicle, _metadata] call bn_koth_fnc_vehicles_applyVisualProfile) exitWith {deleteVehicle _vehicle; call _releaseReservation; ["VISUAL_PROFILE_REJECTED", "Vehicle visual policy rejected the spawn; no charge was made."] call _fail};
clearWeaponCargoGlobal _vehicle; clearMagazineCargoGlobal _vehicle; clearItemCargoGlobal _vehicle; clearBackpackCargoGlobal _vehicle;

private _oldOwned = +(_progression getOrDefault ["ownedVehicleFamilies", []]);
private _oldUsed = +(_progression getOrDefault ["vehicleFirstSpawnsUsed", []]);
private _oldCash = _progression getOrDefault ["cash", -1];
private _spent = [_uid, _price, format ["vehicle_%1:%2", toLower _operation, _loadoutId]] call bn_koth_fnc_progression_cash_spendCash;
if !(_spent getOrDefault ["success", false]) exitWith {deleteVehicle _vehicle; call _releaseReservation; [_spent getOrDefault ["code", "INSUFFICIENT_CASH"], "Vehicle cash transaction failed."] call _fail};
if (_operation isEqualTo "PURCHASE") then {
    private _ownedFamilies = +_oldOwned; _ownedFamilies pushBackUnique _familyId;
    private _usedFamilies = +_oldUsed; _usedFamilies pushBackUnique _familyId;
    _progression set ["ownedVehicleFamilies", _ownedFamilies]; _progression set ["vehicleFirstSpawnsUsed", _usedFamilies];
    _progressions set [_uid, _progression]; missionNamespace setVariable ["BN_KOTH_playerProgression", _progressions];
    [_uid, "vehicle_ownership"] call bn_koth_fnc_persistence_markDirty;
};
private _save = [_uid, format ["vehicle_%1", toLower _operation]] call bn_koth_fnc_persistence_savePlayer;
if !(_save getOrDefault ["success", false]) exitWith {
    private _initialSaveCode = _save getOrDefault ["code", "SAVE_FAILED"];
    _progressions = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]; _progression = _progressions getOrDefault [_uid, createHashMap];
    _progression set ["ownedVehicleFamilies", _oldOwned]; _progression set ["vehicleFirstSpawnsUsed", _oldUsed];
    _progressions set [_uid, _progression]; missionNamespace setVariable ["BN_KOTH_playerProgression", _progressions];
    private _refund = [_uid, _price, format ["vehicle_%1_rollback:%2", toLower _operation, _loadoutId], false, false] call bn_koth_fnc_progression_cash_addCash;
    private _refundSucceeded = _refund getOrDefault ["success", false];
    private _refundCash = _refund getOrDefault ["cash", -1];
    private _cashRestored = _refundSucceeded && {_refundCash isEqualTo _oldCash};
    if (_refundSucceeded) then {[_uid, "cash", 0, ""] call bn_koth_fnc_progression_publishUpdate};
    private _rollbackSave = if (_cashRestored) then {
        [_uid, "vehicle_transaction_rollback"] call bn_koth_fnc_persistence_savePlayer
    } else {
        createHashMapFromArray [["success", false], ["code", "CASH_ROLLBACK_FAILED"]]
    };
    private _rollbackSaved = _rollbackSave getOrDefault ["success", false];
    private _rollbackCode = _rollbackSave getOrDefault ["code", "ROLLBACK_SAVE_FAILED"];
    deleteVehicle _vehicle; call _releaseReservation;
    if (!_cashRestored || {!_rollbackSaved}) then {
        [format ["Personal vehicle ROLLBACK FAILED UID=%1 operation=%2 family=%3 loadout=%4 initialSave=%5 refundSuccess=%6 refundCash=%7 expectedCash=%8 rollbackSave=%9", _uid, _operation, _familyId, _loadoutId, _initialSaveCode, _refundSucceeded, _refundCash, _oldCash, _rollbackCode], "ERROR"] call bn_koth_fnc_common_log;
        ["PERSISTENCE_ROLLBACK_FAILED", "Vehicle spawn was removed, but durable transaction rollback could not be confirmed. An operator must inspect persistence state."] call _fail
    } else {
        [format ["Personal vehicle ROLLBACK CONFIRMED UID=%1 operation=%2 family=%3 loadout=%4 initialSave=%5 refundCash=%6 rollbackSave=%7", _uid, _operation, _familyId, _loadoutId, _initialSaveCode, _refundCash, _rollbackCode], "WARN"] call bn_koth_fnc_common_log;
        ["PERSISTENCE_FAILED_ROLLED_BACK", "Vehicle transaction could not be saved; session cash/state and durable rollback were confirmed."] call _fail
    }
};

_vehicle setVariable ["BN_KOTH_isPersonalPaidVehicle", true, true];
_vehicle setVariable ["BN_KOTH_personalOwnerUid", _uid, true];
_vehicle setVariable ["BN_KOTH_personalVehicleClass", _canonical, true];
_vehicle setVariable ["BN_KOTH_personalFamilyId", _familyId, true];
_vehicle setVariable ["BN_KOTH_personalLoadoutId", _loadoutId, true];
_vehicle setVariable ["BN_KOTH_personalLifeType", _operation, true];
_vehicle setVariable ["BN_KOTH_personalAccessMode", "OWNER_ONLY", true];
_vehicle addEventHandler ["Killed", {params ["_vehicle"]; [_vehicle getVariable ["BN_KOTH_personalOwnerUid", ""], _vehicle, "DESTROYED"] call bn_koth_fnc_vehicles_endRentalLife; private _delay = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "rentedWreckCleanupSeconds")) max 0; [_vehicle, _delay] spawn {params ["_wreck", "_delay"]; sleep _delay; if (!isNull _wreck) then {deleteVehicle _wreck}}}];
_vehicle addEventHandler ["Deleted", {params ["_vehicle"]; [_vehicle getVariable ["BN_KOTH_personalOwnerUid", ""], _vehicle, "DELETED"] call bn_koth_fnc_vehicles_endRentalLife}];
_vehicle addEventHandler ["GetIn", {params ["_vehicle", "_role", "_unit"]; if (!isPlayer _unit) exitWith {}; private _ownerUid = _vehicle getVariable ["BN_KOTH_personalOwnerUid", ""]; private _mode = _vehicle getVariable ["BN_KOTH_personalAccessMode", "OWNER_ONLY"]; private _allowed = (getPlayerUID _unit) isEqualTo _ownerUid; if (_mode isEqualTo "PUBLIC") then {_allowed = true}; if (_mode isEqualTo "GROUP") then {private _ownerObj = objNull; {if (getPlayerUID _x isEqualTo _ownerUid) exitWith {_ownerObj = _x}} forEach allPlayers; _allowed = _allowed || {!isNull _ownerObj && {group _unit isEqualTo group _ownerObj}}}; if (!_allowed) then {[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_forceOutRentalVehicle", owner _unit]}}];

_activeMap set [_uid, createHashMapFromArray [["vehicle", _vehicle], ["vehicleClass", _canonical], ["familyId", _familyId], ["loadoutId", _loadoutId], ["lifeType", _operation], ["accessMode", "OWNER_ONLY"], ["spawnedAt", serverTime], ["ownerUid", _uid], ["cooldownSeconds", _metadata getOrDefault ["replacementCooldownSeconds", 90]], ["emptySince", -1], ["disconnectedSince", -1]]];
missionNamespace setVariable ["BN_KOTH_vehicleActivePersonal", _activeMap];
if (owner _playerObj > 0) then {[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_addRentalOwnerActions", owner _playerObj]};
call _releaseReservation;
[format ["Personal vehicle SUCCESS UID=%1 operation=%2 family=%3 loadout=%4 class=%5 price=%6", _uid, _operation, _familyId, _loadoutId, _canonical, _price], "INFO"] call bn_koth_fnc_common_log;
createHashMapFromArray [["success", true], ["code", format ["VEHICLE_%1", _operation]], ["message", if (_operation isEqualTo "PURCHASE") then {"Vehicle family purchased; first spawn included."} else {if (_operation isEqualTo "SPAWN") then {"Replacement vehicle requisitioned."} else {"Vehicle rented for one life."}}], ["operation", _operation], ["vehicleClass", _canonical], ["familyId", _familyId], ["loadoutId", _loadoutId], ["price", _price], ["cash", _spent getOrDefault ["cash", -1]], ["personalVehicleState", [_uid] call bn_koth_fnc_vehicles_getRentalState]]
