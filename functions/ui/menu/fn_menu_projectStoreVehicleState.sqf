/*
    File: fn_menu_projectStoreVehicleState.sqf
    Author: Legend
    Description: Projects server-supplied personal vehicle state and local
        config metadata into aggregate Store presentation. It grants no
        entitlement and does not replace authoritative transaction validation.
    Execution: Any
    Parameters: 0: Store vehicle entry <HASHMAP>
    Returns: Vehicle Store presentation state <HASHMAP>
    Public: No
*/
params [["_entry", createHashMap, [createHashMap]]];

private _metadata = _entry getOrDefault ["metadata", createHashMap];
private _eligibility = _entry getOrDefault ["eligibility", createHashMap];
private _loadout = _entry getOrDefault ["loadoutEligibility", createHashMap];
private _rentalLoadout = _entry getOrDefault ["rentalEligibility", createHashMap];
private _vehicleClass = _entry getOrDefault ["vehicleClass", ""];
private _personal = missionNamespace getVariable ["BN_KOTH_vehiclePersonalStateLocal", createHashMap];
if !(_personal isEqualType createHashMap) then {_personal = createHashMap};
private _active = (_personal getOrDefault ["activeClass", ""]) isEqualTo _vehicleClass;
private _anyActive = !((_personal getOrDefault ["activeClass", ""]) isEqualTo "");
private _cooldown = ceil ((_personal getOrDefault ["cooldownRemaining", 0]) max 0);
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
private _cash = if (_progression isEqualType createHashMap) then {_progression getOrDefault ["cash", 0]} else {0};
private _owned = _loadout getOrDefault ["owned", false];
private _unlocked = _loadout getOrDefault ["unlocked", false];
private _purchaseEligible = _loadout getOrDefault ["purchaseEligible", false];
private _rentalUnlocked = _rentalLoadout getOrDefault ["unlocked", false];
private _rentable = _metadata getOrDefault ["rentable", false];
private _base = _metadata getOrDefault ["baseLoadout", false];
private _purchasePrice = _metadata getOrDefault ["purchasePrice", -1];
private _rentalPrice = _metadata getOrDefault ["rentalPrice", -1];
private _replacementPrice = _metadata getOrDefault ["replacementPrice", -1];
private _side = toUpper (_entry getOrDefault ["playerSide", _eligibility getOrDefault ["sideToken", ""]]);
private _level = (_entry getOrDefault ["playerLevel", 1]) max 1;
private _activePerks = (_entry getOrDefault ["playerPerks", []]) apply {toLower _x};
private _familyDisplayName = _entry getOrDefault ["familyDisplayName", _entry getOrDefault ["displayName", "VEHICLE FAMILY"]];
private _requiredDisplayName = _entry getOrDefault ["requiredLoadoutDisplayName", ""];

private _sideReady = !(_side isEqualTo "") && {_side in (_metadata getOrDefault ["allowedSides", []])};
private _levelReady = _level >= (_metadata getOrDefault ["minLevel", 1]);
private _requiredPerks = _metadata getOrDefault ["requiredPerks", []];
private _missingPerkIds = _requiredPerks select {!((toLower _x) in _activePerks)};
private _missingPerks = _missingPerkIds apply {
    private _perk = [toLower _x] call bn_koth_fnc_progression_perks_getConfig;
    private _name = _perk getOrDefault ["displayName", ""];
    if (_name isEqualTo "") then {"REQUIRED PERK"} else {toUpper _name}
};
private _perksReady = (count _missingPerkIds) isEqualTo 0;
private _progressionReady = _sideReady && {_levelReady} && {_perksReady};
private _canTransact = _progressionReady && {!_anyActive} && {_cooldown <= 0};
private _canPurchase = _canTransact && {_purchaseEligible} && {_purchasePrice > 0} && {_cash >= _purchasePrice};
private _canSpawn = _canTransact && {_owned} && {_unlocked} && {_replacementPrice > 0} && {_cash >= _replacementPrice};
private _canRent = _canTransact && {_rentable} && {_rentalUnlocked} && {_rentalPrice > 0} && {_cash >= _rentalPrice};

private _missingMastery = if (_owned) then {
    _loadout getOrDefault ["missingMastery", createHashMap]
} else {
    _rentalLoadout getOrDefault ["missingMastery", createHashMap]
};
if !(_missingMastery isEqualType createHashMap) then {_missingMastery = createHashMap};
private _masteryKeys = keys _missingMastery;
_masteryKeys sort true;
private _masteryReasons = _masteryKeys apply {
    private _progress = _missingMastery get _x;
    private _label = switch (_x) do {
        case "infantryKills": {"INFANTRY KILLS"};
        case "insertions": {"INSERTIONS"};
        case "passengersDelivered": {"PASSENGERS DELIVERED"};
        case "transportDistance": {"TRANSPORT DISTANCE"};
        default {"MASTERY"};
    };
    format ["%1 %2/%3", _label, _progress select 0, _progress select 1]
};

private _lockReasons = [];
if (!_sideReady) then {
    private _allowed = _metadata getOrDefault ["allowedSides", []];
    _lockReasons pushBack (if (_side isEqualTo "") then {"PLAYER STATE NOT READY"} else {format ["%1 FACTION ONLY", _allowed joinString " / "]});
};
if (!_levelReady) then {_lockReasons pushBack format ["LEVEL %1", _metadata getOrDefault ["minLevel", 1]]};
if (!_base && {!_owned}) then {_lockReasons pushBack format ["PURCHASE %1", toUpper _familyDisplayName]};
if (!_base && {!_unlocked} && {!(_requiredDisplayName isEqualTo "")} && {_owned || {!(_requiredDisplayName isEqualTo _familyDisplayName)}}) then {
    _lockReasons pushBack format ["REQUIRED LOADOUT %1", toUpper _requiredDisplayName];
};
_lockReasons append _masteryReasons;
{_lockReasons pushBack format ["PERK %1", _x]} forEach _missingPerks;
if (_anyActive && {!_active}) then {_lockReasons pushBack "PERSONAL VEHICLE ACTIVE"};
if (_cooldown > 0) then {_lockReasons pushBack format ["COOLDOWN %1S", _cooldown]};

private _cashBlocks = false;
if (!_active) then {
    if (_owned && {_unlocked} && {_replacementPrice > 0}) then {_cashBlocks = _cash < _replacementPrice};
    if (!_owned && {_base}) then {
        private _canAffordPurchase = _purchasePrice > 0 && {_cash >= _purchasePrice};
        private _canAffordRent = _rentable && {_rentalPrice > 0} && {_cash >= _rentalPrice};
        _cashBlocks = !_canAffordPurchase && {!_canAffordRent};
    };
    if (!_owned && {!_base} && {_rentable} && {_rentalPrice > 0}) then {_cashBlocks = _cash < _rentalPrice};
};
if (_cashBlocks) then {_lockReasons pushBack "INSUFFICIENT CASH"};
if (!_base && {!_owned} && {!_rentable}) then {_lockReasons pushBack "MASTERY EXCLUSIVE"};

private _available = _canPurchase || {_canSpawn} || {_canRent} || {_active};
private _blocking = !_available;
private _stateLabel = if (_active) then {
    "VEHICLE ACTIVE"
} else {
    if (_canPurchase && {_canRent}) then {"AVAILABLE TO PURCHASE OR RENT"} else {
        if (_canPurchase) then {"AVAILABLE TO PURCHASE"} else {
            if (_canRent) then {"AVAILABLE TO RENT"} else {
                if (_canSpawn) then {"REPLACEMENT AVAILABLE"} else {
                    if (_owned) then {"OWNED"} else {"LOCKED"}
                }
            }
        }
    }
};

createHashMapFromArray [
    ["code", _eligibility getOrDefault ["code", "LOCKED_STATE"]],
    ["stateLabel", _stateLabel], ["lockReasons", _lockReasons], ["lockSummary", _lockReasons joinString " • "], ["blocking", _blocking],
    ["owned", _owned], ["unlocked", _unlocked], ["purchasePrice", _purchasePrice], ["rentalPrice", _rentalPrice], ["replacementPrice", _replacementPrice],
    ["active", _active], ["anyActive", _anyActive], ["cooldownRemaining", _cooldown],
    ["canPurchase", _canPurchase], ["canSpawn", _canSpawn], ["canRent", _canRent], ["rentable", _rentable], ["rentalUnlocked", _rentalUnlocked],
    ["missingPerks", _missingPerks], ["missingMastery", _loadout getOrDefault ["missingMastery", createHashMap]],
    ["missingRentalMastery", _rentalLoadout getOrDefault ["missingMastery", createHashMap]],
    ["baseLoadout", _base], ["familyDisplayName", _familyDisplayName], ["requiredLoadoutDisplayName", _requiredDisplayName], ["cash", _cash]
]
