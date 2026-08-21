/*
    File: fn_menu_startPlayerPreview.sqf
    Author: Legend
    Description: Starts the client-local Arsenal player render target using
        the current controlled player representation.
    Execution: Client
    Parameters: 0: Arsenal display <DISPLAY>
    Returns: True when the preview starts, otherwise false <BOOL>
    Public: No
*/
#include "..\..\..\ui\menu\idcs.hpp"

params [["_display", displayNull, [displayNull]]];
if (!hasInterface || {isNull _display} || {isNull player}) exitWith {false};

[] call bn_koth_fnc_menu_stopPlayerPreview;

private _previewControl = _display displayCtrl BN_KOTH_IDC_MENU_PLAYER_PREVIEW;
if (isNull _previewControl) exitWith {false};

private _camera = "camera" camCreate [0, 0, 0];
if (isNull _camera) exitWith {false};

_camera camSetTarget player;
_camera camSetRelPos [0, 4.2, 1.15];
_camera camSetFov 0.52;
_camera camCommit 0;
_camera cameraEffect ["Internal", "Back", "BN_KOTH_ArsenalPlayer"];

_previewControl ctrlSetText "#(argb,512,512,1)r2t(BN_KOTH_ArsenalPlayer,1.0)";
uiNamespace setVariable ["BN_KOTH_menuPlayerPreviewCamera", _camera];
true
