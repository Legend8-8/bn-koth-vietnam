/*
    File: fn_evaluateEquipmentSidePolicyRules.sqf
    Author: Legend
    Description: Pure KOTH equipment-side policy interpreter. Gameplay
        availability and visual identity are evaluated independently from
        factual S.O.G. provenance and progression requirements.
    Execution: Any
    Parameters:
        0: Authoritative/presented KOTH side token <STRING>
        1: Human-authored equipment metadata <HASHMAP>
        2: Whether visual identity metadata is mandatory <BOOL>
    Returns: Side-policy result <HASHMAP>
    Public: No
*/

params [
    ["_sideToken", "", [""]],
    ["_metadata", createHashMap, [createHashMap]],
    ["_requireAppearance", false, [false]]
];

private _side = toUpper _sideToken;
private _allowedSides = _metadata getOrDefault ["allowedSides", []];
private _allowedSidesTypeValid = _allowedSides isEqualType [];
if (!_allowedSidesTypeValid) then {_allowedSides = []};
private _allowedSideValuesValid = (_allowedSides findIf {!(_x isEqualType "")}) < 0;
if (_allowedSideValuesValid) then {_allowedSides = _allowedSides apply {toUpper _x}};
_allowedSides = _allowedSides arrayIntersect _allowedSides;

private _appearanceSideRaw = _metadata getOrDefault ["appearanceSide", ""];
private _appearanceSideTypeValid = _appearanceSideRaw isEqualType "";
private _appearanceSide = if (_appearanceSideTypeValid) then {toUpper _appearanceSideRaw} else {""};
private _validTokens = ["WEST", "EAST"];
private _validAppearanceTokens = ["WEST", "EAST", "BOTH"];

private _finish = {
    params ["_allowed", "_code", "_message"];
    createHashMapFromArray [
        ["success", _allowed],
        ["allowed", _allowed],
        ["code", _code],
        ["message", _message],
        ["sideToken", _side],
        ["allowedSides", _allowedSides],
        ["appearanceSide", _appearanceSide],
        ["appearanceRequired", _requireAppearance]
    ]
};

if !(_side in _validTokens) exitWith {
    [false, "LOCKED_SIDE_STATE", "Equipment side policy requires a valid KOTH side."] call _finish
};

if (!_allowedSidesTypeValid || {!_allowedSideValuesValid} || {(_allowedSides findIf {!(_x in _validTokens)}) >= 0}) exitWith {
    [false, "LOCKED_SIDE_METADATA", "Equipment allowedSides metadata is invalid."] call _finish
};

if ((count _allowedSides) > 0 && {!(_side in _allowedSides)}) exitWith {
    [false, "LOCKED_SIDE", "Equipment is not available to this KOTH side."] call _finish
};

if (_requireAppearance && {!_appearanceSideTypeValid || {!(_appearanceSide in _validAppearanceTokens)}}) exitWith {
    [false, "LOCKED_APPEARANCE_METADATA", "Visual equipment has no safe KOTH appearance identity."] call _finish
};

// BOTH is a deliberate provisional exception (currently headgear-only policy), never inferred; it must be authored explicitly.
if (_requireAppearance && {!(_appearanceSide isEqualTo "BOTH")} && {!(_appearanceSide isEqualTo _side)}) exitWith {
    [false, "LOCKED_APPEARANCE_SIDE", "Visual equipment belongs to the opposing KOTH appearance side."] call _finish
};

[true, "SIDE_POLICY_ALLOWED", "Equipment side policy is valid."] call _finish
