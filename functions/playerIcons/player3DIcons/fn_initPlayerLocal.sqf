/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Installs the client-local Draw3D handler for same-side player icons.
    Execution: Client
    Parameters:
        0: Expected representation unit <OBJECT>
    Returns: True when initialized, otherwise false <BOOL>
    Public: Yes
*/

params [["_targetUnit", objNull, [objNull]]];

if (!hasInterface) exitWith {false};

private _config = missionConfigFile >> "CfgBnKothPlayer3DIcons";
missionNamespace setVariable ["BN_KOTH_player3DIconsEnabled", (getNumber (_config >> "enabled")) > 0];
private _texture = getText (_config >> "texture");
if (_texture isEqualTo "") then {
    _texture = "\A3\ui_f\data\map\markers\military\triangle_CA.paa";
};
missionNamespace setVariable ["BN_KOTH_player3DIconsTexture", _texture];
missionNamespace setVariable ["BN_KOTH_player3DIconsHeight", (getNumber (_config >> "heightAboveUnit")) max 0.1];
missionNamespace setVariable ["BN_KOTH_player3DIconsSize", (getNumber (_config >> "iconSize")) max 0.1];
missionNamespace setVariable ["BN_KOTH_player3DIconsNameSize", (getNumber (_config >> "nameSize")) max 0.01];
missionNamespace setVariable ["BN_KOTH_player3DIconsShadow", (getNumber (_config >> "shadow")) > 0];

if !(missionNamespace getVariable ["BN_KOTH_player3DIconsDrawHandlerAdded", false]) then {
    addMissionEventHandler ["Draw3D", {
        [] call bn_koth_fnc_player3DIcons_draw;
    }];
    missionNamespace setVariable ["BN_KOTH_player3DIconsDrawHandlerAdded", true];
};

true