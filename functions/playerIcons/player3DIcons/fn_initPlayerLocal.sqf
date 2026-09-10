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
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};

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
missionNamespace setVariable ["BN_KOTH_player3DIconsIncludeLocalPlayer", (getNumber (_config >> "includeLocalPlayer")) > 0];
missionNamespace setVariable ["BN_KOTH_player3DIconsHeight", (getNumber (_config >> "heightAboveUnit")) max 0.1];
missionNamespace setVariable ["BN_KOTH_player3DIconsSize", (getNumber (_config >> "iconSize")) max 0.1];
missionNamespace setVariable ["BN_KOTH_player3DIconsNameSize", (getNumber (_config >> "nameSize")) max 0.01];
missionNamespace setVariable ["BN_KOTH_player3DIconsShadow", (getNumber (_config >> "shadow")) > 0];
missionNamespace setVariable ["BN_KOTH_player3DIconsMaxDistance", (getNumber (_config >> "maxDistance")) max 25];
private _candidateRefreshInterval = getNumber (_config >> "candidateRefreshIntervalSeconds");
if (_candidateRefreshInterval < 0.05) then {_candidateRefreshInterval = 0.1};
missionNamespace setVariable ["BN_KOTH_player3DIconsCandidateRefreshInterval", _candidateRefreshInterval];
missionNamespace setVariable ["BN_KOTH_player3DIconsNextCandidateRefreshAt", -1];
missionNamespace setVariable ["BN_KOTH_player3DIconsProximityVisibilityDistance", (getNumber (_config >> "proximityVisibilityDistance")) max 0];
missionNamespace setVariable ["BN_KOTH_player3DIconsWestColor", getArray (_config >> "westColor")];
missionNamespace setVariable ["BN_KOTH_player3DIconsEastColor", getArray (_config >> "eastColor")];
missionNamespace setVariable ["BN_KOTH_player3DIconsSameGroupColor", getArray (_config >> "sameGroupColor")];
missionNamespace setVariable ["BN_KOTH_player3DIconsEnemyMarkDuration", (getNumber (_config >> "temporaryEnemyMarkDuration")) max 0];
uiNamespace setVariable ["BN_KOTH_player3DIconsDrawData", []];
uiNamespace setVariable ["BN_KOTH_casualtyHelp3DDrawData", []];

private _helpTexture = getText (_config >> "casualtyHelpTexture");
if (_helpTexture isEqualTo "") then {_helpTexture = "\A3\ui_f\data\map\markers\military\warning_CA.paa"};
private _helpColor = getArray (_config >> "casualtyHelpColor");
if !(_helpColor isEqualType [] && {count _helpColor >= 4}) then {_helpColor = [1, 0.2, 0.15, 1]};
missionNamespace setVariable ["BN_KOTH_casualtyHelp3DTexture", _helpTexture];
missionNamespace setVariable ["BN_KOTH_casualtyHelp3DColor", _helpColor];
missionNamespace setVariable ["BN_KOTH_casualtyHelp3DSize", (getNumber (_config >> "casualtyHelpSize")) max 0.1];
missionNamespace setVariable ["BN_KOTH_casualtyHelp3DMaxDistance", (getNumber (missionConfigFile >> "CfgBnKothRespawn" >> "casualtyHelp3DMaxDistance")) max 1];

if !(missionNamespace getVariable ["BN_KOTH_player3DIconsRefreshLoopAdded", false]) then {
    private _refreshHandler = addMissionEventHandler ["EachFrame", {
        private _nextRefreshAt = missionNamespace getVariable ["BN_KOTH_player3DIconsNextCandidateRefreshAt", -1];
        if (diag_tickTime >= _nextRefreshAt) then {
            try {
                [] call bn_koth_fnc_player3DIcons_refresh;
            } catch {
                diag_log format ["[BN_KOTH][WARN] 3D icon refresh failed. Error: %1", _exception];
            };
            missionNamespace setVariable [
                "BN_KOTH_player3DIconsNextCandidateRefreshAt",
                diag_tickTime + (missionNamespace getVariable ["BN_KOTH_player3DIconsCandidateRefreshInterval", 0.1])
            ];
        };

        [] call bn_koth_fnc_player3DIcons_draw;
    }];

    missionNamespace setVariable ["BN_KOTH_player3DIconsRefreshLoopAdded", true];
    missionNamespace setVariable ["BN_KOTH_player3DIconsRefreshHandlerId", _refreshHandler];
};

[] call bn_koth_fnc_player3DIcons_refresh;

true
