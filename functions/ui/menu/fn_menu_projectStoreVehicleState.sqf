/*
    File: fn_menu_projectStoreVehicleState.sqf
    Author: Legend
    Description: Projects curated vehicle eligibility into client-only Store
        display state. It grants no ownership and submits no transaction.
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
private _stateLabel = switch (_code) do {
    case "ELIGIBLE": {"ELIGIBLE - REQUISITION COMING SOON"};
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
    ["rentalPrice", _metadata getOrDefault ["rentalPrice", -1]],
    ["actionsAvailable", false]
]
