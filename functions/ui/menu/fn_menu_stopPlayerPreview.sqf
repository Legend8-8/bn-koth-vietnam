/*
    File: fn_menu_stopPlayerPreview.sqf
    Author: Legend
    Description: Stops and destroys the client-local Arsenal player preview.
    Execution: Client
    Parameters: None
    Returns: None
    Public: No
*/

if (!hasInterface) exitWith {};

private _camera = uiNamespace getVariable ["BN_KOTH_menuPlayerPreviewCamera", objNull];
if !(isNull _camera) then {
    _camera cameraEffect ["Terminate", "Back"];
    camDestroy _camera;
};
uiNamespace setVariable ["BN_KOTH_menuPlayerPreviewCamera", objNull];
