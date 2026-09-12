/*
    File: fn_evaluateRules.sqf
    Author: Legend
    Description: Pure purchase/rental transaction evaluator. It consumes an
        already authoritative entitlement result and returns the complete next
        acquisition state without reading or mutating mission state.
    Execution: Any
    Parameters:
        0: Operation token (PURCHASE or RENT) <STRING>
        1: Player UID <STRING>
        2: Requested weapon classname <STRING>
        3: Player progression state <HASHMAP>
        4: Canonical weapon metadata <HASHMAP>
        5: Authoritative/shared entitlement result <HASHMAP>
    Returns:
        Structured acquisition result <HASHMAP>
    Public: No
*/

params [
    ["_operation", "", [""]],
    ["_uid", "", [""]],
    ["_weaponClass", "", [""]],
    ["_progression", createHashMap, [createHashMap]],
    ["_metadata", createHashMap, [createHashMap]],
    ["_entitlement", createHashMap, [createHashMap]]
];

_operation = toUpper _operation;
private _requestedClass = toLower _weaponClass;
private _canonicalClass = toLower (_metadata getOrDefault ["canonicalClass", ""]);

private _finish = {
    params ["_success", "_code", "_message", ["_extra", createHashMap, [createHashMap]]];
    private _result = createHashMapFromArray [
        ["success", _success],
        ["code", _code],
        ["message", _message],
        ["uid", _uid],
        ["operation", _operation],
        ["requestedClass", _requestedClass],
        ["canonicalClass", _canonicalClass],
        ["committed", false],
        ["charged", 0]
    ];
    {_result set [_x, _extra get _x]} forEach (keys _extra);
    _result
};

if !(_operation in ["PURCHASE", "RENT"]) exitWith {
    [false, "INVALID_OPERATION", "Weapon acquisition operation is invalid."] call _finish
};
if (_uid isEqualTo "") exitWith {
    [false, "INVALID_UID", "Weapon acquisition requires a registered player UID."] call _finish
};
if (_requestedClass isEqualTo "" || {_canonicalClass isEqualTo ""}) exitWith {
    [false, "INVALID_WEAPON", "Weapon acquisition requires valid canonical metadata."] call _finish
};
if !(_metadata getOrDefault ["success", false]) exitWith {
    [false, _metadata getOrDefault ["code", "INVALID_METADATA"], "Weapon metadata lookup failed."] call _finish
};

private _entitlementCode = _entitlement getOrDefault ["code", "ERR_ENTITLEMENT"];
if (_entitlementCode in ["LOCKED_SIDE", "CROSS_SIDE_NOT_ALLOWED", "LOCKED_LEVEL", "LOCKED_MASTERY", "LOCKED_PERK"]) exitWith {
    [false, _entitlementCode, _entitlement getOrDefault ["message", "Weapon entitlement is locked."]] call _finish
};
if !(_entitlement getOrDefault ["success", false]) exitWith {
    [false, _entitlementCode, _entitlement getOrDefault ["message", "Weapon entitlement evaluation failed."]] call _finish
};

private _ownedWeapons = _progression getOrDefault ["ownedWeapons", []];
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};
_ownedWeapons = +_ownedWeapons;
private _rentedWeapons = _progression getOrDefault ["rentedWeapons", []];
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};
_rentedWeapons = +_rentedWeapons;
_ownedWeapons = _ownedWeapons apply {toLower _x};
_rentedWeapons = _rentedWeapons apply {toLower _x};

private _isOwned = _canonicalClass in _ownedWeapons;
private _isRented = _canonicalClass in _rentedWeapons;
private _cash = _progression getOrDefault ["cash", -1];
if !(_cash isEqualType 0 && {finite _cash} && {_cash >= 0}) exitWith {
    [false, "CASH_UNINITIALIZED", "Authoritative player cash is unavailable."] call _finish
};

if (_isOwned) exitWith {
    [true, "ALREADY_OWNED", "Weapon is already permanently owned.", createHashMapFromArray [
        ["cash", _cash], ["owned", true], ["rented", _isRented]
    ]] call _finish
};
if (_operation isEqualTo "RENT" && {_isRented}) exitWith {
    [true, "ALREADY_RENTED", "Weapon rental is already active for this server session.", createHashMapFromArray [
        ["cash", _cash], ["owned", false], ["rented", true]
    ]] call _finish
};

private _priceKey = if (_operation isEqualTo "PURCHASE") then {"purchasePrice"} else {"rentalPrice"};
private _price = _metadata getOrDefault [_priceKey, -1];
if !(_price isEqualType 0 && {finite _price} && {_price >= 0}) exitWith {
    private _code = if (_operation isEqualTo "PURCHASE") then {"PURCHASE_NOT_CONFIGURED"} else {"RENTAL_NOT_CONFIGURED"};
    [false, _code, format ["Weapon %1 is not configured.", toLower _operation]] call _finish
};
if (_cash < _price) exitWith {
    [false, "INSUFFICIENT_CASH", "Insufficient cash for weapon acquisition.", createHashMapFromArray [
        ["cash", _cash], ["price", _price]
    ]] call _finish
};

private _nextOwned = +_ownedWeapons;
private _nextRented = +_rentedWeapons;
if (_operation isEqualTo "PURCHASE") then {
    _nextOwned pushBackUnique _canonicalClass;
    _nextRented = _nextRented - [_canonicalClass];
} else {
    _nextRented pushBackUnique _canonicalClass;
};

private _resultCode = if (_operation isEqualTo "PURCHASE") then {"WEAPON_PURCHASED"} else {"WEAPON_RENTED"};
private _accessType = if (_operation isEqualTo "PURCHASE") then {"OWNED"} else {"RENTED"};
[true, _resultCode, format ["Weapon %1 completed.", toLower _operation], createHashMapFromArray [
    ["committed", true],
    ["charged", _price],
    ["price", _price],
    ["cash", _cash - _price],
    ["owned", (_operation isEqualTo "PURCHASE")],
    ["rented", (_operation isEqualTo "RENT")],
    ["accessType", _accessType],
    ["nextOwnedWeapons", _nextOwned],
    ["nextRentedWeapons", _nextRented]
]] call _finish
