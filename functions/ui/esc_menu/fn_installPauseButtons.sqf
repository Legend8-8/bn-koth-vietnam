/*
    File: fn_installPauseButtons.sqf
    Author: tylervip
    Edited: Legend
    Description: Adds rank/progression presentation and ESC pause-menu buttons
        for returning to the lobby and gamemode keybinds/options.
    Execution: Client
    Parameters:
        0: Pause display (optional) <DISPLAY>
    Returns:
        None
    Public: Yes
*/

params [["_pauseDisplay", displayNull, [displayNull]]];

if (!hasInterface) exitWith {};
private _attachButtons = {
    params ["_display"];
    if (isNull _display) exitWith {};
    if (_display getVariable ["BN_KOTH_escMenuButtonsAttached", false]) exitWith {};

    private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
    if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
    private _rawXp = _progression getOrDefault ["xp", 0];
    private _xp = if (_rawXp isEqualType 0 && {finite _rawXp}) then {_rawXp max 0} else {0};
    private _rawCash = _progression getOrDefault ["cash", 0];
    private _cash = if (_rawCash isEqualType 0 && {finite _rawCash}) then {_rawCash max 0} else {0};
    private _rawLevel = _progression getOrDefault ["level", 1];
    private _requestedLevel = if (_rawLevel isEqualType 0 && {finite _rawLevel}) then {_rawLevel max 1} else {1};
    private _levelProgress = [_xp, _requestedLevel] call bn_koth_fnc_progression_xp_getLevelProgress;
    if !(_levelProgress isEqualType createHashMap) then {
        // Progression state/functions may not be ready on the very first ESC open; fail safe instead of printing "any".
        _levelProgress = createHashMapFromArray [
            ["level", _requestedLevel], ["maxLevel", 270], ["xpIntoLevel", 0], ["xpRequired", 0], ["ratio", 1]
        ];
    };
    private _resolvedLevel = _levelProgress getOrDefault ["level", 1];
    private _level = if (_resolvedLevel isEqualType 0 && {finite _resolvedLevel}) then {_resolvedLevel max 1} else {1};
    private _rank = [_level] call bn_koth_fnc_progression_resolveRankPresentation;
    if !(_rank isEqualType createHashMap) then {
        _rank = createHashMap;
    };
    private _playerName = toUpper (if (!isNull player) then {name player} else {profileName});
    private _xpText = if (_level >= (_levelProgress getOrDefault ["maxLevel", 270])) then {
        format ["MAX | %1 XP", round _xp]
    } else {
        format ["%1 / %2 XP", round (_levelProgress getOrDefault ["xpIntoLevel", 0]), round (_levelProgress getOrDefault ["xpRequired", 0])]
    };

    private _panel = _display ctrlCreate ["RscText", -1];
    _panel ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.052, safeZoneW * 0.18, safeZoneH * 0.108];
    _panel ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    _panel ctrlEnable false;
    _panel ctrlCommit 0;

    private _rankIcon = _display ctrlCreate ["RscPicture", -1];
    _rankIcon ctrlSetPosition [safeZoneX + safeZoneW * 0.024, safeZoneY + safeZoneH * 0.061, safeZoneH * 0.060, safeZoneH * 0.060];
    _rankIcon ctrlSetText (_rank getOrDefault ["icon", ""]);
    _rankIcon ctrlSetTextColor (_rank getOrDefault ["color", [1, 1, 1, 0]]);
    _rankIcon ctrlShow (_rank getOrDefault ["hasIcon", false]);
    _rankIcon ctrlEnable false;
    _rankIcon ctrlCommit 0;

    private _nameText = _display ctrlCreate ["RscText", -1];
    _nameText ctrlSetPosition [safeZoneX + safeZoneW * 0.061, safeZoneY + safeZoneH * 0.058, safeZoneW * 0.129, safeZoneH * 0.025];
    _nameText ctrlSetText _playerName;
    _nameText ctrlSetFont "PuristaSemiBold";
    _nameText ctrlSetFontHeight (safeZoneH * 0.021);
    _nameText ctrlSetTextColor [0.92, 0.90, 0.84, 1];
    _nameText ctrlEnable false;
    _nameText ctrlCommit 0;

    private _levelText = _display ctrlCreate ["RscText", -1];
    _levelText ctrlSetPosition [safeZoneX + safeZoneW * 0.061, safeZoneY + safeZoneH * 0.082, safeZoneW * 0.129, safeZoneH * 0.020];
    _levelText ctrlSetText format ["LEVEL %1", _level];
    _levelText ctrlSetFont "PuristaMedium";
    _levelText ctrlSetFontHeight (safeZoneH * 0.016);
    _levelText ctrlSetTextColor [0.89, 0.70, 0.24, 1];
    _levelText ctrlEnable false;
    _levelText ctrlCommit 0;

    private _xpTextCtrl = _display ctrlCreate ["RscText", -1];
    _xpTextCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.061, safeZoneY + safeZoneH * 0.104, safeZoneW * 0.075, safeZoneH * 0.018];
    _xpTextCtrl ctrlSetText _xpText;
    _xpTextCtrl ctrlSetFontHeight (safeZoneH * 0.013);
    _xpTextCtrl ctrlSetTextColor [0.72, 0.70, 0.64, 1];
    _xpTextCtrl ctrlEnable false;
    _xpTextCtrl ctrlCommit 0;

    private _cashText = _display ctrlCreate ["RscText", -1];
    _cashText ctrlSetPosition [safeZoneX + safeZoneW * 0.137, safeZoneY + safeZoneH * 0.104, safeZoneW * 0.053, safeZoneH * 0.018];
    _cashText ctrlSetText ([_cash] call bn_koth_fnc_ui_formatCash);
    _cashText ctrlSetFontHeight (safeZoneH * 0.013);
    _cashText ctrlSetTextColor [0.78, 0.76, 0.52, 1];
    _cashText ctrlEnable false;
    _cashText ctrlCommit 0;

    private _returnButton = _display ctrlCreate ["RscButtonMenu", -1];
    _returnButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.17, safeZoneW * 0.18, safeZoneH * 0.035];
    _returnButton ctrlSetText "RETURN TO LOBBY";
    _returnButton ctrlSetTextColor [0.92, 0.42, 0.32, 1];
    _returnButton ctrlSetBackgroundColor [0.20, 0.055, 0.045, 1];
    _returnButton ctrlCommit 0;
    _returnButton setVariable ["BN_KOTH_returnToLobbyConfirming", false];
    _returnButton setVariable ["BN_KOTH_returnToLobbyConfirmToken", 0];
    _returnButton ctrlAddEventHandler ["ButtonClick", {
        params ["_button"];
        private _confirming = _button getVariable ["BN_KOTH_returnToLobbyConfirming", false];

        if (_confirming) then {
            _button setVariable ["BN_KOTH_returnToLobbyConfirming", false];
            _button ctrlSetText "RETURN TO LOBBY";
            _button ctrlSetBackgroundColor [0.20, 0.055, 0.045, 1];

            [] call bn_koth_fnc_teams_requestReturnToLobby;

            private _pauseDisplay = ctrlParent _button;
            if (!isNull _pauseDisplay) then {
                _pauseDisplay closeDisplay 2;
            };
        } else {
            _button setVariable ["BN_KOTH_returnToLobbyConfirming", true];
            _button ctrlSetText "CONFIRM RETURN TO LOBBY?";
            _button ctrlSetBackgroundColor [0.34, 0.11, 0.07, 1];

            private _token = (_button getVariable ["BN_KOTH_returnToLobbyConfirmToken", 0]) + 1;
            _button setVariable ["BN_KOTH_returnToLobbyConfirmToken", _token];

            [_button, _token] spawn {
                params ["_button", "_token"];
                sleep 4;
                if (isNull _button) exitWith {};
                if ((_button getVariable ["BN_KOTH_returnToLobbyConfirmToken", -1]) isEqualTo _token) then {
                    _button setVariable ["BN_KOTH_returnToLobbyConfirming", false];
                    _button ctrlSetText "RETURN TO LOBBY";
                    _button ctrlSetBackgroundColor [0.20, 0.055, 0.045, 1];
                };
            };
        };
    }];

    private _keyButton = _display ctrlCreate ["RscButtonMenu", -1];
    _keyButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.215, safeZoneW * 0.18, safeZoneH * 0.035];
    _keyButton ctrlSetText "GAMEMODE KEYBINDINGS";
    _keyButton ctrlCommit 0;
    _keyButton ctrlAddEventHandler ["ButtonClick", {
        params ["_button"];
        [ctrlParent _button] call bn_koth_fnc_escMenu_openKeybindings;
    }];

    private _optionsButton = _display ctrlCreate ["RscButtonMenu", -1];
    _optionsButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.26, safeZoneW * 0.18, safeZoneH * 0.035];
    _optionsButton ctrlSetText "GAMEMODE OPTIONS";
    _optionsButton ctrlCommit 0;
    _optionsButton ctrlAddEventHandler ["ButtonClick", {
        params ["_button"];
        [ctrlParent _button] call bn_koth_fnc_escMenu_openOptions;
    }];

    _display setVariable ["BN_KOTH_escMenuButtonsAttached", true];
    diag_log "[BN_KOTH][INFO] escMenu buttons attached to pause display";
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
