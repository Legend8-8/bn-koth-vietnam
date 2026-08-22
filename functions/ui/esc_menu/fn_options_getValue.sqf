/*
    File: fn_options_getValue.sqf
    Author: tylervip
    Description: Reads one ESC option from profile or config default.
    Execution: Client
    Parameters:
        0: Option config name <STRING>
    Returns:
        Value <NUMBER>
    Public: Yes
*/

params [["_option", "", [""]]];
if (_option isEqualTo "") exitWith {0};

private _cfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> _option;
if !(isClass _cfg) exitWith {0};

private _default = getNumber (_cfg >> "default");
private _profileKey = format ["BN_KOTH_escMenuOption_%1", _option];

profileNamespace getVariable [_profileKey, _default]
