/*
    File: fn_getLocationData.sqf
    Author: tylervip
    Description: Resolves the canonical runtime data for a configured KOTH location.
    Execution: Server/Client
    Parameters:
        0: Location ID <STRING>
    Returns:
        HashMap with canonical location metadata and resolved runtime names <HASHMAP>
    Public: Yes
*/

params [["_locationId", "", [""]]];

if (_locationId isEqualTo "") exitWith {createHashMap};

private _cfg = missionConfigFile >> "CfgBnKothLocations" >> _locationId;
if !(isClass _cfg) exitWith {createHashMap};

private _resolveRoleValue = {
    params ["_cfgRef", "_roleKey", "_defaultValue"];

    private _configuredValue = getText (_cfgRef >> _roleKey);
    if !(_configuredValue isEqualTo "") exitWith {_configuredValue};

    _defaultValue
};

private _locationData = createHashMap;
private _derivedZoneMarker = format ["%1_zone", _locationId];
private _derivedWestRespawn = format ["%1_respawn_west", _locationId];
private _derivedEastRespawn = format ["%1_respawn_east", _locationId];
private _derivedWestBaseZone = format ["%1_west_base_zone", _locationId];
private _derivedEastBaseZone = format ["%1_east_base_zone", _locationId];
private _derivedWestCommandSpawn = format ["%1_west_command_spawnpoint", _locationId];
private _derivedEastCommandSpawn = format ["%1_east_command_spawnpoint", _locationId];
private _derivedWestCommandBoard = format ["%1_west_command_mapboard", _locationId];
private _derivedEastCommandBoard = format ["%1_east_command_mapboard", _locationId];
private _derivedWestPaidGround = format ["%1_west_paid_ground_spawnpoint", _locationId];
private _derivedWestPaidAir = format ["%1_west_paid_air_spawnpoint", _locationId];
private _derivedWestPaidSea = format ["%1_west_paid_sea_spawnpoint", _locationId];
private _derivedWestFreeGround = format ["%1_west_free_ground_spawnpoint", _locationId];
private _derivedWestFreeAir = format ["%1_west_free_air_spawnpoint", _locationId];
private _derivedWestFreeSea = format ["%1_west_free_sea_spawnpoint", _locationId];
private _derivedEastPaidGround = format ["%1_east_paid_ground_spawnpoint", _locationId];
private _derivedEastPaidAir = format ["%1_east_paid_air_spawnpoint", _locationId];
private _derivedEastPaidSea = format ["%1_east_paid_sea_spawnpoint", _locationId];
private _derivedEastFreeGround = format ["%1_east_free_ground_spawnpoint", _locationId];
private _derivedEastFreeAir = format ["%1_east_free_air_spawnpoint", _locationId];
private _derivedEastFreeSea = format ["%1_east_free_sea_spawnpoint", _locationId];

_locationData set ["id", _locationId];
_locationData set ["displayName", getText (_cfg >> "displayName")];
_locationData set ["description", getText (_cfg >> "description")];
_locationData set ["image", getText (_cfg >> "image")];

_locationData set ["zoneMarker", [_cfg, "zoneMarker", _derivedZoneMarker] call _resolveRoleValue];
_locationData set ["respawnWestMarker", [_cfg, "respawnWestMarker", _derivedWestRespawn] call _resolveRoleValue];
_locationData set ["respawnEastMarker", [_cfg, "respawnEastMarker", _derivedEastRespawn] call _resolveRoleValue];
_locationData set ["westBaseZoneMarker", [_cfg, "westBaseZoneMarker", _derivedWestBaseZone] call _resolveRoleValue];
_locationData set ["eastBaseZoneMarker", [_cfg, "eastBaseZoneMarker", _derivedEastBaseZone] call _resolveRoleValue];
_locationData set ["westCommand_spawnpoint", [_cfg, "westCommand_spawnpoint", _derivedWestCommandSpawn] call _resolveRoleValue];
_locationData set ["eastCommand_spawnpoint", [_cfg, "eastCommand_spawnpoint", _derivedEastCommandSpawn] call _resolveRoleValue];
_locationData set ["westCommand_mapboard", [_cfg, "westCommand_mapboard", _derivedWestCommandBoard] call _resolveRoleValue];
_locationData set ["eastCommand_mapboard", [_cfg, "eastCommand_mapboard", _derivedEastCommandBoard] call _resolveRoleValue];
_locationData set ["westPaidGround_spawnpoint", [_cfg, "westPaidGround_spawnpoint", _derivedWestPaidGround] call _resolveRoleValue];
_locationData set ["westPaidAir_spawnpoint", [_cfg, "westPaidAir_spawnpoint", _derivedWestPaidAir] call _resolveRoleValue];
_locationData set ["westPaidSea_spawnpoint", [_cfg, "westPaidSea_spawnpoint", _derivedWestPaidSea] call _resolveRoleValue];
_locationData set ["westFreeGround_spawnpoint", [_cfg, "westFreeGround_spawnpoint", _derivedWestFreeGround] call _resolveRoleValue];
_locationData set ["westFreeAir_spawnpoint", [_cfg, "westFreeAir_spawnpoint", _derivedWestFreeAir] call _resolveRoleValue];
_locationData set ["westFreeSea_spawnpoint", [_cfg, "westFreeSea_spawnpoint", _derivedWestFreeSea] call _resolveRoleValue];
_locationData set ["eastPaidGround_spawnpoint", [_cfg, "eastPaidGround_spawnpoint", _derivedEastPaidGround] call _resolveRoleValue];
_locationData set ["eastPaidAir_spawnpoint", [_cfg, "eastPaidAir_spawnpoint", _derivedEastPaidAir] call _resolveRoleValue];
_locationData set ["eastPaidSea_spawnpoint", [_cfg, "eastPaidSea_spawnpoint", _derivedEastPaidSea] call _resolveRoleValue];
_locationData set ["eastFreeGround_spawnpoint", [_cfg, "eastFreeGround_spawnpoint", _derivedEastFreeGround] call _resolveRoleValue];
_locationData set ["eastFreeAir_spawnpoint", [_cfg, "eastFreeAir_spawnpoint", _derivedEastFreeAir] call _resolveRoleValue];
_locationData set ["eastFreeSea_spawnpoint", [_cfg, "eastFreeSea_spawnpoint", _derivedEastFreeSea] call _resolveRoleValue];

_locationData
