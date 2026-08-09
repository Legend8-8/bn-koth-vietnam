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

#include "..\..\ui\lobby\idcs.hpp"

params ["_display", "_viewModel"];

if (isNull _display) exitWith {};
if !(_viewModel isEqualType createHashMap) exitWith {};

(_display displayCtrl BN_KOTH_IDC_HEADER_STATUS) ctrlSetText (_viewModel getOrDefault ["statusTitle", "LOBBY"]);
(_display displayCtrl BN_KOTH_IDC_HEADER_SUBSTATUS) ctrlSetText (_viewModel getOrDefault ["statusSubtitle", "Waiting for mission state"]);
(_display displayCtrl BN_KOTH_IDC_HEADER_PLAYERS) ctrlSetText format [
    "%1 / %2 PLAYERS",
    _viewModel getOrDefault ["playerCount", 0],
    _viewModel getOrDefault ["maxPlayers", 64]
];
(_display displayCtrl BN_KOTH_IDC_HEADER_RIGHT_TITLE) ctrlSetText (_viewModel getOrDefault ["rightStatusTitle", "ROUND STATUS"]);
(_display displayCtrl BN_KOTH_IDC_HEADER_RIGHT_VALUE) ctrlSetText (_viewModel getOrDefault ["rightStatusValue", "WAITING FOR TEAMS"]);
(_display displayCtrl BN_KOTH_IDC_HEADER_INFO) ctrlSetText (_viewModel getOrDefault ["headerInfo", "Capture and hold the objective to earn score."]);
(_display displayCtrl BN_KOTH_IDC_BOTTOM_TITLE) ctrlSetText "MODE INFO";

(_display displayCtrl BN_KOTH_IDC_BOTTOM_DESCRIPTION) ctrlSetStructuredText parseText format [
    "<t size='1.04' color='#E8E2D6'>King of the Hill - Vietnam</t><br/><br/><t color='#D5D0C7'>Two teams fight to capture and hold the objective.</t><br/><t color='#BEB7AB'>Control the zone to earn %1 point every %2 seconds.</t><br/><t color='#BEB7AB'>Eliminate enemies, hold the zone, and defend your position.</t><br/><t color='#BEB7AB'>First team to reach %3 wins the round.</t>",
    _viewModel getOrDefault ["scoreTick", 1],
    _viewModel getOrDefault ["scoreTickInterval", 5],
    _viewModel getOrDefault ["scoreLimit", 100]
];
