/*
    File: fn_installPauseButtons.sqf
    Author: tylervip
    Description: Adds ESC pause menu buttons for gamemode keybinds and options.
    Execution: Client
    Parameters:
        0: Pause display (optional) <DISPLAY>
    Returns:
        None
    Public: Yes
*/

params [["_pauseDisplay", displayNull, [displayNull]]];

if (!hasInterface) exitWith {};

#include "..\..\..\ui\esc_menu\idcs.hpp"

private _attachButtons = {
    params ["_display"];
    if (isNull _display) exitWith {};

    if !(_display getVariable ["BN_KOTH_escMenuButtonsAttached", false]) then {
        private _keyButton = _display ctrlCreate ["RscButtonMenu", -1];
        _keyButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.17, safeZoneW * 0.18, safeZoneH * 0.035];
        _keyButton ctrlSetText "GAMEMODE KEYBINDINGS";
        _keyButton ctrlCommit 0;
        _keyButton ctrlAddEventHandler ["ButtonClick", {
            params ["_button"];
            [ctrlParent _button] call bn_koth_fnc_escMenu_openKeybindings;
        }];

        private _optionsButton = _display ctrlCreate ["RscButtonMenu", -1];
        _optionsButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.215, safeZoneW * 0.18, safeZoneH * 0.035];
        _optionsButton ctrlSetText "GAMEMODE OPTIONS";
        _optionsButton ctrlCommit 0;
        _optionsButton ctrlAddEventHandler ["ButtonClick", {
            params ["_button"];
            [ctrlParent _button] call bn_koth_fnc_escMenu_openOptions;
        }];

        private _switchTeamsButton = _display ctrlCreate ["RscButtonMenu", BN_KOTH_IDC_ESC_SWITCH_TEAMS_BUTTON];
        _switchTeamsButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.26, safeZoneW * 0.18, safeZoneH * 0.035];
        _switchTeamsButton ctrlSetText "SWITCH TEAMS";
        _switchTeamsButton ctrlCommit 0;
        _switchTeamsButton ctrlAddEventHandler ["ButtonClick", {
            params ["_button"];
            [ctrlParent _button] call bn_koth_fnc_escMenu_switchTeams;
        }];

        _display setVariable ["BN_KOTH_escMenuButtonsAttached", true];
        diag_log "[BN_KOTH][INFO] escMenu buttons attached to pause display";
    };

    [_display] call bn_koth_fnc_escMenu_refreshSwitchTeamsButton;
};


if (!isNull _pauseDisplay) then {
    [_pauseDisplay] call _attachButtons;
};

if (uiNamespace getVariable ["BN_KOTH_escMenuPauseHookInstalled", false]) exitWith {
    diag_log "[BN_KOTH][INFO] escMenu_installPauseButtons skipped hook already installed";
};
uiNamespace setVariable ["BN_KOTH_escMenuPauseHookInstalled", true];
diag_log "[BN_KOTH][INFO] escMenu_installPauseButtons installing OnGameInterrupt hook";

[missionNamespace, "OnGameInterrupt", {
    params ["_display"];
    if (isNull _display) exitWith {
        diag_log "[BN_KOTH][WARN] escMenu OnGameInterrupt received null display";
    };

    diag_log "[BN_KOTH][INFO] escMenu OnGameInterrupt callback running";

    [_display] call (missionNamespace getVariable ["bn_koth_fnc_escMenu_installPauseButtons_attach", {}]);
}] call BIS_fnc_addScriptedEventHandler;

missionNamespace setVariable ["bn_koth_fnc_escMenu_installPauseButtons_attach", _attachButtons];
