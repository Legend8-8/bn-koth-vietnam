/*
    File: fn_draw.sqf
    Author: tylervip
    Description: Draws cached friendly player icons above their heads without labels.
    Execution: Client, from the local Draw3D mission event handler.
    Parameters: None
    Returns: Nothing
    Public: No
*/

if (!hasInterface || {isNull player} || {!alive player}) exitWith {};
if !(missionNamespace getVariable ["BN_KOTH_player3DIconsEnabled", true]) exitWith {};

private _height = missionNamespace getVariable ["BN_KOTH_player3DIconsHeight", 2.2];
private _size = missionNamespace getVariable ["BN_KOTH_player3DIconsSize", 0.7];
private _shadow = missionNamespace getVariable ["BN_KOTH_player3DIconsShadow", true];
private _texture = missionNamespace getVariable ["BN_KOTH_player3DIconsTexture", "\A3\ui_f\data\map\markers\military\triangle_CA.paa"];
private _nameSize = missionNamespace getVariable ["BN_KOTH_player3DIconsNameSize", 0.035];
private _alpha = missionNamespace getVariable ["BN_KOTH_player3DIconsAlpha", 1];
private _proximityDistance = missionNamespace getVariable ["BN_KOTH_player3DIconsProximityVisibilityDistance", 25];
private _drawData = uiNamespace getVariable ["BN_KOTH_player3DIconsDrawData", []];

{
    _x params ["_position", "_direction", "_label", "_iconTexture", "_color", "_isLocal"];
    if !(_isLocal) then {
        private _drawPosition = [_position select 0, _position select 1, (_position select 2) + _height];
        private _screenPosition = worldToScreen _drawPosition;
        if (_screenPosition isEqualTo []) then {
            continue;
        };

        private _withinProximity = player distance _drawPosition <= _proximityDistance;
        private _lineOfSightBlocked = !_withinProximity && {!((lineIntersectsSurfaces [
            eyePos player,
            AGLToASL _drawPosition,
            player,
            objNull,
            true,
            1,
            "GEOM",
            "NONE"
        ]) isEqualTo [])};
        if (_lineOfSightBlocked) then {
            continue;
        };

        private _drawColor = +_color;
        if (_drawColor isEqualType []) then {
            private _existingAlpha = (_drawColor param [3, 1]) max 0 min 1;
            _drawColor set [3, (_existingAlpha * _alpha) max 0 min 1];
        };

        drawIcon3D [_iconTexture, _drawColor, _drawPosition, _size, _size, _direction, "", _shadow, _nameSize, "PuristaMedium", "center", false];
    };
} forEach _drawData;
