/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Adds a local action to repack partial magazines into full ones.
    Execution: Client
    Parameters: None
    Returns: True when the player action is installed <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};
if (isNull player) exitWith {false};

private _unit = player;

if !(_unit getVariable ["BN_KOTH_magRepackActionInstalled", false]) then {
    _unit addAction [
        "<t color='#ffff00'>Repack Ammo</t>",
        {
            [] call bn_koth_fnc_magRepack_repackAllMags;
        },
        nil,
        1.5,
        false,
        true,
        "",
        "_this == _originalTarget && {({_x select 1 > 0 && _x select 1 < getNumber (configFile >> 'CfgMagazines' >> (_x select 0) >> 'count') && !(_x select 2)} count (magazinesAmmoFull _this)) > 1}",
        3
    ];

    _unit setVariable ["BN_KOTH_magRepackActionInstalled", true, false];
};

true
