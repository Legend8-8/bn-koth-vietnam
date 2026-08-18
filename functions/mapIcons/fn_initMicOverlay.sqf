/*
    File: fn_initMicOverlay.sqf
    Author: tylervip
    Description: Draws map icons and the local player's microphone image while transmitting.
    Execution: Client
    Parameters:
        None
    Returns:
        True when the overlay monitor is started, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _mapIconsCfg = missionConfigFile >> "CfgBnKothMapIcons";
if ((getNumber (_mapIconsCfg >> "micOverlayEnabled")) <= 0) exitWith {false};

private _micTexture = getText (_mapIconsCfg >> "micTexture");
private _micColor = getArray (_mapIconsCfg >> "micColor");
private _micSize = getNumber (_mapIconsCfg >> "micSize");
private _micNameColor = getArray (_mapIconsCfg >> "micNameColor");
private _micNameSize = getNumber (_mapIconsCfg >> "micNameSize");
private _micInputAction = getText (_mapIconsCfg >> "micInputAction");
private _iconAlpha = (getNumber (_mapIconsCfg >> "iconAlpha")) max 0 min 1;
private _iconTexture = getText (_mapIconsCfg >> "iconTexture");
private _micDisplayId = getNumber (_mapIconsCfg >> "micDisplayId");
private _micControlId = getNumber (_mapIconsCfg >> "micControlId");

if (_micTexture isEqualTo "") then {_micTexture = "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa"};
if !(_micColor isEqualType [] && {count _micColor >= 4}) then {_micColor = [1, 0.5, 0, 1]};
if (_micSize <= 0) then {_micSize = 24};
if !(_micNameColor isEqualType [] && {count _micNameColor >= 4}) then {_micNameColor = [1, 1, 1, 1]};
if (_micNameSize <= 0) then {_micNameSize = 0.04};
if (_micInputAction isEqualTo "") then {_micInputAction = "PushToTalk"};
if (_iconTexture isEqualTo "") then {_iconTexture = "\A3\ui_f\data\map\markers\military\triangle_CA.paa"};
if (_micDisplayId <= 0) then {_micDisplayId = 12};
if (_micControlId <= 0) then {_micControlId = 51};

private _existingHandle = missionNamespace getVariable ["BN_KOTH_mapIconsMicOverlayHandle", scriptNull];
if (_existingHandle isEqualType scriptNull && {!scriptDone _existingHandle}) exitWith {true};

private _handle = [_micTexture, _micColor, _micSize, _micNameColor, _micNameSize, _micInputAction, _iconAlpha, _iconTexture, _micDisplayId, _micControlId] spawn {
    params ["_micTexture", "_micColor", "_micSize", "_micNameColor", "_micNameSize", "_micInputAction", "_iconAlpha", "_iconTexture", "_micDisplayId", "_micControlId"];

    while {hasInterface} do {
        private _mapDisplay = findDisplay _micDisplayId;
        if (!isNull _mapDisplay) then {
            private _mapControl = _mapDisplay displayCtrl _micControlId;
            if (!isNull _mapControl && {(_mapControl getVariable ["BN_KOTH_mapIconsMicDrawHandler", -1]) < 0}) then {
                _mapControl setVariable ["BN_KOTH_mapIconsMicTexture", _micTexture];
                _mapControl setVariable ["BN_KOTH_mapIconsMicColor", _micColor];
                _mapControl setVariable ["BN_KOTH_mapIconsMicSize", _micSize];
                _mapControl setVariable ["BN_KOTH_mapIconsMicNameColor", _micNameColor];
                _mapControl setVariable ["BN_KOTH_mapIconsMicNameSize", _micNameSize];
                _mapControl setVariable ["BN_KOTH_mapIconsMicInputAction", _micInputAction];
                _mapControl setVariable ["BN_KOTH_mapIconsAlpha", _iconAlpha];

                private _handlerId = _mapControl ctrlAddEventHandler ["Draw", {
                    params ["_mapControl"];

                    private _inputAction = _mapControl getVariable ["BN_KOTH_mapIconsMicInputAction", "PushToTalk"];
                    if (isNull player || {!alive player}) exitWith {};

                    private _isTalking = (inputAction _inputAction) > 0;
                    private _drawData = uiNamespace getVariable ["BN_KOTH_mapIconsDrawData", []];
                    {
                        _x params ["_position", "_direction", "_label", "_texture", "_color", "_isLocal"];
                        private _drawTexture = _texture;
                        private _drawColor = _color;
                        private _drawLabel = _label;
                        private _drawSize = 1;
                        private _drawTextColor = [1, 1, 1, 1];
                        private _drawDirection = _direction;
                        if (_isLocal && {_isTalking}) then {
                            private _micDrawSize = _mapControl getVariable ["BN_KOTH_mapIconsMicSize", 24];
                            if !(_micDrawSize isEqualType 0) then {
                                _micDrawSize = 24;
                            };
                            _drawTexture = _mapControl getVariable ["BN_KOTH_mapIconsMicTexture", "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa"];
                            _drawColor = _mapControl getVariable ["BN_KOTH_mapIconsMicColor", [1, 1, 1, 1]];
                            _drawTextColor = _mapControl getVariable ["BN_KOTH_mapIconsMicNameColor", [1, 1, 1, 1]];
                            _drawSize = _micDrawSize / 24;
                            _drawDirection = 0;
                        };

                        _mapControl drawIcon [_drawTexture, _drawColor, _position, 24 * _drawSize, 24 * _drawSize, _drawDirection, _drawLabel, true, _mapControl getVariable ["BN_KOTH_mapIconsMicNameSize", 0.04], "PuristaMedium", "right", _drawTextColor];
                    } forEach _drawData;
                }];

                _mapControl setVariable ["BN_KOTH_mapIconsMicDrawHandler", _handlerId];
            };
        };

        uiSleep 0.25;
    };

    missionNamespace setVariable ["BN_KOTH_mapIconsMicOverlayHandle", scriptNull];
};

missionNamespace setVariable ["BN_KOTH_mapIconsMicOverlayHandle", _handle];
true