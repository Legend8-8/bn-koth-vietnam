/*
    File: fn_draw.sqf
    Author: tylervip
    Description: Draws cached friendly player icons above their heads without labels.
    Execution: Client, from the local Draw3D mission event handler.
    Parameters: None
    Returns: Nothing
    Public: No
*/

if (!hasInterface || {isNull player} || {!alive player} || {[player] call bn_koth_fnc_respawn_isIncapacitated}) exitWith {};

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

private _helpTexture = missionNamespace getVariable ["BN_KOTH_casualtyHelp3DTexture", "\A3\ui_f\data\map\markers\military\warning_CA.paa"];
private _helpColor = missionNamespace getVariable ["BN_KOTH_casualtyHelp3DColor", [1, 0.2, 0.15, 1]];
private _helpSize = missionNamespace getVariable ["BN_KOTH_casualtyHelp3DSize", 0.85];
{
    _x params ["_position", "_label"];
    private _drawPosition = [_position select 0, _position select 1, (_position select 2) + _height];
    drawIcon3D [_helpTexture, _helpColor, _drawPosition, _helpSize, _helpSize, 0, _label, true, _nameSize, "PuristaMedium", "center", false];
} forEach (uiNamespace getVariable ["BN_KOTH_casualtyHelp3DDrawData", []]);
