/*
    File: fn_menu_open.sqf
    Author: Legend
    Description: Opens the deployed menu on the local client.
    Execution: Client
    Parameters:
        0: Arsenal capability requested by the local menu opener <BOOL> (optional, default false)
        1: Actual local action target mapboard <OBJECT> (optional)
    Returns:
        True when open, otherwise false <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [
    ["_arsenalEnabled", false, [true]],
    ["_arsenalBoard", objNull, [objNull]]
];

if (!hasInterface) exitWith {false};
if ([player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {
    private _uid = getPlayerUID player;
    private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
    diag_log format [
        "[BN_KOTH][INFO] menu_open denied reason=INCAPACITATED lifeState=%1 vnIncap=%2 playerState=%3 roundState=%4",
        lifeState player,
        player getVariable ["vn_revive_incapacitated", false],
        _playerStates getOrDefault [_uid, ""],
        missionNamespace getVariable ["BN_KOTH_roundState", ""]
    ];
    false
};

["", "RESUBMIT"] call bn_koth_fnc_menu_setSpawnKit;

uiNamespace setVariable ["BN_KOTH_menuArsenalEnabled", _arsenalEnabled];
uiNamespace setVariable ["BN_KOTH_menuArsenalBoardNetId", if (isNull _arsenalBoard) then {""} else {netId _arsenalBoard}];

disableSerialization;

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_MENU;
};

if (!isNull _display) exitWith {
    ['LOADOUT'] call bn_koth_fnc_menu_refresh;
    [] call bn_koth_fnc_ui_requestState;
    [createHashMapFromArray [["mutation", createHashMapFromArray [["op", "snapshot"]]]]] call bn_koth_fnc_loadouts_request;
    true
};

uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", ""];

private _opened = createDialog "BN_KOTH_RscMenu";
if (_opened) then {
    ['LOADOUT'] call bn_koth_fnc_menu_refresh;
    [] call bn_koth_fnc_ui_requestState;
    [createHashMapFromArray [["mutation", createHashMapFromArray [["op", "snapshot"]]]]] call bn_koth_fnc_loadouts_request;
};

_opened
