/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Initializes the client-local map icon subsystem.
    Execution: Client
    Parameters:
        0: Expected representation unit <OBJECT>
    Returns:
        True when the subsystem is initialized, otherwise false <BOOL>
    Public: Yes
*/

params [["_targetUnit", objNull, [objNull]]];

if (!hasInterface) exitWith {false};

if (!isNull _targetUnit && {!(_targetUnit isEqualTo player)}) then {
    private _deadline = time + 5;
    waitUntil {
        (player isEqualTo _targetUnit) || {time >= _deadline}
    };
};

if (isNull player) exitWith {false};

private _playerMapIconsCfg = missionConfigFile >> "CfgBnKothPlayerMapIcons";
private _refreshInterval = getNumber (_playerMapIconsCfg >> "refreshIntervalSeconds");
if (_refreshInterval < 0.1) then {
    _refreshInterval = 0.5;
};

missionNamespace setVariable ["BN_KOTH_playerMapIconsEnabled", (getNumber (_playerMapIconsCfg >> "enabled")) > 0];
missionNamespace setVariable ["BN_KOTH_playerMapIconsRefreshInterval", _refreshInterval];
missionNamespace setVariable ["BN_KOTH_playerMapIconsTexture", getText (_playerMapIconsCfg >> "iconTexture")];
missionNamespace setVariable ["BN_KOTH_playerMapIconsColorArray", getArray (_playerMapIconsCfg >> "iconColor")];
missionNamespace setVariable ["BN_KOTH_playerMapIconsGroupColorArray", getArray (_playerMapIconsCfg >> "groupIconColor")];
missionNamespace setVariable ["BN_KOTH_playerMapIconsAlpha", (getNumber (_playerMapIconsCfg >> "iconAlpha")) max 0 min 1];
missionNamespace setVariable ["BN_KOTH_playerMapIconsShowPassengerCount", (getNumber (_playerMapIconsCfg >> "showPassengerCount")) > 0];
missionNamespace setVariable ["BN_KOTH_playerMapIconsShowDriverName", (getNumber (_playerMapIconsCfg >> "showDriverName")) > 0];
uiNamespace setVariable ["BN_KOTH_playerMapIconsDrawData", []];

if !(missionNamespace getVariable ["BN_KOTH_playerMapIconsLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [] call bn_koth_fnc_playerMapIcons_refresh;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_playerMapIconsLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_playerMapIconsLocalMissionEhId", _eventId];
};

private _refreshLoop = missionNamespace getVariable ["BN_KOTH_playerMapIconsLoopHandle", scriptNull];
if (_refreshLoop isEqualTo scriptNull || {scriptDone _refreshLoop}) then {
    private _loopHandle = [] spawn {
        while {hasInterface} do {
            try {
                [] call bn_koth_fnc_playerMapIcons_refresh;
            } catch {
                diag_log format ["[BN_KOTH][WARN] Map icon refresh failed; retrying. Error: %1", _exception];
            };

            private _interval = missionNamespace getVariable ["BN_KOTH_playerMapIconsRefreshInterval", 0.5];
            if (_interval < 0.1) then {
                _interval = 0.1;
            };

            uiSleep _interval;
        };

        missionNamespace setVariable ["BN_KOTH_playerMapIconsLoopHandle", scriptNull];
    };

    missionNamespace setVariable ["BN_KOTH_playerMapIconsLoopHandle", _loopHandle];
};

[] call bn_koth_fnc_playerMapIcons_refresh;
[] call bn_koth_fnc_playerMapIcons_initMicOverlay;

true