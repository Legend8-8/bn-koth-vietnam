/*
    File: fn_repackAllMags.sqf
    Author: tylervip
    Description: Repack all partial magazines for the local player.
    Execution: Client
    Parameters: None
    Returns: Nothing
*/

private _repacked = [];
{
    private _mag = _x select 0;
    private _ammo = _x select 1;
    private _isLoaded = _x select 2;
    private _magMax = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");

    if (!_isLoaded && {_ammo > 0} && {_ammo < _magMax} && {_magMax > 1}) then {
        if !(_mag in _repacked) then {
            [_mag] call bn_koth_fnc_magRepack_ammoRepack;
            _repacked pushBack _mag;
        };
    };
} forEach magazinesAmmoFull player;
