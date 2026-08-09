/*
    File: fn_refreshLobbyCenter.sqf
    Author: Legend
    Description: Applies spectator/lobby center panel settings and player-facing copy.
    Execution: Client
    Parameters:
        0: Lobby display <DISPLAY>
        1: Center-panel view model <HASHMAP>
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\lobby\idcs.hpp"

params ["_display", "_viewModel"];

if (isNull _display) exitWith {};
if !(_viewModel isEqualType createHashMap) exitWith {};

(_display displayCtrl BN_KOTH_IDC_CENTER_INFO) ctrlSetStructuredText parseText format [
    "<t align='center' size='0.9' color='#D3C8B4'>ROUND SETTINGS</t><br/><br/><t align='left' color='#8F8778'>Score Limit</t><t align='right' color='#F0ECE2'>%1</t><br/><t align='left' color='#8F8778'>Round Time Limit</t><t align='right' color='#F0ECE2'>%2</t><br/><t align='left' color='#8F8778'>Vehicles</t><t align='right' color='#F0ECE2'>%3</t><br/><t align='left' color='#8F8778'>Friendly Fire</t><t align='right' color='#F0ECE2'>%4</t><br/><t align='left' color='#8F8778'>3rd Person</t><t align='right' color='#F0ECE2'>%5</t>",
    _viewModel getOrDefault ["scoreLimit", 100],
    _viewModel getOrDefault ["roundTimeLimitText", "NONE"],
    _viewModel getOrDefault ["vehiclesText", "SERVER RULES"],
    _viewModel getOrDefault ["friendlyFireText", "SERVER RULES"],
    _viewModel getOrDefault ["thirdPersonText", "SERVER RULES"]
];
