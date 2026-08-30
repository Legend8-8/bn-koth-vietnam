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
private _configuredEnabled = (getNumber (_config >> "enabled")) > 0;
private _profileEnabled = (["player3DIconsEnabled"] call bn_koth_fnc_escMenu_options_getValue) > 0;
missionNamespace setVariable ["BN_KOTH_player3DIconsEnabled", _configuredEnabled && _profileEnabled];
missionNamespace setVariable ["BN_KOTH_player3DIconsAlpha", ([("player3DIconsAlpha")] call bn_koth_fnc_escMenu_options_getValue) max 0 min 1];
private _texture = getText (_config >> "texture");
if (_texture isEqualTo "") then {
    _texture = "\A3\ui_f\data\map\markers\military\triangle_CA.paa";
};
missionNamespace setVariable ["BN_KOTH_player3DIconsTexture", _texture];
missionNamespace setVariable ["BN_KOTH_player3DIconsHeight", (getNumber (_config >> "heightAboveUnit")) max 0.1];
missionNamespace setVariable ["BN_KOTH_player3DIconsSize", (getNumber (_config >> "iconSize")) max 0.1];
missionNamespace setVariable ["BN_KOTH_player3DIconsNameSize", (getNumber (_config >> "nameSize")) max 0.01];
missionNamespace setVariable ["BN_KOTH_player3DIconsShadow", (getNumber (_config >> "shadow")) > 0];
missionNamespace setVariable ["BN_KOTH_player3DIconsMaxDistance", (getNumber (_config >> "maxDistance")) max 25];
missionNamespace setVariable ["BN_KOTH_player3DIconsProximityVisibilityDistance", (getNumber (_config >> "proximityVisibilityDistance")) max 0];
missionNamespace setVariable ["BN_KOTH_player3DIconsWestColor", getArray (_config >> "westColor")];
missionNamespace setVariable ["BN_KOTH_player3DIconsEastColor", getArray (_config >> "eastColor")];
missionNamespace setVariable ["BN_KOTH_player3DIconsSameGroupColor", getArray (_config >> "sameGroupColor")];
missionNamespace setVariable ["BN_KOTH_player3DIconsEnemyMarkDuration", (getNumber (_config >> "temporaryEnemyMarkDuration")) max 0];
uiNamespace setVariable ["BN_KOTH_player3DIconsDrawData", []];

if !(missionNamespace getVariable ["BN_KOTH_player3DIconsRefreshLoopAdded", false]) then {
    private _refreshHandler = addMissionEventHandler ["EachFrame", {
        try {
            [] call bn_koth_fnc_player3DIcons_refresh;
        } catch {
            diag_log format ["[BN_KOTH][WARN] 3D icon refresh failed. Error: %1", _exception];
        };

        [] call bn_koth_fnc_player3DIcons_draw;
    }];

    missionNamespace setVariable ["BN_KOTH_player3DIconsRefreshLoopAdded", true];
    missionNamespace setVariable ["BN_KOTH_player3DIconsRefreshHandlerId", _refreshHandler];
};

[] call bn_koth_fnc_player3DIcons_refresh;

true
