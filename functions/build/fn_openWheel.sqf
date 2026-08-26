/*
    File: fn_openWheel.sqf
    Author: tylervip
    Description: Opens the SOG wheel menu using the config catalog.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if !(call bn_koth_fnc_build_canBuild) exitWith {
    hint "Build menu unavailable right now.";
};

if (missionNamespace getVariable ["BN_KOTH_buildPlacementActive", false]) exitWith {
    hint "A build placement is already active.";
};

if (isNil "vn_fnc_wm_init") exitWith {
    hint "The SOG wheel menu is unavailable in this mission context.";
};

private _catalog = [] call bn_koth_fnc_build_getCatalog;
if ((count _catalog) <= 0) exitWith {
    hint "No buildable objects are configured.";
};

["Build menu opened.", "INFO"] call bn_koth_fnc_common_log;
[_catalog] call vn_fnc_wm_init;
