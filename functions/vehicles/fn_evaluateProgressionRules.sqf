/*
    File: fn_evaluateProgressionRules.sqf
    Author: Legend
    Description: Pure vehicle side, level, and perk eligibility interpreter.
        It does not read mission state, award ownership, charge cash, or spawn
        a vehicle. Weapon mastery is intentionally not part of vehicle policy.
    Execution: Any
    Parameters:
        0: Side token <STRING>
        1: Player level <NUMBER>
        2: Player perks <ARRAY>
        3: Vehicle metadata <HASHMAP>
    Returns:
        Vehicle eligibility result <HASHMAP>
    Public: No
*/

params [
    ["_sideToken", "", [""]],
    ["_playerLevel", 1, [0]],
    ["_playerPerks", [], [[]]],
    ["_metadata", createHashMap, [createHashMap]]
];

private _side = toUpper _sideToken;
private _canonicalClass = _metadata getOrDefault ["canonicalClass", ""];
private _finish = {
    params ["_success", "_eligible", "_code", "_message", ["_extra", createHashMap, [createHashMap]]];

    private _result = createHashMapFromArray [
        ["success", _success],
        ["eligible", _eligible],
        ["code", _code],
        ["message", _message],
        ["canonicalClass", _canonicalClass],
        ["sideToken", _side]
    ];
    {_result set [_x, _extra get _x]} forEach (keys _extra);
    _result
};

if !(_metadata getOrDefault ["success", false]) exitWith {
    [false, false, "INVALID_METADATA", "Vehicle progression metadata is invalid."] call _finish
};

private _allowedSides = _metadata getOrDefault ["allowedSides", []];
if !(_side in _allowedSides) exitWith {
    [true, false, "LOCKED_SIDE", "Vehicle is not available to this KOTH side.",
        createHashMapFromArray [["allowedSides", _allowedSides]]] call _finish
};

private _minLevel = _metadata getOrDefault ["minLevel", 1];
if (_playerLevel < _minLevel) exitWith {
    [true, false, "LOCKED_LEVEL", format ["Requires level %1.", _minLevel],
        createHashMapFromArray [["playerLevel", _playerLevel], ["minLevel", _minLevel]]] call _finish
};

private _requiredPerks = _metadata getOrDefault ["requiredPerks", []];
private _normalizedPerks = _playerPerks apply {toLower _x};
private _missingPerks = _requiredPerks select {!((toLower _x) in _normalizedPerks)};
if ((count _missingPerks) > 0) exitWith {
    [true, false, "LOCKED_PERK", "Required vehicle perk entitlement is incomplete.",
        createHashMapFromArray [["missingPerks", _missingPerks]]] call _finish
};

[true, true, "ELIGIBLE", "Vehicle side, level, and perk requirements are complete.",
    createHashMapFromArray [
        ["minLevel", _minLevel],
        ["purchasePrice", _metadata getOrDefault ["purchasePrice", -1]],
        ["rentalPrice", _metadata getOrDefault ["rentalPrice", -1]],
        ["storeCategory", _metadata getOrDefault ["storeCategory", ""]],
        ["vehicleRole", _metadata getOrDefault ["vehicleRole", ""]]
    ]] call _finish
