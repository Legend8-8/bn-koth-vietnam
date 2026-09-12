/*
    File: test_vehicleCapabilities.sqf
    Author: Legend
    Description: Focused checks that vehicle capability requires an actual resolved Eden role.
    Execution: Debug console after mission initialization
    Returns: Failure messages <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_name", "_condition"];
    if (!_condition) then {_failures pushBack _name};
};

private _suffix = str floor (random 1000000);
private _westGround = format ["BN_KOTH_test_west_ground_%1", _suffix];
private _eastAir = format ["BN_KOTH_test_east_air_%1", _suffix];
createMarkerLocal [_westGround, [10, 10, 0]];
_westGround setMarkerShapeLocal "ICON";
createMarkerLocal [_eastAir, [20, 20, 0]];
_eastAir setMarkerShapeLocal "ICON";

private _data = createHashMapFromArray [
    ["id", "test"],
    ["westPaidGround_spawnpoint", _westGround],
    ["westFreeGround_spawnpoint", "BN_KOTH_missing_free_ground"],
    ["westPaidAir_spawnpoint", "BN_KOTH_missing_west_air"],
    ["westFreeAir_spawnpoint", "BN_KOTH_missing_west_free_air"],
    ["westPaidSea_spawnpoint", "BN_KOTH_missing_west_sea"],
    ["westFreeSea_spawnpoint", "BN_KOTH_missing_west_free_sea"],
    ["westCommand_spawnpoint", "BN_KOTH_missing_west_command"],
    ["eastPaidGround_spawnpoint", "BN_KOTH_missing_east_ground"],
    ["eastFreeGround_spawnpoint", "BN_KOTH_missing_east_free_ground"],
    ["eastPaidAir_spawnpoint", _eastAir],
    ["eastFreeAir_spawnpoint", "BN_KOTH_missing_east_free_air"],
    ["eastPaidSea_spawnpoint", "BN_KOTH_missing_east_sea"],
    ["eastFreeSea_spawnpoint", "BN_KOTH_missing_east_free_sea"],
    ["eastCommand_spawnpoint", "BN_KOTH_missing_east_command"]
];

private _capabilities = [_data] call bn_koth_fnc_zone_getVehicleCapabilities;
private _sides = _capabilities getOrDefault ["sides", createHashMap];
private _westFamilies = ((_sides get "WEST") get "families");
private _eastFamilies = ((_sides get "EAST") get "families");

["Existing WEST paid ground marker enables paid ground", ((_westFamilies get "GROUND") get "paid")] call _check;
["Derived missing WEST free ground name grants nothing", !(((_westFamilies get "GROUND") get "free"))] call _check;
["WEST air remains disabled", !(((_westFamilies get "ROTARY") get "any"))] call _check;
["Existing EAST paid air enables rotary Store capability", ((_eastFamilies get "ROTARY") get "paid")] call _check;
["Shared paid air enables fixed-wing Store capability", ((_eastFamilies get "FIXED_WING") get "paid")] call _check;
["Missing command role disables command", !(((_eastFamilies get "COMMAND") get "spawn"))] call _check;
["Missing optional sea roles disable sea only", !(((_eastFamilies get "SEA") get "any"))] call _check;

deleteMarkerLocal _westGround;
deleteMarkerLocal _eastAir;

diag_log format ["[BN_KOTH_TEST] Location vehicle capabilities: %1 failure(s): %2", count _failures, _failures];
_failures
