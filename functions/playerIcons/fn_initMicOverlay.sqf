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

private _playerIconsCfg = missionConfigFile >> "CfgBnKothPlayerIcons";
if ((getNumber (_playerIconsCfg >> "micOverlayEnabled")) <= 0) exitWith {false};

private _micTexture = getText (_playerIconsCfg >> "micTexture");
private _micColor = getArray (_playerIconsCfg >> "micColor");
private _micSize = getNumber (_playerIconsCfg >> "micSize");
private _micNameSize = getNumber (_playerIconsCfg >> "micNameSize");
private _micInputAction = getText (_playerIconsCfg >> "micInputAction");
private _iconAlpha = (getNumber (_playerIconsCfg >> "iconAlpha")) max 0 min 1;
private _iconTexture = getText (_playerIconsCfg >> "iconTexture");
private _micDisplayId = getNumber (_playerIconsCfg >> "micDisplayId");
private _micControlId = getNumber (_playerIconsCfg >> "micControlId");

if (_micTexture isEqualTo "") then {_micTexture = "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa"};
if !(_micColor isEqualType [] && {count _micColor >= 4}) then {_micColor = [1, 0.5, 0, 1]};
if (_micSize <= 0) then {_micSize = 24};
if (_micNameSize <= 0) then {_micNameSize = 0.04};
if (_micInputAction isEqualTo "") then {_micInputAction = "PushToTalk"};
if (_iconTexture isEqualTo "") then {_iconTexture = "\A3\ui_f\data\map\markers\military\triangle_CA.paa"};
if (_micDisplayId <= 0) then {_micDisplayId = 12};
if (_micControlId <= 0) then {_micControlId = 51};

private _existingHandle = missionNamespace getVariable ["BN_KOTH_playerIconsMicOverlayHandle", scriptNull];
if (_existingHandle isEqualType scriptNull && {!scriptDone _existingHandle}) exitWith {true};

private _handle = [_micTexture, _micColor, _micSize, _micNameSize, _micInputAction, _iconAlpha, _iconTexture, _micDisplayId, _micControlId] spawn {
    params ["_micTexture", "_micColor", "_micSize", "_micNameSize", "_micInputAction", "_iconAlpha", "_iconTexture", "_micDisplayId", "_micControlId"];

    while {hasInterface} do {
        private _isTalking = (inputAction _micInputAction) > 0;
        private _lastTalking = missionNamespace getVariable ["BN_KOTH_playerIconsMicTalking", !_isTalking];
        if !(_isTalking isEqualTo _lastTalking) then {
            missionNamespace setVariable ["BN_KOTH_playerIconsMicTalking", _isTalking];
            [player, _isTalking] remoteExecCall ["bn_koth_fnc_playerIcons_setVoiceState", 0];
        };

        private _mapDisplay = findDisplay _micDisplayId;
        if (!isNull _mapDisplay) then {
            private _mapControl = _mapDisplay displayCtrl _micControlId;
            if (!isNull _mapControl && {(_mapControl getVariable ["BN_KOTH_playerIconsMicDrawHandler", -1]) < 0}) then {
                _mapControl setVariable ["BN_KOTH_playerIconsMicTexture", _micTexture];
                _mapControl setVariable ["BN_KOTH_playerIconsMicColor", _micColor];
                _mapControl setVariable ["BN_KOTH_playerIconsMicSize", _micSize];
                _mapControl setVariable ["BN_KOTH_playerIconsMicNameSize", _micNameSize];
                _mapControl setVariable ["BN_KOTH_playerIconsMicInputAction", _micInputAction];
                _mapControl setVariable ["BN_KOTH_playerIconsAlpha", _iconAlpha];

                private _handlerId = _mapControl ctrlAddEventHandler ["Draw", {
                    params ["_mapControl"];

                    if (isNull player || {!alive player}) exitWith {};

                    private _isTalking = missionNamespace getVariable ["BN_KOTH_playerIconsMicTalking", false];
                    private _drawData = uiNamespace getVariable ["BN_KOTH_playerIconsDrawData", []];
                    {
                        _x params ["_position", "_direction", "_label", "_texture", "_color", "_isLocal", "_isTalking"];
                        private _drawTexture = _texture;
                        private _drawColor = _color;
                        private _drawLabel = _label;
                        private _drawSize = 1;
                        private _drawDirection = _direction;
                        if (_isTalking) then {
                            private _micDrawSize = _mapControl getVariable ["BN_KOTH_playerIconsMicSize", 24];
                            if !(_micDrawSize isEqualType 0) then {
                                _micDrawSize = 24;
                            };
                            _drawTexture = _mapControl getVariable ["BN_KOTH_playerIconsMicTexture", "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa"];
                            _drawColor = _mapControl getVariable ["BN_KOTH_playerIconsMicColor", [1, 1, 1, 1]];
                            _drawSize = _micDrawSize / 24;
                            _drawDirection = 0;
                        };

                        _mapControl drawIcon [_drawTexture, _drawColor, _position, 24 * _drawSize, 24 * _drawSize, _drawDirection, _drawLabel, true, _mapControl getVariable ["BN_KOTH_playerIconsMicNameSize", 0.04], "PuristaMedium", "right", false];
                    } forEach _drawData;
                }];

                _mapControl setVariable ["BN_KOTH_playerIconsMicDrawHandler", _handlerId];
            };
        };

        uiSleep 0.05;
    };

    missionNamespace setVariable ["BN_KOTH_playerIconsMicOverlayHandle", scriptNull];
};

missionNamespace setVariable ["BN_KOTH_playerIconsMicOverlayHandle", _handle];
true