/*
    File: fn_menu_layoutItemCards.sqf
    Author: Legend
    Description: Applies one two-column, two-row geometry to the shared fixed
        item-card control pool. It changes presentation geometry only.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
        1: Card area x <NUMBER>
        2: Card area y <NUMBER>
        3: Card area width <NUMBER>
        4: Card area height <NUMBER>
    Returns: None
    Public: No
*/

params [
    ["_display", displayNull, [displayNull]],
    ["_areaX", 0, [0]],
    ["_areaY", 0, [0]],
    ["_areaW", 0, [0]],
    ["_areaH", 0, [0]]
];

if (isNull _display || {_areaW <= 0} || {_areaH <= 0}) exitWith {};

private _cards = call bn_koth_fnc_menu_getItemCardControls;
private _gapX = safeZoneW * 0.008;
private _gapY = safeZoneH * 0.012;
private _cardW = (_areaW - _gapX) * 0.5;
private _cardH = (_areaH - _gapY) * 0.5;
private _innerX = safeZoneW * 0.007;
private _innerY = safeZoneH * 0.008;

{
    _x params ["_backgroundIdc", "_imageAreaIdc", "_imageIdc", "_nameIdc", "_statusIdc", "_overlayIdc", "_lockTextIdc", "_primaryActionIdc", "_secondaryActionIdc"];
    private _column = _forEachIndex mod 2;
    private _row = floor (_forEachIndex / 2);
    private _xPos = _areaX + _column * (_cardW + _gapX);
    private _yPos = _areaY + _row * (_cardH + _gapY);
    private _contentX = _xPos + _innerX;
    private _contentW = _cardW - _innerX * 2;
    private _actionGap = safeZoneW * 0.006;
    private _actionW = (_contentW - _actionGap) * 0.5;

    (_display displayCtrl _backgroundIdc) ctrlSetPosition [_xPos, _yPos, _cardW, _cardH];
    (_display displayCtrl _imageAreaIdc) ctrlSetPosition [_contentX, _yPos + _innerY, _contentW, _cardH * 0.48];
    (_display displayCtrl _imageIdc) ctrlSetPosition [_contentX, _yPos + _innerY, _contentW, _cardH * 0.48];
    (_display displayCtrl _nameIdc) ctrlSetPosition [_contentX, _yPos + _cardH * 0.52, _contentW, safeZoneH * 0.026];
    (_display displayCtrl _statusIdc) ctrlSetPosition [_contentX, _yPos + _cardH * 0.62, _contentW, safeZoneH * 0.022];
    (_display displayCtrl _overlayIdc) ctrlSetPosition [_xPos, _yPos, _cardW, _cardH];
    (_display displayCtrl _lockTextIdc) ctrlSetPosition [_contentX, _yPos + _cardH * 0.38, _contentW, safeZoneH * 0.035];
    (_display displayCtrl _primaryActionIdc) ctrlSetPosition [_contentX, _yPos + _cardH - safeZoneH * 0.048, _actionW, safeZoneH * 0.036];
    (_display displayCtrl _secondaryActionIdc) ctrlSetPosition [_contentX + _actionW + _actionGap, _yPos + _cardH - safeZoneH * 0.048, _actionW, safeZoneH * 0.036];

    {(_display displayCtrl _x) ctrlCommit 0} forEach _x;
} forEach _cards;
