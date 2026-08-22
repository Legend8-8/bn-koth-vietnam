/*
    File: fn_options_init.sqf
    Author: tylervip
    Description: Initializes option handlers and applies stored values.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _handlers = createHashMap;
private _cfgRoot = missionConfigFile >> "CfgBnKothEscMenuOptions";

{
    private _option = configName _x;
    private _onChange = getText (_x >> "onChange");
    private _handler = if (_onChange isEqualTo "") then {{}} else {compile _onChange};
    _handlers set [_option, _handler];
} forEach ("true" configClasses _cfgRoot);

localNamespace setVariable ["BN_KOTH_escMenuOptionHandlers", _handlers];

{
    private _option = configName _x;
    private _value = [_option] call bn_koth_fnc_escMenu_options_getValue;
    [_option, _value, false] call bn_koth_fnc_escMenu_options_setValue;
} forEach ("true" configClasses _cfgRoot);
