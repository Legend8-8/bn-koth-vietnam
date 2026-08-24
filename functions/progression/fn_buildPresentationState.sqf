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

private _xp = (_progression getOrDefault ["xp", 0]) max 0;
private _level = (_progression getOrDefault ["level", 1]) max 1;
private _cash = (_progression getOrDefault ["cash", 0]) max 0;
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
