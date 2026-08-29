/*
    File: fn_spawnBattlefieldPickups.sqf
    Author: Legend
    Description: Spawns a bounded config-driven set of battlefield weapon holders inside the active AO.
    Execution: Server
    Parameters: None
    Returns: Number of holders spawned <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

[] call bn_koth_fnc_zone_cleanupBattlefieldPickups;

private _zoneCfg = missionConfigFile >> "CfgBnKothZone";
private _activeMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
if (!isClass _zoneCfg || {_activeMarker isEqualTo ""} || {(markerShape _activeMarker) isEqualTo ""}) exitWith {
    ["Battlefield pickup spawn skipped: zone config or active AO marker is unavailable.", "WARN"] call bn_koth_fnc_common_log;
    0
};

private _configuredWeapons = getArray (_zoneCfg >> "battlefieldPickupWeapons");
private _pickupCount = (getNumber (_zoneCfg >> "battlefieldPickupCount")) max 0;
private _magazineCount = (getNumber (_zoneCfg >> "battlefieldPickupMagazineCount")) max 0;
private _attemptsPerItem = (getNumber (_zoneCfg >> "battlefieldPickupPlacementAttemptsPerItem")) max 1;
private _minimumSeparation = (getNumber (_zoneCfg >> "battlefieldPickupMinimumSeparation")) max 0;
private _maximumSurfaceOffset = (getNumber (_zoneCfg >> "battlefieldPickupMaximumSurfaceOffset")) max 0;
private _surfaceClearance = (getNumber (_zoneCfg >> "battlefieldPickupSurfaceClearance")) max 0;

_pickupCount = floor _pickupCount;
_magazineCount = floor _magazineCount;
_attemptsPerItem = floor _attemptsPerItem;
_configuredWeapons = _configuredWeapons select {_x isEqualType "" && {!(_x isEqualTo "")}};

if (_pickupCount <= 0 || {(count _configuredWeapons) isEqualTo 0}) exitWith {
    [format ["Battlefield pickup spawn skipped: count=%1 configuredWeapons=%2.", _pickupCount, count _configuredWeapons], "WARN"] call bn_koth_fnc_common_log;
    0
};

private _arsenalCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility";
private _sourceWeaponsCfg = _arsenalCfg >> "SourceWeapons";
private _sourceMagazinesCfg = _arsenalCfg >> "SourceMagazines";

private _resolveMagazine = {
    params ["_weaponClass"];
    private _weaponFact = _sourceWeaponsCfg >> _weaponClass;
    if !(isClass _weaponFact) exitWith {""};

    private _baseMagazine = toLower (getText (_weaponFact >> "baseMagazine"));
    if !(_baseMagazine isEqualTo "" || {!(isClass (configFile >> "CfgMagazines" >> _baseMagazine))}) exitWith {
        _baseMagazine
    };

    private _compatible = (getArray (_weaponFact >> "compatibleMagazines")) apply {toLower _x};
    private _bestMagazine = "";
    private _bestScore = -1;
    {
        private _magazineClass = _x;
        private _magazineFact = _sourceMagazinesCfg >> _magazineClass;
        if (isClass (configFile >> "CfgMagazines" >> _magazineClass) && {isClass _magazineFact}) then {
            private _traits = (getArray (_magazineFact >> "traits")) apply {toLower _x};
            private _score = if ("heat" in _traits) then {2} else {1};
            if (_score > _bestScore) then {
                _bestMagazine = _magazineClass;
                _bestScore = _score;
            };
        };
    } forEach _compatible;
    _bestMagazine
};

private _aoCenter = markerPos _activeMarker;
private _aoSize = markerSize _activeMarker;
private _aoDirection = markerDir _activeMarker;
private _placedPositions = [];
private _spawned = [];

private _resolveSurfacePosition = {
    params ["_candidate"];
    private _xPos = _candidate select 0;
    private _yPos = _candidate select 1;
    private _terrainAsl = getTerrainHeightASL [_xPos, _yPos];
    private _surfaceAsl = _terrainAsl;
    private _blockedByElevatedSurface = false;
    private _hits = lineIntersectsSurfaces [
        [_xPos, _yPos, _terrainAsl + _maximumSurfaceOffset + 10],
        [_xPos, _yPos, _terrainAsl - 1],
        objNull,
        objNull,
        true,
        10,
        "GEOM",
        "NONE"
    ];

    {
        private _hitPosition = _x param [0, []];
        if ((count _hitPosition) >= 3) then {
            private _hitAsl = _hitPosition select 2;
            if (_hitAsl > (_terrainAsl + _maximumSurfaceOffset)) then {
                _blockedByElevatedSurface = true;
            } else {
                if (_hitAsl >= (_terrainAsl - 0.05) && {_hitAsl > _surfaceAsl}) then {
                    _surfaceAsl = _hitAsl;
                };
            };
        };
    } forEach _hits;

    if (_blockedByElevatedSurface) exitWith {[]};
    ASLToATL [_xPos, _yPos, _surfaceAsl + _surfaceClearance]
};

for "_slot" from 1 to _pickupCount do {
    private _weaponClass = toLower (selectRandom _configuredWeapons);
    if !(isClass (configFile >> "CfgWeapons" >> _weaponClass)) then {
        [format ["Battlefield pickup weapon '%1' is not a valid CfgWeapons class.", _weaponClass], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    private _magazineClass = [_weaponClass] call _resolveMagazine;
    if (_magazineClass isEqualTo "") then {
        [format ["Battlefield pickup weapon '%1' has no usable factual compatible magazine.", _weaponClass], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    private _position = [];
    for "_attempt" from 1 to _attemptsPerItem do {
        private _localX = (random 2 - 1) * (_aoSize param [0, 0]);
        private _localY = (random 2 - 1) * (_aoSize param [1, 0]);
        private _candidate = [
            (_aoCenter select 0) + (_localX * cos _aoDirection) + (_localY * sin _aoDirection),
            (_aoCenter select 1) - (_localX * sin _aoDirection) + (_localY * cos _aoDirection),
            0
        ];
        if !(_candidate inArea _activeMarker) then {continue};

        private _emptyPosition = _candidate findEmptyPosition [0, 8, "GroundWeaponHolder_Scripted"];
        if ((count _emptyPosition) < 2) then {continue};
        if (!(_emptyPosition inArea _activeMarker) || {surfaceIsWater _emptyPosition}) then {continue};
        private _surfacePosition = [_emptyPosition] call _resolveSurfacePosition;
        if ((count _surfacePosition) < 3 || {!(_surfacePosition inArea _activeMarker)}) then {continue};
        if ((_placedPositions findIf {_x distance2D _surfacePosition < _minimumSeparation}) >= 0) then {continue};

        _position = _surfacePosition;
        break;
    };

    if ((count _position) < 2) then {
        [format ["Battlefield pickup '%1' could not find a valid AO position after %2 attempts.", _weaponClass, _attemptsPerItem], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    private _holder = createVehicle ["GroundWeaponHolder_Scripted", _position, [], 0, "CAN_COLLIDE"];
    if (isNull _holder) then {
        [format ["Battlefield pickup holder creation failed for '%1'.", _weaponClass], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    _holder setPosATL _position;
    _holder addWeaponCargoGlobal [_weaponClass, 1];
    if (_magazineCount > 0) then {
        _holder addMagazineCargoGlobal [_magazineClass, _magazineCount];
    };
    _placedPositions pushBack _position;
    _spawned pushBack _holder;
    [format [
        "Battlefield pickup spawned: weapon=%1 magazine=%2 worldPos=%3 atlPos=%4",
        _weaponClass,
        _magazineClass,
        getPosWorld _holder,
        getPosATL _holder
    ]] call bn_koth_fnc_common_log;
};

missionNamespace setVariable ["BN_KOTH_battlefieldPickupObjects", _spawned];
[format [
    "Battlefield pickups spawned: %1/%2 holder(s) from %3 configured weapon class(es).",
    count _spawned,
    _pickupCount,
    count _configuredWeapons
]] call bn_koth_fnc_common_log;

count _spawned
