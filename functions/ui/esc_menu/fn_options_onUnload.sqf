/*
    File: fn_options_onUnload.sqf
    Author: tylervip
    Description: Commits or resets options when options menu closes.
    Execution: Client
    Parameters:
        0: Display <DISPLAY>
        1: Exit code <NUMBER>
    Returns:
        None
    Public: Yes
*/

params ["_display", "_exitCode"];

switch (_exitCode) do {
    case 1: {
        private _pending = _display getVariable ["BN_KOTH_escMenuPendingOptions", createHashMap];
        {
            [_x, _pending getOrDefault [_x, 0], false] call bn_koth_fnc_escMenu_options_setValue;
        } forEach ["earplugVolumeGround", "earplugVolumeVehicle", "player3DIconsEnabled", "player3DIconsAlpha"];

        saveProfileNamespace;
        [] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;
    };

    case 3: {
        private _cfgRoot = missionConfigFile >> "CfgBnKothEscMenuOptions";
        {
            private _name = configName _x;
            private _default = getNumber (_x >> "default");
            [_name, _default, false] call bn_koth_fnc_escMenu_options_setValue;
        } forEach ("true" configClasses _cfgRoot);

        saveProfileNamespace;
        [] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;
    };

    default {};
};
