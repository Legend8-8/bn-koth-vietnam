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
    Returns:
        Player progression presentation payload <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_progression", createHashMap, [createHashMap]]
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
private _perks = _progression getOrDefault ["perks", []];

if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};
if !(_perks isEqualType []) then {_perks = []};

createHashMapFromArray [
    ["uid", _uid],
    ["xp", _xp],
    ["level", _level],
    ["cash", _cash],
    ["weaponKills", _weaponKills],
    ["ownedWeapons", _ownedWeapons],
    ["rentedWeapons", _rentedWeapons],
    ["perks", _perks]
]
