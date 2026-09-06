/*
    File: fn_getCatalog.sqf
    Author: tylervip
    Description: Builds the wheel-menu item list from the config catalog.
    Execution: Client
    Parameters: None
    Returns: <ARRAY>
    Public: Yes
*/

private _root = missionConfigFile >> "CfgBnKothBuild" >> "Objects";
private _catalog = [];

if !(isClass (missionConfigFile >> "CfgBnKothBuild")) exitWith {_catalog};

{
    private _key = configName _x;
    private _className = getText (_x >> "classname");
    if (_className isEqualTo "") then {continue;};

    private _icon = getText (_x >> "icon");
    if (_icon isEqualTo "") then {
        _icon = getText (configFile >> "CfgVehicles" >> _className >> "editorPreview");
    };

    _catalog pushBack [
        _icon,
        "",
        [[_key], "bn_koth_fnc_build_onSelect", false]
    ];
} forEach ("true" configClasses _root);

_catalog
