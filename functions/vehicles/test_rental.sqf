/*
    File: test_rental.sqf
    Author: Legend
    Description: Focused static/pure contract checks for the single-step
        one-life vehicle rental state. This file is not registered as a
        runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/
private _failures=[];
private _assert={params["_condition","_message"];if (!_condition) then {_failures pushBack _message}};
[isServer,"Rental tests require server execution."] call _assert;
private _cfg=missionConfigFile >> "CfgBnKothVehicles";
[(getNumber (_cfg >> "rentalCooldownSeconds"))>=0,"Cooldown config missing."] call _assert;
[(getNumber (_cfg >> "rentedWreckCleanupSeconds"))>=0,"Wreck cleanup config missing."] call _assert;
[(getNumber (_cfg >> "rentedAbandonmentSeconds"))>0,"Abandonment config missing."] call _assert;
[(getNumber (_cfg >> "rentedOwnerDisconnectCleanupSeconds"))>0,"Owner disconnect config missing."] call _assert;
[(getNumber (_cfg >> "paidSpawnClearanceMeters"))>0,"Spawn clearance config missing."] call _assert;
[(getNumber (_cfg >> "paidFallbackSpawnRadiusMeters"))>0,"Fallback radius config missing."] call _assert;

private _active=missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",objNull];
private _cooldowns=missionNamespace getVariable ["BN_KOTH_vehicleRentalCooldowns",objNull];
private _reservations=missionNamespace getVariable ["BN_KOTH_vehiclePaidPadReservations",objNull];
private _pads=missionNamespace getVariable ["BN_KOTH_vehiclePaidPads",objNull];
[isNil {missionNamespace getVariable "BN_KOTH_vehiclePendingRentals"},"Pending rental state must no longer exist; RENT is a single-step transaction."] call _assert;
[_active isEqualType createHashMap,"Active rental map must be initialized by fn_initServer."] call _assert;
[_cooldowns isEqualType createHashMap,"Rental cooldown map must be initialized by fn_initServer."] call _assert;
[_reservations isEqualType createHashMap,"Paid pad reservation map must be initialized by fn_initServer."] call _assert;
[_pads isEqualType [],"Paid pad cache must be initialized by fn_initServer."] call _assert;
if (_pads isEqualType []) then {
    {
        [(_x getOrDefault ["category",""]) in ["GROUND","AIR","SEA"],"Cached pad must own a valid category."] call _assert;
        [(_x getOrDefault ["side",""]) in ["EAST","WEST"],"Cached pad must own a valid side."] call _assert;
    } forEach _pads;
};

[isNil {missionNamespace getVariable "BN_KOTH_ownedVehicles"},"Permanent ownedVehicles state must not exist."] call _assert;
[isNil {missionNamespace getVariable "BN_KOTH_vehiclePurchases"},"Permanent vehicle purchase state must not exist."] call _assert;

// Pre-commit rollback proof: a vehicle never registered in BN_KOTH_vehicleActiveRentals must not be
// treated as a real rental life ending, no matter how its Deleted/Killed EH invokes fn_endRentalLife.
private _probeUid = "BN_KOTH_TEST_ROLLBACK_PROBE";
private _cooldownBefore = (missionNamespace getVariable ["BN_KOTH_vehicleRentalCooldowns",createHashMap]) getOrDefault [_probeUid,-1];
[isNil {(missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",createHashMap]) get _probeUid},"Test setup: probe UID must not already own an active-rental entry."] call _assert;
private _probeVehicle = "Land_vn_helipadsquare_f" createVehicle [0,0,0];
private _endResult = [_probeUid,_probeVehicle,"TEST_ROLLBACK"] call bn_koth_fnc_vehicles_endRentalLife;
deleteVehicle _probeVehicle;
[!_endResult,"endRentalLife must reject a vehicle with no matching active-rental record (pre-commit rollback safety)."] call _assert;
[((missionNamespace getVariable ["BN_KOTH_vehicleRentalCooldowns",createHashMap]) getOrDefault [_probeUid,-1]) isEqualTo _cooldownBefore,"A rejected endRentalLife call must never start/change a cooldown for that UID."] call _assert;
[isNil {(missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",createHashMap]) get _probeUid},"A rejected endRentalLife call must never create/leave an active-rental entry."] call _assert;
_failures
