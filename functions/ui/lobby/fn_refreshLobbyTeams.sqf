/*
    File: fn_refreshLobbyTeams.sqf
    Author: Legend
    Description: Applies roster, count, and join-button state to WEST and EAST lobby panels.
    Execution: Client
    Parameters:
        0: Lobby display <DISPLAY>
        1: Team view model <HASHMAP>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\lobby\idcs.hpp"

params ["_display", "_viewModel"];

if (isNull _display) exitWith {};
if !(_viewModel isEqualType createHashMap) exitWith {};

private _westCount = _viewModel getOrDefault ["westCount", 0];
private _eastCount = _viewModel getOrDefault ["eastCount", 0];
private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _defaultTeamCap = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxTeamPlayers")} else {50};
if (_defaultTeamCap < 1) then {
    _defaultTeamCap = 1;
};

private _teamCap = _viewModel getOrDefault ["teamCap", _defaultTeamCap];
if (_teamCap < 1) then {
    _teamCap = 1;
};

private _westRows = _viewModel getOrDefault ["westRows", []];
private _eastRows = _viewModel getOrDefault ["eastRows", []];
private _myAssignedSide = _viewModel getOrDefault ["myAssignedSide", sideUnknown];
private _selectionLocked = _viewModel getOrDefault ["selectionLocked", false];
private _westFull = _westCount >= _teamCap;
private _eastFull = _eastCount >= _teamCap;

(_display displayCtrl BN_KOTH_IDC_WEST_COUNT) ctrlSetText format ["%1 / %2", _westCount, _teamCap];
(_display displayCtrl BN_KOTH_IDC_EAST_COUNT) ctrlSetText format ["%1 / %2", _eastCount, _teamCap];

private _renderRows = {
    params ["_ctrl", "_rows"];

    lbClear _ctrl;
    private _emptyPicture = "#(argb,8,8,3)color(0,0,0,0)";
    {
        private _entry = _x;
        private _text = _entry select 0;
        private _isCurrent = _entry select 1;
        private _level = _entry param [2, 1, [0]];
        private _isPlayerRow = _entry param [3, false, [false]];
        private _rowIndex = _ctrl lbAdd _text;
        private _rank = if (_isPlayerRow) then {[_level] call bn_koth_fnc_progression_resolveRankPresentation} else {createHashMap};
        private _hasIcon = _rank getOrDefault ["hasIcon", false];
        private _pictureColor = _rank getOrDefault ["color", [1, 1, 1, 0]];

        _ctrl lbSetPicture [_rowIndex, if (_hasIcon) then {_rank getOrDefault ["icon", _emptyPicture]} else {_emptyPicture}];
        _ctrl lbSetPictureColor [_rowIndex, _pictureColor];
        _ctrl lbSetPictureColorSelected [_rowIndex, _pictureColor];

        if (_isCurrent) then {
            _ctrl lbSetColor [_rowIndex, [0.96, 0.83, 0.34, 1]];
        } else {
            _ctrl lbSetColor [_rowIndex, [1, 1, 1, 0.86]];
        };

        _ctrl lbSetSelectColor [_rowIndex, [1, 1, 1, 1]];
    } forEach _rows;

    _ctrl lbSetCurSel -1;
};

[_display displayCtrl BN_KOTH_IDC_WEST_ROSTER, _westRows] call _renderRows;
[_display displayCtrl BN_KOTH_IDC_EAST_ROSTER, _eastRows] call _renderRows;

private _westJoinCtrl = _display displayCtrl BN_KOTH_IDC_WEST_JOIN;
private _eastJoinCtrl = _display displayCtrl BN_KOTH_IDC_EAST_JOIN;

_westJoinCtrl ctrlEnable (!_selectionLocked && {!_westFull});
_eastJoinCtrl ctrlEnable (!_selectionLocked && {!_eastFull});

_westJoinCtrl ctrlSetBackgroundColor [0.1, 0.34, 0.63, 0.92];
_eastJoinCtrl ctrlSetBackgroundColor [0.62, 0.16, 0.14, 0.92];

_westJoinCtrl ctrlSetText (if (_westFull) then {"WEST FULL"} else {"JOIN WEST TEAM"});
_eastJoinCtrl ctrlSetText (if (_eastFull) then {"EAST FULL"} else {"JOIN EAST TEAM"});

if (_myAssignedSide isEqualTo west) then {
    _westJoinCtrl ctrlSetText "RETURN TO LOBBY";
    if (!_eastFull) then {
        _eastJoinCtrl ctrlSetText "JOIN EAST TEAM";
    };
    _westJoinCtrl ctrlSetBackgroundColor [0.4, 0.34, 0.12, 0.92];
};

if (_myAssignedSide isEqualTo east) then {
    if (!_westFull) then {
        _westJoinCtrl ctrlSetText "JOIN WEST TEAM";
    };
    _eastJoinCtrl ctrlSetText "RETURN TO LOBBY";
    _eastJoinCtrl ctrlSetBackgroundColor [0.4, 0.34, 0.12, 0.92];
};

if (_myAssignedSide isEqualTo sideUnknown) then {
    _westJoinCtrl ctrlSetText (if (_westFull) then {"WEST FULL"} else {"JOIN WEST TEAM"});
    _eastJoinCtrl ctrlSetText (if (_eastFull) then {"EAST FULL"} else {"JOIN EAST TEAM"});
};
