/*
    File: fn_menu_projectStoreVehicleState.sqf
    Author: Legend
    Description: Projects curated vehicle eligibility and targeted transient
        rental state into client-only Store display state.
    Execution: Any
    Parameters:
        0: Store vehicle entry <HASHMAP>
    Returns: Vehicle Store presentation state <HASHMAP>
    Public: No
*/

params [["_entry", createHashMap, [createHashMap]]];

private _metadata = _entry getOrDefault ["metadata", createHashMap];
private _eligibility = _entry getOrDefault ["eligibility", createHashMap];
private _code = _eligibility getOrDefault ["code", "LOCKED_STATE"];
private _vehicleClass = _entry getOrDefault ["vehicleClass", ""];
private _rentalState = missionNamespace getVariable ["BN_KOTH_vehicleRentalStateLocal", createHashMap];
if !(_rentalState isEqualType createHashMap) then {_rentalState = createHashMap};
private _active = (_rentalState getOrDefault ["activeClass", ""]) isEqualTo _vehicleClass;
private _anyActive = !((_rentalState getOrDefault ["activeClass", ""]) isEqualTo "");
private _cooldown = _rentalState getOrDefault ["cooldownRemaining", 0];
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
private _cash = if (_progression isEqualType createHashMap) then {_progression getOrDefault ["cash", 0]} else {0};
private _rentalPrice = _metadata getOrDefault ["rentalPrice", -1];
private _stateLabel = switch (_code) do {
    case "ELIGIBLE": {
        if (_active) then {"VEHICLE ACTIVE"} else {
            if (_anyActive) then {"ANOTHER VEHICLE IS ACTIVE"} else {
                if (_cooldown > 0) then {format ["AVAILABLE IN %1 SECONDS", _cooldown]} else {if (_rentalPrice > _cash) then {"INSUFFICIENT CASH"} else {"AVAILABLE TO RENT"}}
            }
        }
    };
    case "LOCKED_SIDE": {"UNAVAILABLE FOR YOUR FACTION"};
    case "LOCKED_LEVEL": {format ["LOCKED - LEVEL %1", _metadata getOrDefault ["minLevel", 1]]};
    case "LOCKED_PERK": {"LOCKED - PERK"};
    default {"UNAVAILABLE"};
};

createHashMapFromArray [
    ["code", _code],
    ["eligible", _eligibility getOrDefault ["eligible", false]],
    ["stateLabel", _stateLabel],
    ["purchasePrice", _metadata getOrDefault ["purchasePrice", -1]],
    ["rentalPrice", _rentalPrice],
    ["active", _active],
    ["cooldownRemaining", _cooldown],
    ["canRent", (_code isEqualTo "ELIGIBLE") && {!_anyActive} && {_cooldown <= 0}],
    ["actionsAvailable", _code isEqualTo "ELIGIBLE"]
]
