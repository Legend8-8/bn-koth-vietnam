/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Initializes ESC menu input hooks, options, and earplug state.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};
diag_log format ["[BN_KOTH][INFO] escMenu_initPlayerLocal begin owner=%1 unit=%2", clientOwner, typeOf player];
private _firstInit = !(missionNamespace getVariable ["BN_KOTH_escMenuInitialized", false]);
if (_firstInit) then {
    missionNamespace setVariable ["BN_KOTH_escMenuInitialized", true];

    [] call bn_koth_fnc_escMenu_options_init;
    [] call bn_koth_fnc_escMenu_earplugs_init;
    [] call bn_koth_fnc_escMenu_keybinds_init;
    [] call bn_koth_fnc_escMenu_installPauseButtons;
    diag_log "[BN_KOTH][INFO] escMenu_initPlayerLocal firstInit completed core setup";

    [] spawn {
        waitUntil {sleep 0.1; !isNull (findDisplay 46)};

        private _display = findDisplay 46;
        if (isNull _display) exitWith {};

        if ((_display getVariable ["BN_KOTH_escMenuKeyDownEh", -1]) < 0) then {
            private _keyDownEh = _display displayAddEventHandler ["KeyDown", "_this call bn_koth_fnc_escMenu_keybinds_handleKeyDown"];
            _display setVariable ["BN_KOTH_escMenuKeyDownEh", _keyDownEh];
        };

        if ((_display getVariable ["BN_KOTH_escMenuKeyUpEh", -1]) < 0) then {
            private _keyUpEh = _display displayAddEventHandler ["KeyUp", "_this call bn_koth_fnc_escMenu_keybinds_handleKeyUp"];
            _display setVariable ["BN_KOTH_escMenuKeyUpEh", _keyUpEh];
        };

        diag_log "[BN_KOTH][INFO] escMenu_initPlayerLocal installed display46 key handlers";
    };
};

private _boundUnit = missionNamespace getVariable ["BN_KOTH_escMenuVehicleEhUnit", objNull];
private _inEhId = missionNamespace getVariable ["BN_KOTH_escMenuVehicleInEh", -1];
private _outEhId = missionNamespace getVariable ["BN_KOTH_escMenuVehicleOutEh", -1];

if (!isNull _boundUnit && {!(_boundUnit isEqualTo player)}) then {
    if (_inEhId >= 0) then {
        _boundUnit removeEventHandler ["GetInMan", _inEhId];
    };
    if (_outEhId >= 0) then {
        _boundUnit removeEventHandler ["GetOutMan", _outEhId];
    };

    missionNamespace setVariable ["BN_KOTH_escMenuVehicleInEh", -1];
    missionNamespace setVariable ["BN_KOTH_escMenuVehicleOutEh", -1];
};

if (isNull _boundUnit || {!(_boundUnit isEqualTo player)} || {_inEhId < 0} || {_outEhId < 0}) then {
    missionNamespace setVariable [
        "BN_KOTH_escMenuVehicleInEh",
        player addEventHandler ["GetInMan", {
            [] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;
        }]
    ];

    missionNamespace setVariable [
        "BN_KOTH_escMenuVehicleOutEh",
        player addEventHandler ["GetOutMan", {
            [] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;
        }]
    ];

    missionNamespace setVariable ["BN_KOTH_escMenuVehicleEhUnit", player];
};

[] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;
diag_log format ["[BN_KOTH][INFO] escMenu_initPlayerLocal end owner=%1 unit=%2", clientOwner, typeOf player];
