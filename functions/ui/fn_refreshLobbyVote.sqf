/*
    File: fn_refreshLobbyVote.sqf
    Author: Legend
    Description: Applies vote panel text, candidate cards, and countdown state.
    Execution: Client
    Parameters:
        0: Lobby display <DISPLAY>
        1: Vote-panel view model <HASHMAP>
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\lobby\idcs.hpp"

params ["_display", "_viewModel"];

if (isNull _display) exitWith {};
if !(_viewModel isEqualType createHashMap) exitWith {};

(_display displayCtrl BN_KOTH_IDC_VOTE_PREVIOUS_VALUE) ctrlSetText (_viewModel getOrDefault ["previousLocationName", "NONE"]);
(_display displayCtrl BN_KOTH_IDC_VOTE_HELP) ctrlSetText (_viewModel getOrDefault ["voteHelpText", "Vote for the next objective location."]);

private _previousImageCtrl = _display displayCtrl BN_KOTH_IDC_VOTE_PREVIOUS_IMAGE;
if !(isNull _previousImageCtrl) then {
    private _previousImage = _viewModel getOrDefault ["previousLocationImage", ""];
    if (_previousImage isEqualTo "") then {
        _previousImageCtrl ctrlSetText "";
        _previousImageCtrl ctrlShow false;
    } else {
        _previousImageCtrl ctrlSetText _previousImage;
        _previousImageCtrl ctrlShow true;
    };
};

private _candidateCtrlIds = [
    BN_KOTH_IDC_VOTE_CANDIDATE_1,
    BN_KOTH_IDC_VOTE_CANDIDATE_2,
    BN_KOTH_IDC_VOTE_CANDIDATE_3
];

private _totalCtrlIds = [
    BN_KOTH_IDC_VOTE_TOTAL_1,
    BN_KOTH_IDC_VOTE_TOTAL_2,
    BN_KOTH_IDC_VOTE_TOTAL_3
];

private _imageCtrlIds = [
    BN_KOTH_IDC_VOTE_IMAGE_1,
    BN_KOTH_IDC_VOTE_IMAGE_2,
    BN_KOTH_IDC_VOTE_IMAGE_3
];

private _descriptionCtrlIds = [
    BN_KOTH_IDC_VOTE_DESC_1,
    BN_KOTH_IDC_VOTE_DESC_2,
    BN_KOTH_IDC_VOTE_DESC_3
];

private _entries = _viewModel getOrDefault ["voteEntries", []];
private _voteAllowed = _viewModel getOrDefault ["voteAllowed", false];

for "_i" from 0 to 2 do {
    private _candidateCtrl = _display displayCtrl (_candidateCtrlIds select _i);
    private _totalCtrl = _display displayCtrl (_totalCtrlIds select _i);
    private _imageCtrl = _display displayCtrl (_imageCtrlIds select _i);
    private _descriptionCtrl = _display displayCtrl (_descriptionCtrlIds select _i);

    if (_i < count _entries) then {
        private _entry = _entries select _i;
        private _locationName = _entry select 0;
        private _description = _entry select 1;
        private _image = _entry select 2;
        private _votes = _entry select 3;
        private _isSelected = _entry select 4;

        _candidateCtrl ctrlSetText _locationName;
        _totalCtrl ctrlSetText str _votes;
        if !(isNull _imageCtrl) then {
            if (_image isEqualTo "") then {
                _imageCtrl ctrlSetText "";
                _imageCtrl ctrlShow false;
            } else {
                _imageCtrl ctrlSetText _image;
                _imageCtrl ctrlShow true;
            };
        };
        if !(isNull _descriptionCtrl) then {
            _descriptionCtrl ctrlSetText _description;
            _descriptionCtrl ctrlShow true;
        };
        _candidateCtrl ctrlSetBackgroundColor (if (_isSelected) then {[0.36, 0.28, 0.1, 0.96]} else {[0.13, 0.12, 0.1, 0.92]});
        _candidateCtrl ctrlSetTextColor (if (_isSelected) then {[0.98, 0.92, 0.7, 1]} else {[0.95, 0.94, 0.9, 0.96]});
        _candidateCtrl ctrlShow true;
        _totalCtrl ctrlShow true;
        _candidateCtrl ctrlEnable _voteAllowed;
    } else {
        _candidateCtrl ctrlSetText "--";
        _totalCtrl ctrlSetText "0";
        if !(isNull _imageCtrl) then {
            _imageCtrl ctrlSetText "";
            _imageCtrl ctrlShow false;
        };
        if !(isNull _descriptionCtrl) then {
            _descriptionCtrl ctrlSetText "";
            _descriptionCtrl ctrlShow false;
        };
        _candidateCtrl ctrlSetBackgroundColor [0.13, 0.12, 0.1, 0.92];
        _candidateCtrl ctrlSetTextColor [0.95, 0.94, 0.9, 0.96];
        _candidateCtrl ctrlShow false;
        _totalCtrl ctrlShow false;
        _candidateCtrl ctrlEnable false;
    };
};

(_display displayCtrl BN_KOTH_IDC_VOTE_TIMER) ctrlSetText (_viewModel getOrDefault ["voteTimerText", "VOTE CLOSED"]);
