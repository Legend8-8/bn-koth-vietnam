/*
    File: fn_earplugs_toggle.sqf
    Author: tylervip
    Description: Toggles earplugs on the local client.
    Execution: Client
    Parameters:
        None
    Returns:
        True when toggled <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _enabled = !(localNamespace getVariable ["BN_KOTH_earplugsEnabled", false]);
[_enabled] call bn_koth_fnc_escMenu_earplugs_apply;

[(if (_enabled) then {"EARPLUGS INSERTED."} else {"EARPLUGS REMOVED."})] call bn_koth_fnc_ui_notify;
true
