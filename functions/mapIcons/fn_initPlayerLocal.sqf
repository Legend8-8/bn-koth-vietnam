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

private _mapIconsCfg = missionConfigFile >> "CfgBnKothMapIcons";
private _refreshInterval = getNumber (_mapIconsCfg >> "refreshIntervalSeconds");
if (_refreshInterval < 0.1) then {
    _refreshInterval = 0.5;
};

missionNamespace setVariable ["BN_KOTH_mapIconsEnabled", (getNumber (_mapIconsCfg >> "enabled")) > 0];
missionNamespace setVariable ["BN_KOTH_mapIconsRefreshInterval", _refreshInterval];
missionNamespace setVariable ["BN_KOTH_mapIconsTexture", getText (_mapIconsCfg >> "iconTexture")];
missionNamespace setVariable ["BN_KOTH_mapIconsColorArray", getArray (_mapIconsCfg >> "iconColor")];
missionNamespace setVariable ["BN_KOTH_mapIconsGroupColorArray", getArray (_mapIconsCfg >> "groupIconColor")];
missionNamespace setVariable ["BN_KOTH_mapIconsAlpha", (getNumber (_mapIconsCfg >> "iconAlpha")) max 0 min 1];
missionNamespace setVariable ["BN_KOTH_mapIconsShowPassengerCount", (getNumber (_mapIconsCfg >> "showPassengerCount")) > 0];
missionNamespace setVariable ["BN_KOTH_mapIconsShowDriverName", (getNumber (_mapIconsCfg >> "showDriverName")) > 0];
uiNamespace setVariable ["BN_KOTH_mapIconsDrawData", []];

if !(missionNamespace getVariable ["BN_KOTH_mapIconsLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [] call bn_koth_fnc_mapIcons_refresh;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_mapIconsLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_mapIconsLocalMissionEhId", _eventId];
};

private _refreshLoop = missionNamespace getVariable ["BN_KOTH_mapIconsLoopHandle", scriptNull];
if (_refreshLoop isEqualTo scriptNull || {scriptDone _refreshLoop}) then {
    private _loopHandle = [] spawn {
        while {hasInterface} do {
            try {
                [] call bn_koth_fnc_mapIcons_refresh;
            } catch {
                diag_log format ["[BN_KOTH][WARN] Map icon refresh failed; retrying. Error: %1", _exception];
            };

            private _interval = missionNamespace getVariable ["BN_KOTH_mapIconsRefreshInterval", 0.5];
            if (_interval < 0.1) then {
                _interval = 0.1;
            };

            uiSleep _interval;
        };

        missionNamespace setVariable ["BN_KOTH_mapIconsLoopHandle", scriptNull];
    };

    missionNamespace setVariable ["BN_KOTH_mapIconsLoopHandle", _loopHandle];
};

[] call bn_koth_fnc_mapIcons_refresh;

true