/*
    File: fn_draw.sqf
    Author: tylervip
    Description: Draws same-side player and vehicle icons above their world positions.
    Execution: Client, from the local Draw3D mission event handler.
    Parameters: None
    Returns: Nothing
    Public: No
*/

if (!hasInterface || {isNull player} || {!alive player}) exitWith {};
if !(missionNamespace getVariable ["BN_KOTH_player3DIconsEnabled", true]) exitWith {};

private _height = missionNamespace getVariable ["BN_KOTH_player3DIconsHeight", 2.2];
private _size = missionNamespace getVariable ["BN_KOTH_player3DIconsSize", 0.7];
private _nameSize = missionNamespace getVariable ["BN_KOTH_player3DIconsNameSize", 0.035];
private _shadow = missionNamespace getVariable ["BN_KOTH_player3DIconsShadow", true];
private _texture = missionNamespace getVariable ["BN_KOTH_player3DIconsTexture", "\A3\ui_f\data\map\markers\military\triangle_CA.paa"];
private _drawData = uiNamespace getVariable ["BN_KOTH_playerMapIconsDrawData", []];

{
    _x params ["_position", "_direction", "_label", "_texture", "_color", "_isLocal"];
    if (!_isLocal) then {
        private _drawPosition = [_position select 0, _position select 1, (_position select 2) + _height];
        drawIcon3D [_texture, _color, _drawPosition, _size, _size, _direction, _label, _shadow, _nameSize, "PuristaMedium", "center", [1, 1, 1, 1]];
    };
} forEach _drawData;