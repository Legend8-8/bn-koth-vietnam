/*
    File: fn_ammoRepack.sqf
    Author: tylervip
    Description: Repack partial magazines of a single type for the local player.
    Execution: Client
    Parameters:
        _mag - magazine class name <STRING>
    Returns: Nothing
*/

params ["_mag"];

if (isNil "_mag" || {_mag == ""}) exitWith {};

private _magMax = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
if (_magMax <= 1) exitWith {};

private _total = 0;
{
    if (_mag isEqualTo (_x select 0) && {!(_x select 2)}) then {
        _total = _total + (_x select 1);
    };
} forEach magazinesAmmoFull player;

if (_total <= 0) exitWith {};

{
    if (_mag isEqualTo (_x select 0) && {!(_x select 2)}) then {
        player removeMagazine (_x select 0);
    };
} forEach magazinesAmmoFull player;

for "_i" from 1 to floor (_total / _magMax) do {
    player addMagazine [_mag, _magMax];
};

private _rem = _total % _magMax;
if (_rem > 0) then {
    player addMagazine [_mag, _rem];
};

hintSilent "Mags Repacked";
sleep 2;
hintSilent "";
