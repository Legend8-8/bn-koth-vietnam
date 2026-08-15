/*
    File: fn_applyLoadout.sqf
    Author: Legend
    Description: Applies a previously validated loadout to a unit through one owned path.
    Execution: Any (must execute where target unit is local)
    Parameters:
        0: Target unit <OBJECT>
        1: Validation result map from bn_koth_fnc_loadouts_validateLoadout <HASHMAP>
    Returns:
        Application result <HASHMAP>
    Public: No
*/

params [
    ["_unit", objNull, [objNull]],
    ["_validationResult", createHashMap, [createHashMap]]
];

private _fail = {
    params ["_code", "_message", ["_loadoutId", "", [""]]];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["loadoutId", _loadoutId]
    ]
};

if (isNull _unit) exitWith {
    ["ERR_INVALID_UNIT", "Loadout application requires a valid unit object."] call _fail
};

if !(local _unit) exitWith {
    ["ERR_UNIT_NOT_LOCAL", "Loadout application rejected: execute on the machine that owns the target unit."] call _fail
};

if !(_validationResult isEqualType createHashMap) exitWith {
    ["ERR_INVALID_VALIDATION_RESULT", "Loadout application requires a validation result map."] call _fail
};

private _isValidated = _validationResult getOrDefault ["success", false];
private _validatedBy = _validationResult getOrDefault ["validatedBy", ""];
private _loadoutId = _validationResult getOrDefault ["loadoutId", ""];

if (!_isValidated || {!(_validatedBy isEqualTo "bn_koth_fnc_loadouts_validateLoadout")}) exitWith {
    ["ERR_UNTRUSTED_VALIDATION", "Loadout application requires a successful server validation result.", _loadoutId] call _fail
};

// Entitlement is authoritative server logic in validator/progression APIs, not in application.
private _validatedLoadout = _validationResult getOrDefault ["validatedLoadout", []];
if !(_validatedLoadout isEqualType []) exitWith {
    ["ERR_VALIDATED_LOADOUT_TYPE", "Validated loadout payload has invalid type.", _loadoutId] call _fail
};

if ((count _validatedLoadout) <= 0) exitWith {
    ["ERR_VALIDATED_LOADOUT_EMPTY", "Validated loadout payload is empty.", _loadoutId] call _fail
};

_unit setUnitLoadout _validatedLoadout;

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", "Validated loadout applied."],
    ["loadoutId", _loadoutId]
]
