/*
    File: fn_keybinds_init.sqf
    Author: tylervip
    Edited: Mango Mongo
    Description: Rebuilds mission-local lookup maps for key down and key up binds.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _oldMappings = missionNamespace getVariable ["BN_KOTH_escMenuMappedKeys", []];
{
    missionNamespace setVariable [_x, nil];
} forEach _oldMappings;

private _newMappings = [];
private _cfgRoot = missionConfigFile >> "CfgBnKothEscMenuKeybinds";

{
    private _action = configName _x;
    private _functionName = getText (_x >> "function");
    if (_functionName isEqualTo "") then {continue;};

    private _bind = [_action] call bn_koth_fnc_escMenu_keybinds_getBind;
    if !(_bind isEqualType [] && {(count _bind) >= 4}) then {continue;};
    if ((_bind select 0) <= 0) then {continue;};

    private _isDown = (getNumber (_x >> "down")) > 0;
    private _prefix = if (_isDown) then {"keyDown"} else {"keyUp"};

    private _mapVar = format [
        "BN_KOTH_escMenu_%1_%2_%3_%4_%5",
        _prefix,
        _bind select 0,
        _bind select 1,
        _bind select 2,
        _bind select 3
    ];

    missionNamespace setVariable [_mapVar, _functionName];
    _newMappings pushBack _mapVar;
} forEach ("getNumber(_x >> 'access') >= 0" configClasses _cfgRoot);

missionNamespace setVariable ["BN_KOTH_escMenuMappedKeys", _newMappings];
