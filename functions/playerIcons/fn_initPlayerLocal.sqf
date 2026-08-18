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

private _playerIconsCfg = missionConfigFile >> "CfgBnKothPlayerIcons";
private _refreshInterval = getNumber (_playerIconsCfg >> "refreshIntervalSeconds");
if (_refreshInterval < 0.1) then {
    _refreshInterval = 0.5;
};

missionNamespace setVariable ["BN_KOTH_playerIconsEnabled", (getNumber (_playerIconsCfg >> "enabled")) > 0];
missionNamespace setVariable ["BN_KOTH_playerIconsRefreshInterval", _refreshInterval];
missionNamespace setVariable ["BN_KOTH_playerIconsTexture", getText (_playerIconsCfg >> "iconTexture")];
missionNamespace setVariable ["BN_KOTH_playerIconsColorArray", getArray (_playerIconsCfg >> "iconColor")];
missionNamespace setVariable ["BN_KOTH_playerIconsGroupColorArray", getArray (_playerIconsCfg >> "groupIconColor")];
missionNamespace setVariable ["BN_KOTH_playerIconsAlpha", (getNumber (_playerIconsCfg >> "iconAlpha")) max 0 min 1];
missionNamespace setVariable ["BN_KOTH_playerIconsShowPassengerCount", (getNumber (_playerIconsCfg >> "showPassengerCount")) > 0];
missionNamespace setVariable ["BN_KOTH_playerIconsShowDriverName", (getNumber (_playerIconsCfg >> "showDriverName")) > 0];
uiNamespace setVariable ["BN_KOTH_playerIconsDrawData", []];

if !(missionNamespace getVariable ["BN_KOTH_playerIconsLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [] call bn_koth_fnc_playerIcons_refresh;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_playerIconsLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_playerIconsLocalMissionEhId", _eventId];
};

private _refreshLoop = missionNamespace getVariable ["BN_KOTH_playerIconsLoopHandle", scriptNull];
if (_refreshLoop isEqualTo scriptNull || {scriptDone _refreshLoop}) then {
    private _loopHandle = [] spawn {
        while {hasInterface} do {
            try {
                [] call bn_koth_fnc_playerIcons_refresh;
            } catch {
                diag_log format ["[BN_KOTH][WARN] Map icon refresh failed; retrying. Error: %1", _exception];
            };

            private _interval = missionNamespace getVariable ["BN_KOTH_playerIconsRefreshInterval", 0.5];
            if (_interval < 0.1) then {
                _interval = 0.1;
            };

            uiSleep _interval;
        };

        missionNamespace setVariable ["BN_KOTH_playerIconsLoopHandle", scriptNull];
    };

    missionNamespace setVariable ["BN_KOTH_playerIconsLoopHandle", _loopHandle];
};

[] call bn_koth_fnc_playerIcons_refresh;

true