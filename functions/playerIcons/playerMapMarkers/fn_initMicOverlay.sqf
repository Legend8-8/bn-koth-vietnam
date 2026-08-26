/*
    File: fn_initMicOverlay.sqf
    Author: tylervip
    Description: Monitors voice state and draws talking players on the big map.
    Execution: Client
    Parameters: None
    Returns: True when the monitor is started, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _config = missionConfigFile >> "CfgBnKothPlayerMapMarkers";
if ((getNumber (_config >> "micOverlayEnabled")) <= 0) exitWith {
    missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicEnabled", false];
    false
};

private _inputAction = getText (_config >> "micInputAction");
if (_inputAction isEqualTo "") then {_inputAction = "PushToTalk"};
private _micTexture = getText (_config >> "micTexture");
if (_micTexture isEqualTo "") then {_micTexture = "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa"};
private _micColor = getArray (_config >> "micColor");
if !(_micColor isEqualType [] && {count _micColor >= 4}) then {_micColor = [0.85, 0.4, 0, 1]};
private _micSize = getNumber (_config >> "micSize");
if (_micSize <= 0) then {_micSize = 24};
private _micNameSize = getNumber (_config >> "micNameSize");
if (_micNameSize <= 0) then {_micNameSize = 0.04};
private _mapDisplayId = getNumber (_config >> "mapDisplayId");
if (_mapDisplayId <= 0) then {_mapDisplayId = 12};
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicEnabled", true];

private _existingHandle = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicOverlayHandle", scriptNull];
if (_existingHandle isEqualType scriptNull && {!scriptDone _existingHandle}) exitWith {true};

private _handle = [_inputAction, _micTexture, _micColor, _micSize, _micNameSize, _mapDisplayId] spawn {
    params ["_inputAction", "_micTexture", "_micColor", "_micSize", "_micNameSize", "_mapDisplayId"];

    while {hasInterface} do {
        private _isTalking = (inputAction _inputAction) > 0;
        private _lastTalking = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicTalking", !_isTalking];
        if !(_isTalking isEqualTo _lastTalking) then {
            missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicTalking", _isTalking];
            [player, _isTalking] remoteExecCall ["bn_koth_fnc_playerMapMarkers_setVoiceState", 0];
        };

        private _mapDisplay = findDisplay _mapDisplayId;
        if (!isNull _mapDisplay) then {
            private _mapControl = _mapDisplay displayCtrl 51;
            if (!isNull _mapControl && {(_mapControl getVariable ["BN_KOTH_playerMapMarkersMicDrawHandler", -1]) < 0}) then {
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicTexture", _micTexture];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicColor", _micColor];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicSize", _micSize];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicNameSize", _micNameSize];
                private _handlerId = _mapControl ctrlAddEventHandler ["Draw", {
                    params ["_mapControl"];
                    {
                        _x params ["_position"];
                        private _size = _mapControl getVariable ["BN_KOTH_playerMapMarkersMicSize", 24];
                        _mapControl drawIcon [
                            _mapControl getVariable ["BN_KOTH_playerMapMarkersMicTexture", "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa"],
                            _mapControl getVariable ["BN_KOTH_playerMapMarkersMicColor", [0.85, 0.4, 0, 1]],
                            _position,
                            _size,
                            _size,
                            2,
                            "",
                            true,
                            _mapControl getVariable ["BN_KOTH_playerMapMarkersMicNameSize", 0.04],
                            "PuristaMedium",
                            "right",
                            false
                        ];
                    } forEach (uiNamespace getVariable ["BN_KOTH_playerMapMarkersMicDrawEntries", []]);
                }];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicDrawHandler", _handlerId];
            };
        };

        uiSleep 0.05;
    };

    missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicOverlayHandle", scriptNull];
};

missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicOverlayHandle", _handle];
true
