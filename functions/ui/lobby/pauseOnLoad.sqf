/*
    File: pauseOnLoad.sqf
    Author: Legend
    Description: Native pause-menu hook entrypoint used by description.ext onPauseScript.
    Execution: Client
*/

if (!hasInterface) exitWith {};

private _pauseDisplay = _this param [0, displayNull];

if (isNull _pauseDisplay) then {
    _pauseDisplay = findDisplay 49;
};

uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuSuppressed", true];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuActive", true];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuRestorePending", false];

if (!isNull _pauseDisplay) then {
    private _installFn = missionNamespace getVariable ["bn_koth_fnc_escMenu_installPauseButtons", {}];
    if !(_installFn isEqualTo {}) then {
        [_pauseDisplay] call _installFn;
    } else {
        if !(_pauseDisplay getVariable ["BN_KOTH_escMenuButtonsAttached", false]) then {
            private _keyButton = _pauseDisplay ctrlCreate ["RscButtonMenu", -1];
            _keyButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.17, safeZoneW * 0.18, safeZoneH * 0.035];
            _keyButton ctrlSetText "GAMEMODE KEYBINDINGS";
            _keyButton ctrlCommit 0;
            _keyButton ctrlAddEventHandler ["ButtonClick", {
                params ["_button"];
                private _openFn = missionNamespace getVariable ["bn_koth_fnc_escMenu_openKeybindings", {}];
                if !(_openFn isEqualTo {}) then {
                    [ctrlParent _button] call _openFn;
                };
            }];

            private _optionsButton = _pauseDisplay ctrlCreate ["RscButtonMenu", -1];
            _optionsButton ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.215, safeZoneW * 0.18, safeZoneH * 0.035];
            _optionsButton ctrlSetText "GAMEMODE OPTIONS";
            _optionsButton ctrlCommit 0;
            _optionsButton ctrlAddEventHandler ["ButtonClick", {
                params ["_button"];
                private _openFn = missionNamespace getVariable ["bn_koth_fnc_escMenu_openOptions", {}];
                if !(_openFn isEqualTo {}) then {
                    [ctrlParent _button] call _openFn;
                };
            }];

            _pauseDisplay setVariable ["BN_KOTH_escMenuButtonsAttached", true];
        };
    };

    private _existingEhId = _pauseDisplay getVariable ["BN_KOTH_pauseUnloadEhId", -1];
    if (_existingEhId < 0) then {
        private _ehId = _pauseDisplay displayAddEventHandler ["Unload", {
            uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuActive", false];
            uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuRestorePending", true];
        }];

        _pauseDisplay setVariable ["BN_KOTH_pauseUnloadEhId", _ehId];
    };
};
