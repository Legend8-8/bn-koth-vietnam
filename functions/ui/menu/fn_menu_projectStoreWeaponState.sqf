/*
    File: fn_menu_projectStoreWeaponState.sqf
    Author: Legend
    Description: Projects cached Store weapon facts into client presentation.
        It does not decide entitlement or mutate progression.
    Execution: Any
    Parameters:
        0: Store entry <HASHMAP>
        1: Cached player cash <NUMBER>
    Returns: Store presentation state <HASHMAP>
    Public: No
*/

params [
    ["_entry", createHashMap, [createHashMap]],
    ["_cash", 0, [0]]
];

private _metadata = _entry getOrDefault ["metadata", createHashMap];
private _entitlement = _entry getOrDefault ["entitlement", createHashMap];
private _code = _entitlement getOrDefault ["code", "LOCKED_STATE"];
private _accessType = toUpper (_entitlement getOrDefault ["accessType", "NONE"]);
private _purchasePrice = _metadata getOrDefault ["purchasePrice", -1];
private _rentalPrice = _metadata getOrDefault ["rentalPrice", -1];
private _owned = _entry getOrDefault ["owned", _accessType isEqualTo "OWNED"];
private _rented = _entry getOrDefault ["rented", _accessType isEqualTo "RENTED"];
private _transactionEligible = _code in ["REQUIRES_ACQUISITION", "ENTITLED"];

private _canBuy = (_purchasePrice >= 0) && {!_owned} && {_transactionEligible};
private _canRent = (_rentalPrice >= 0) && {!_owned} && {!_rented} && {_transactionEligible};
private _stateLabel = switch (true) do {
    case (_code isEqualTo "LOCKED_LEVEL"): {format ["LOCKED - LEVEL %1", _metadata getOrDefault ["minLevel", 1]]};
    case (_code isEqualTo "LOCKED_MASTERY"): {format ["MASTERY %1 / %2", _entry getOrDefault ["masteryKills", _entitlement getOrDefault ["masteryKills", 0]], _metadata getOrDefault ["masteryKillsRequired", 0]]};
    case (_code isEqualTo "LOCKED_PERK"): {"LOCKED - PERK"};
    case (_code in ["LOCKED_SIDE", "CROSS_SIDE_NOT_ALLOWED"]): {"UNAVAILABLE FOR YOUR FACTION"};
    case _owned: {"OWNED"};
    case _rented: {"RENTED"};
    case ((_purchasePrice < 0) && {_rentalPrice < 0}): {"ACQUISITION NOT CONFIGURED"};
    case (_code isEqualTo "REQUIRES_ACQUISITION"): {"AVAILABLE TO ACQUIRE"};
    default {"AVAILABLE"};
};

createHashMapFromArray [
    ["code", _code], ["stateLabel", _stateLabel], ["owned", _owned], ["rented", _rented],
    ["purchasePrice", _purchasePrice], ["rentalPrice", _rentalPrice],
    ["canBuy", _canBuy], ["canRent", _canRent],
    ["canAffordPurchase", _canBuy && {_cash >= _purchasePrice}],
    ["canAffordRental", _canRent && {_cash >= _rentalPrice}]
]
