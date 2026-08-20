/*
    File: fn_refreshLobbyHeader.sqf
    Author: Legend
    Description: Applies header and mode-info text to the lobby.
    Execution: Client
    Parameters:
        0: Lobby display <DISPLAY>
        1: Header/status view model <HASHMAP>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\lobby\idcs.hpp"

params ["_display", "_viewModel"];

if (isNull _display) exitWith {};
if !(_viewModel isEqualType createHashMap) exitWith {};

(_display displayCtrl BN_KOTH_IDC_HEADER_STATUS) ctrlSetText (_viewModel getOrDefault ["statusTitle", "LOBBY"]);
(_display displayCtrl BN_KOTH_IDC_HEADER_SUBSTATUS) ctrlSetText (_viewModel getOrDefault ["statusSubtitle", "Waiting for mission state"]);
private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _defaultMaxPlayers = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxPlayers")} else {100};
if (_defaultMaxPlayers < 1) then {
    _defaultMaxPlayers = 1;
};

private _scoreTick = _viewModel getOrDefault ["scoreTick", 1];
private _scoreTickInterval = _viewModel getOrDefault ["scoreTickInterval", 5];
private _scoreLimit = _viewModel getOrDefault ["scoreLimit", 100];

if (_scoreTick < 0) then {
    _scoreTick = 0;
};

if (_scoreTickInterval < 1) then {
    _scoreTickInterval = 1;
};

if (_scoreLimit < 1) then {
    _scoreLimit = 1;
};

private _pointLabel = if (_scoreTick isEqualTo 1) then {"point"} else {"points"};
private _secondLabel = if (_scoreTickInterval isEqualTo 1) then {"second"} else {"seconds"};

(_display displayCtrl BN_KOTH_IDC_HEADER_PLAYERS) ctrlSetText format [
    "%1 / %2",
    _viewModel getOrDefault ["playerCount", 0],
    _viewModel getOrDefault ["maxPlayers", _defaultMaxPlayers]
];
(_display displayCtrl BN_KOTH_IDC_HEADER_RIGHT_TITLE) ctrlSetText (_viewModel getOrDefault ["rightStatusTitle", "ROUND STATUS"]);
(_display displayCtrl BN_KOTH_IDC_HEADER_RIGHT_VALUE) ctrlSetText (_viewModel getOrDefault ["rightStatusValue", "WAITING FOR TEAMS"]);

private _playerName = toUpper (_viewModel getOrDefault ["playerName", profileName]);
private _playerLevel = (_viewModel getOrDefault ["playerLevel", 1]) max 1;
private _playerMaxLevel = (_viewModel getOrDefault ["playerMaxLevel", 270]) max 1;
private _playerXp = (_viewModel getOrDefault ["playerXp", 0]) max 0;
private _playerXpIntoLevel = (_viewModel getOrDefault ["playerXpIntoLevel", 0]) max 0;
private _playerXpRequired = (_viewModel getOrDefault ["playerXpRequired", 0]) max 0;
private _playerXpRatio = (_viewModel getOrDefault ["playerXpRatio", 1]) max 0 min 1;

(_display displayCtrl BN_KOTH_IDC_HEADER_RANK_BADGE) ctrlSetText str _playerLevel;
(_display displayCtrl BN_KOTH_IDC_HEADER_PLAYER_NAME) ctrlSetText _playerName;
(_display displayCtrl BN_KOTH_IDC_HEADER_PLAYER_LEVEL) ctrlSetText format ["LEVEL %1", _playerLevel];

private _xpCtrl = _display displayCtrl BN_KOTH_IDC_HEADER_XP;
if (_playerLevel >= _playerMaxLevel) then {
    _xpCtrl ctrlSetText format ["MAX | %1 XP", _playerXp];
} else {
    _xpCtrl ctrlSetText format ["%1 / %2 XP", round _playerXpIntoLevel, round _playerXpRequired];
};

disableSerialization;
private _xpTrack = _display displayCtrl BN_KOTH_IDC_BG_HEADER_XP_TRACK;
private _xpFill = _display displayCtrl BN_KOTH_IDC_BG_HEADER_XP_FILL;
private _trackPos = ctrlPosition _xpTrack;
_xpFill ctrlSetPosition [
    _trackPos select 0,
    _trackPos select 1,
    (_trackPos select 2) * _playerXpRatio,
    _trackPos select 3
];
_xpFill ctrlCommit 0;

(_display displayCtrl BN_KOTH_IDC_HEADER_INFO) ctrlSetText (_viewModel getOrDefault ["headerInfo", "Capture and hold the objective to earn score."]);
(_display displayCtrl BN_KOTH_IDC_BOTTOM_TITLE) ctrlSetText "MODE INFO";

(_display displayCtrl BN_KOTH_IDC_BOTTOM_DESCRIPTION) ctrlSetStructuredText parseText format [
    "<t size='1.04' color='#E8E2D6'>King of the Hill - Vietnam</t><br/><br/><t color='#D5D0C7'>Two teams fight to capture and hold the objective.</t><br/><t color='#BEB7AB'>Control the zone to earn %1 %2 every %3 %4.</t><br/><t color='#BEB7AB'>Eliminate enemies, hold the zone, and defend your position.</t><br/><t color='#BEB7AB'>First team to reach %5 wins the round.</t>",
    _scoreTick,
    _pointLabel,
    _scoreTickInterval,
    _secondLabel,
    _scoreLimit
];
