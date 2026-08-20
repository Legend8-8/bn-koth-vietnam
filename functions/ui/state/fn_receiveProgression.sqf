/*
    File: fn_receiveProgression.sqf
    Author: Legend
    Description: Applies an authoritative server progression update to the local
        presentation copy and refreshes the deployed menu when it is open.
    Execution: Client
    Parameters:
        0: Progression payload <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params [["_progression", createHashMap, [createHashMap]]];

if (!hasInterface) exitWith {};

// Remote progression updates are server-to-client only. A listen-server host may
// also receive the update by direct local call from the authoritative server.
if (!isServer && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

if ((count _progression) == 0) exitWith {};

private _uid = _progression getOrDefault ["uid", ""];
private _xp = _progression getOrDefault ["xp", -1];
private _level = _progression getOrDefault ["level", -1];

if (_uid isEqualTo "" || {_xp < 0} || {_level < 1}) exitWith {};

private _localUid = if (!isNull player) then {getPlayerUID player} else {""};
if !(_localUid isEqualTo _uid) exitWith {};

missionNamespace setVariable [
    "BN_KOTH_playerProgressionLocal",
    createHashMapFromArray [
        ["uid", _uid],
        ["xp", _xp],
        ["level", _level]
    ]
];

disableSerialization;
private _menuDisplay = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _menuDisplay) then {
    [] call bn_koth_fnc_menu_refresh;
};
