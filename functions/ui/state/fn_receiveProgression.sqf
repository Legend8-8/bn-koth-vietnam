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

private _localProgression = missionNamespace getVariable [
    "BN_KOTH_playerProgressionLocal",
    createHashMap
];
if !(_localProgression isEqualType createHashMap) then {
    _localProgression = createHashMap;
};

{
    _localProgression set [_x, _progression get _x];
} forEach (keys _progression);

missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", _localProgression];

private _rewardAmount = _progression getOrDefault ["rewardAmount", _progression getOrDefault ["amount", 0]];
private _rewardReason = _progression getOrDefault ["rewardReason", _progression getOrDefault ["reason", ""]];
private _rewardType = toLower (_progression getOrDefault ["rewardType", "xp"]);
if !(_rewardAmount isEqualTo 0 || {_rewardReason isEqualTo ""}) then {
    private _reasonLabel = switch (toLower _rewardReason) do {
        case "kill": {"KILL"};
        case "control": {"OBJECTIVE"};
        case "priority": {"PRIORITY"};
        default {toUpper _rewardReason};
    };

    if (_rewardType isEqualTo "cash") then {
        private _cashSign = if (_rewardAmount > 0) then {"+"} else {""};
        systemChat format ["[CASH] %1 %2$%3", _reasonLabel, _cashSign, _rewardAmount];
    } else {
        systemChat format ["[XP] %1 +%2 XP", _reasonLabel, _rewardAmount];
    };
};

disableSerialization;
private _menuDisplay = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _menuDisplay) then {
    [] call bn_koth_fnc_menu_refresh;
};
