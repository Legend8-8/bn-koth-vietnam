/*
    File: fn_initMicOverlay.sqf
    Author: tylervip
    Description: Monitors voice state and draws full-map voice plus full-map/GPS casualty overlays.
    Execution: Client
    Parameters: None
    Returns: True when the monitor is started, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _config = missionConfigFile >> "CfgBnKothPlayerMapMarkers";
private _micEnabled = (getNumber (_config >> "micOverlayEnabled")) > 0;

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
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicEnabled", _micEnabled];

private _helpTexture = getText (_config >> "casualtyHelpTexture");
if (_helpTexture isEqualTo "") then {_helpTexture = "\A3\ui_f\data\map\markers\military\warning_CA.paa"};
private _helpColor = getArray (_config >> "casualtyHelpColor");
if !(_helpColor isEqualType [] && {count _helpColor >= 4}) then {_helpColor = [1, 0.25, 0.2, 1]};
private _helpSize = (getNumber (_config >> "casualtyHelpSize")) max 1;
private _helpNameSize = (getNumber (_config >> "casualtyHelpNameSize")) max 0.01;

private _existingHandle = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicOverlayHandle", scriptNull];
if (_existingHandle isEqualType scriptNull && {!scriptDone _existingHandle}) exitWith {true};

private _handle = [_inputAction, _micEnabled, _micTexture, _micColor, _micSize, _micNameSize, _helpTexture, _helpColor, _helpSize, _helpNameSize, _mapDisplayId] spawn {
    params ["_inputAction", "_micEnabled", "_micTexture", "_micColor", "_micSize", "_micNameSize", "_helpTexture", "_helpColor", "_helpSize", "_helpNameSize", "_mapDisplayId"];

    while {hasInterface} do {
        if (_micEnabled) then {
            private _isTalking = (inputAction _inputAction) > 0;
            private _lastTalking = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicTalking", !_isTalking];
            if !(_isTalking isEqualTo _lastTalking) then {
                missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicTalking", _isTalking];
                [player, _isTalking] remoteExecCall ["bn_koth_fnc_playerMapMarkers_setVoiceState", 0];
            };
        };

        private _mapControls = [];
        private _mapDisplay = findDisplay _mapDisplayId;
        if (!isNull _mapDisplay) then {
            private _mapControl = _mapDisplay displayCtrl 51;
            if (!isNull _mapControl) then {
                _mapControls pushBack [_mapControl, true];
            };
        };

        private _iguiDisplays = uiNamespace getVariable ["IGUI_displays", []];
        if !(_iguiDisplays isEqualType []) then {_iguiDisplays = []};
        private _gpsDisplays = [];
        {
            private _referenceDisplay = uiNamespace getVariable [_x, displayNull];
            if (!isNull _referenceDisplay) then {
                _gpsDisplays pushBackUnique _referenceDisplay;
                private _referenceIdd = ctrlIDD _referenceDisplay;
                {
                    if (!isNull _x && {ctrlIDD _x isEqualTo _referenceIdd}) then {
                        _gpsDisplays pushBackUnique _x;
                    };
                } forEach _iguiDisplays;
            };
        } forEach ["RscCustomInfoMiniMap", "RscCustomInfoAirborneMiniMap"];

        {
            private _gpsControl = _x displayCtrl 101;
            if (!isNull _gpsControl) then {
                _mapControls pushBackUnique [_gpsControl, false];
            };
        } forEach _gpsDisplays;

        {
            _x params ["_mapControl", "_drawMic"];
            if ((_mapControl getVariable ["BN_KOTH_playerMapMarkersMicDrawHandler", -1]) < 0) then {
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicTexture", _micTexture];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicColor", _micColor];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicSize", _micSize];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicNameSize", _micNameSize];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicDrawEnabled", _drawMic];
                _mapControl setVariable ["BN_KOTH_casualtyHelpTexture", _helpTexture];
                _mapControl setVariable ["BN_KOTH_casualtyHelpColor", _helpColor];
                _mapControl setVariable ["BN_KOTH_casualtyHelpSize", _helpSize];
                _mapControl setVariable ["BN_KOTH_casualtyHelpNameSize", _helpNameSize];
                private _handlerId = _mapControl ctrlAddEventHandler ["Draw", {
                    params ["_mapControl"];
                    if (_mapControl getVariable ["BN_KOTH_playerMapMarkersMicDrawEnabled", false]) then {
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
                    };

                    {
                        _x params ["_position", "_label"];
                        private _size = _mapControl getVariable ["BN_KOTH_casualtyHelpSize", 28];
                        _mapControl drawIcon [
                            _mapControl getVariable ["BN_KOTH_casualtyHelpTexture", "\A3\ui_f\data\map\markers\military\warning_CA.paa"],
                            _mapControl getVariable ["BN_KOTH_casualtyHelpColor", [1, 0.25, 0.2, 1]],
                            _position,
                            _size,
                            _size,
                            0,
                            _label,
                            true,
                            _mapControl getVariable ["BN_KOTH_casualtyHelpNameSize", 0.04],
                            "PuristaMedium",
                            "right",
                            false
                        ];
                    } forEach (uiNamespace getVariable ["BN_KOTH_casualtyHelpMapDrawEntries", []]);
                }];
                _mapControl setVariable ["BN_KOTH_playerMapMarkersMicDrawHandler", _handlerId];
            };
        } forEach _mapControls;

        uiSleep 0.05;
    };

    missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicOverlayHandle", scriptNull];
};

missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicOverlayHandle", _handle];
true
