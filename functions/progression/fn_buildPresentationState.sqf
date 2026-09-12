/*
    File: fn_buildPresentationState.sqf
    Author: Legend
    Description: Projects server-owned player progression into the minimum
        player-only state required for client presentation. It reads no
        mission state and does not decide entitlement.
    Execution: Any
    Parameters:
        0: Player UID <STRING>
        1: Progression state <HASHMAP>
        2: Include durable saved-kit intent <BOOL> (default false)
    Returns:
        Player progression presentation payload <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_progression", createHashMap, [createHashMap]],
    ["_includeSavedKits", false, [false]]
];

// max() does not reliably sanitize NaN in this engine, so non-finite authoritative
// fields must be rejected explicitly with finite() rather than merely clamped.
private _rawXp = _progression getOrDefault ["xp", 0];
private _xp = if (_rawXp isEqualType 0 && {finite _rawXp}) then {_rawXp max 0} else {0};
private _rawLevel = _progression getOrDefault ["level", 1];
private _level = if (_rawLevel isEqualType 0 && {finite _rawLevel}) then {_rawLevel max 1} else {1};
private _rawCash = _progression getOrDefault ["cash", 0];
private _cash = if (_rawCash isEqualType 0 && {finite _rawCash}) then {_rawCash max 0} else {0};
private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
private _ownedWeapons = _progression getOrDefault ["ownedWeapons", []];
private _rentedWeapons = _progression getOrDefault ["rentedWeapons", []];
private _ownedPerks = _progression getOrDefault ["ownedPerks", []];
private _activePerks = _progression getOrDefault ["activePerks", []];
private _savedKits = _progression getOrDefault ["savedKits", []];

if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};
if !(_ownedPerks isEqualType []) then {_ownedPerks = []};
if !(_activePerks isEqualType []) then {_activePerks = []};
if !(_savedKits isEqualType []) then {_savedKits = []};
private _perkRoot = missionConfigFile >> "CfgBnKothPerks";
private _perkCatalogue = [];
if (isClass _perkRoot) then {
    {
        private _metadata = [configName _x] call bn_koth_fnc_progression_perks_getConfig;
        if (_metadata getOrDefault ["available", false]) then {
            _perkCatalogue pushBack createHashMapFromArray [
                ["perkId", _metadata getOrDefault ["perkId", ""]],
                ["displayName", _metadata getOrDefault ["displayName", ""]],
                ["description", _metadata getOrDefault ["description", ""]],
                ["purchaseCost", _metadata getOrDefault ["purchaseCost", -1]],
                ["purchasable", _metadata getOrDefault ["purchasable", false]]
            ];
        };
    } forEach ("true" configClasses (_perkRoot >> "Perks"));
};

private _result = createHashMapFromArray [
    ["uid", _uid],
    ["xp", _xp],
    ["level", _level],
    ["cash", _cash],
    ["weaponKills", _weaponKills],
    ["ownedWeapons", _ownedWeapons],
    ["rentedWeapons", _rentedWeapons],
    ["ownedPerks", _ownedPerks],
    ["activePerks", _activePerks],
    ["perks", _activePerks],
    ["maxActivePerks", if (isClass _perkRoot) then {floor ((getNumber (_perkRoot >> "maxActivePerks")) max 0)} else {0}],
    ["perkCatalogue", _perkCatalogue]
];
if (_includeSavedKits) then {
    _result set ["savedKits", _savedKits];
    _result set ["preferredSavedKitId", _progression getOrDefault ["preferredSavedKitId", ""]];
    _result set ["savedKitsInitialized", _progression getOrDefault ["savedKitsInitialized", false]];
    _result set ["savedKitsAuthoritative", true];
};
_result
