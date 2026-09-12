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
private _allowedSides = _metadata getOrDefault ["allowedSides", []];
if !(_allowedSides isEqualType []) then {_allowedSides = []};
private _playableSides = (_allowedSides apply {toUpper _x}) arrayIntersect ["WEST", "EAST"];
private _requiredSide = if ((count _playableSides) isEqualTo 1) then {_playableSides select 0} else {""};
private _playerLevel = (_entitlement getOrDefault ["playerLevel", 1]) max 1;
private _minLevel = (_metadata getOrDefault ["minLevel", 1]) max 1;
private _missingPerks = _entitlement getOrDefault ["missingPerks", []];
if !(_missingPerks isEqualType []) then {_missingPerks = []};

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

private _detailStatus = "UNAVAILABLE";
private _detailLines = [];
switch (true) do {
    case (_code in ["LOCKED_SIDE", "CROSS_SIDE_NOT_ALLOWED"]): {
        _detailStatus = if !(_requiredSide isEqualTo "") then {format ["AVAILABLE ON %1 ONLY", _requiredSide]} else {"FACTION RESTRICTED"};
    };
    case (_code isEqualTo "LOCKED_LEVEL"): {
        if (_crossSide && {_crossSideAllowed} && {_masteryRequired > 0} && {!_masteryComplete} && {!(_requiredSide isEqualTo "")}) then {
            _detailStatus = "LOCKED";
            _detailLines = [
                format ["Reach Level %1", _minLevel],
                format ["Then get %1 kills with this weapon on %2", _masteryRequired, _requiredSide],
                format ["%1 / %2 kills", _masteryKills, _masteryRequired]
            ];
        } else {
            _detailStatus = format ["LEVEL %1 REQUIRED", _minLevel];
            _detailLines = [format ["You are Level %1", _playerLevel]];
        };
    };
    case (_code isEqualTo "LOCKED_MASTERY"): {
        _detailStatus = if !(_requiredSide isEqualTo "") then {format ["LOCKED — USE ON %1 FIRST", _requiredSide]} else {"LOCKED"};
        _detailLines = [
            if !(_requiredSide isEqualTo "") then {
                format ["Get %1 kills with this weapon on %2", _masteryRequired, _requiredSide]
            } else {
                format ["Get %1 kills with this weapon", _masteryRequired]
            },
            format ["%1 / %2 kills", _masteryKills, _masteryRequired]
        ];
    };
    case (_code isEqualTo "LOCKED_PERK"): {
        private _perkLabels = _missingPerks apply {toUpper _x};
        _detailStatus = if ((count _perkLabels) isEqualTo 1) then {format ["%1 PERK REQUIRED", _perkLabels select 0]} else {"PERKS REQUIRED"};
        if ((count _perkLabels) > 1) then {_detailLines = [format ["Activate %1", _perkLabels joinString " / "]]};
    };
    case _owned: {_detailStatus = "OWNED"};
    case _rented: {_detailStatus = "RENTED FOR THIS SERVER SESSION"};
    case (_code isEqualTo "REQUIRES_ACQUISITION"): {_detailStatus = "AVAILABLE TO ACQUIRE"};
    case (_code in ["ENTITLED", "ENTITLED_UNCONTROLLED"]): {_detailStatus = "AVAILABLE"};
    case (_code isEqualTo "LOCKED_STATE"): {_detailStatus = "UNAVAILABLE"};
    default {_detailStatus = if (_entitlement getOrDefault ["entitled", false]) then {"AVAILABLE"} else {"LOCKED"}};
};

createHashMapFromArray [
    ["code", _code], ["stateLabel", _stateLabel], ["owned", _owned], ["rented", _rented],
    ["purchasePrice", _purchasePrice], ["rentalPrice", _rentalPrice],
    ["crossSide", _crossSide], ["crossSideAllowed", _crossSideAllowed],
    ["masteryKills", _masteryKills], ["masteryRequired", _masteryRequired], ["masteryComplete", _masteryComplete],
    ["canBuy", _canBuy], ["canRent", _canRent],
    ["canAffordPurchase", _canBuy && {_cash >= _purchasePrice}],
    ["canAffordRental", _canRent && {_cash >= _rentalPrice}],
    ["blocking", _code in ["LOCKED_LEVEL", "LOCKED_MASTERY", "LOCKED_PERK", "LOCKED_SIDE", "CROSS_SIDE_NOT_ALLOWED"]],
    ["detailStatus", _detailStatus], ["detailLines", _detailLines], ["requiredSide", _requiredSide]
]
