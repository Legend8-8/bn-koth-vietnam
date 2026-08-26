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
private _crossSide = _entitlement getOrDefault ["crossSide", false];
private _crossSideAllowed = _metadata getOrDefault ["crossSideAllowed", false];
private _masteryKills = (_entry getOrDefault ["masteryKills", _entitlement getOrDefault ["masteryKills", 0]]) max 0;
private _masteryRequired = (_metadata getOrDefault ["masteryKillsRequired", 0]) max 0;
private _masteryComplete = _crossSide && {_crossSideAllowed} && {_masteryRequired > 0} && {_masteryKills >= _masteryRequired};

private _canBuy = (_purchasePrice >= 0) && {!_owned} && {_transactionEligible};
private _canRent = (_rentalPrice >= 0) && {!_owned} && {!_rented} && {_transactionEligible};
private _stateLabel = switch (true) do {
    case ((_code isEqualTo "LOCKED_LEVEL") && {_crossSide} && {_crossSideAllowed} && {_masteryRequired > 0}): {
        if (_masteryComplete) then {
            format ["MASTERY COMPLETE · LEVEL %1", _metadata getOrDefault ["minLevel", 1]]
        } else {
            format ["LEVEL %1 · MASTERY %2 / %3 KILLS", _metadata getOrDefault ["minLevel", 1], _masteryKills, _masteryRequired]
        }
    };
    case (_code isEqualTo "LOCKED_LEVEL"): {format ["LOCKED · LEVEL %1", _metadata getOrDefault ["minLevel", 1]]};
    case (_code isEqualTo "LOCKED_MASTERY"): {format ["MASTERY %1 / %2 KILLS", _masteryKills, _masteryRequired]};
    case ((_code isEqualTo "LOCKED_PERK") && {_masteryComplete}): {"MASTERY COMPLETE · PERK REQUIRED"};
    case (_code isEqualTo "LOCKED_PERK"): {"PERK REQUIRED"};
    case (_code in ["LOCKED_SIDE", "CROSS_SIDE_NOT_ALLOWED"]): {"FACTION RESTRICTED"};
    case _owned: {"OWNED"};
    case _rented: {"RENTED"};
    case _masteryComplete: {"MASTERY COMPLETE"};
    case ((_purchasePrice < 0) && {_rentalPrice < 0}): {"ACQUISITION NOT CONFIGURED"};
    case (_code isEqualTo "REQUIRES_ACQUISITION"): {"AVAILABLE TO ACQUIRE"};
    default {"AVAILABLE"};
};

createHashMapFromArray [
    ["code", _code], ["stateLabel", _stateLabel], ["owned", _owned], ["rented", _rented],
    ["purchasePrice", _purchasePrice], ["rentalPrice", _rentalPrice],
    ["crossSide", _crossSide], ["crossSideAllowed", _crossSideAllowed],
    ["masteryKills", _masteryKills], ["masteryRequired", _masteryRequired], ["masteryComplete", _masteryComplete],
    ["canBuy", _canBuy], ["canRent", _canRent],
    ["canAffordPurchase", _canBuy && {_cash >= _purchasePrice}],
    ["canAffordRental", _canRent && {_cash >= _rentalPrice}],
    ["blocking", _code in ["LOCKED_LEVEL", "LOCKED_MASTERY", "LOCKED_PERK", "LOCKED_SIDE", "CROSS_SIDE_NOT_ALLOWED"]]
]
