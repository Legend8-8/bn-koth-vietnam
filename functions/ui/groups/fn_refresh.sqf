/*
    File: fn_refresh.sqf
    Author: Legend
    Description: Renders the latest targeted group presentation state.
    Execution: Client
    Parameters:
        0: Refresh selection-dependent controls only <BOOL>
    Returns: Whether an open display was refreshed <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\groups\idcs.hpp"

params [["_selectionOnly", false, [false]]];

if (!hasInterface) exitWith {false};
disableSerialization;
private _display = uiNamespace getVariable ["BN_KOTH_groupMenuDisplay", displayNull];
if (isNull _display) exitWith {false};

private _state = missionNamespace getVariable ["BN_KOTH_groupStateLocal", createHashMap];
if !(_state isEqualType createHashMap) then {_state = createHashMap};
private _available = _state getOrDefault ["availableGroups", []];
private _current = _state getOrDefault ["currentGroup", createHashMap];
private _inviteCandidates = _state getOrDefault ["inviteCandidates", []];
private _pendingInvite = _state getOrDefault ["pendingInvite", createHashMap];
private _mode = uiNamespace getVariable ["BN_KOTH_groupMenuMode", "MAIN"];
private _hasCurrent = _current isEqualType createHashMap && {(count _current) > 0};
private _isLeader = _hasCurrent && {_current getOrDefault ["isLeader", false]};
private _availableList = _display displayCtrl BN_KOTH_IDC_GROUP_AVAILABLE;
private _currentList = _display displayCtrl BN_KOTH_IDC_GROUP_CURRENT;

if (!_selectionOnly) then {
    private _availableSelection = if ((lbCurSel _availableList) >= 0) then {
        _availableList lbData (lbCurSel _availableList)
    } else {
        ""
    };
    private _currentSelection = if ((lbCurSel _currentList) >= 0) then {
        _currentList lbData (lbCurSel _currentList)
    } else {
        ""
    };

    lbClear _availableList;
    {
        private _memberCount = _x getOrDefault ["memberCount", 0];
        private _deployedCount = _x getOrDefault ["deployedCount", 0];
        private _row = _availableList lbAdd (_x getOrDefault ["label", "GROUP"]);
        _availableList lbSetData [_row, _x getOrDefault ["groupId", ""]];
        private _lockLabel = if (_x getOrDefault ["locked", false]) then {"LOCKED   "} else {""};
        _availableList lbSetTextRight [_row, format ["%1%2 %3", _lockLabel, _memberCount, if (_memberCount isEqualTo 1) then {"MEMBER"} else {"MEMBERS"}]];
        _availableList lbSetValue [_row, if (_x getOrDefault ["locked", false]) then {1} else {0}];
        _availableList lbSetTooltip [_row, format ["Leader: %1   %2/%3 deployed", _x getOrDefault ["leaderName", "Unknown"], _deployedCount, _memberCount]];
    } forEach _available;

    lbClear _currentList;
    if (_hasCurrent && {_mode isEqualTo "INVITE"}) then {
        {
            private _row = _currentList lbAdd (_x getOrDefault ["name", "Unknown"]);
            _currentList lbSetData [_row, _x getOrDefault ["uid", ""]];
        } forEach _inviteCandidates;
    } else {
    if (_hasCurrent) then {
        {
            private _isRowLeader = _x getOrDefault ["leader", false];
            private _deployed = _x getOrDefault ["deployed", false];
            private _stateLabel = toUpper (_x getOrDefault ["state", "NOT DEPLOYED"]);
            private _rightLabel = if (_isRowLeader) then {
                "LEADER"
            } else {
                if (_deployed) then {"DEPLOYED"} else {_stateLabel}
            };
            private _row = _currentList lbAdd (_x getOrDefault ["name", "Unknown"]);
            _currentList lbSetData [_row, _x getOrDefault ["uid", ""]];
            _currentList lbSetTextRight [_row, _rightLabel];
            _currentList lbSetTooltip [_row, if (_isRowLeader) then {
                format ["Group leader   %1", if (_deployed) then {"Deployed"} else {_stateLabel}]
            } else {
                if (_deployed) then {"Deployed"} else {_stateLabel}
            }];
        } forEach (_current getOrDefault ["members", []]);
    };
    };

    private _restoreSelection = {
        params ["_list", "_data"];
        private _row = -1;
        if !(_data isEqualTo "") then {
            for "_index" from 0 to ((lbSize _list) - 1) do {
                if ((_list lbData _index) isEqualTo _data) exitWith {_row = _index};
            };
        };
        _list lbSetCurSel _row;
    };
    [_availableList, _availableSelection] call _restoreSelection;
    [_currentList, _currentSelection] call _restoreSelection;
};

private _memberCount = if (_hasCurrent) then {_current getOrDefault ["memberCount", 0]} else {0};
private _role = if (_isLeader) then {"LEADER"} else {"MEMBER"};
(_display displayCtrl BN_KOTH_IDC_GROUP_STATUS) ctrlSetText (if (_hasCurrent) then {
    format ["%1   •   %2 %3   •   %4%5", _current getOrDefault ["label", "GROUP"], _memberCount, if (_memberCount isEqualTo 1) then {"MEMBER"} else {"MEMBERS"}, _role, if (_current getOrDefault ["locked", false]) then {"   •   LOCKED"} else {""}]
} else {
    "You're not currently in a group"
});

private _hasAvailable = (count _available) > 0;
_availableList ctrlShow _hasAvailable;
(_display displayCtrl BN_KOTH_IDC_GROUP_AVAILABLE_EMPTY) ctrlShow (!_hasAvailable);
private _hasPending = _pendingInvite isEqualType createHashMap && {(count _pendingInvite) > 0};
private _showInviteList = _hasCurrent && {_mode isEqualTo "INVITE"} && {(count _inviteCandidates) > 0};
private _showMemberList = _hasCurrent && {_mode isEqualTo "MAIN"};
_currentList ctrlShow (_showMemberList || {_showInviteList});
private _currentEmpty = _display displayCtrl BN_KOTH_IDC_GROUP_CURRENT_EMPTY;
_currentEmpty ctrlSetText (if (_mode isEqualTo "INVITE") then {"No eligible teammates available to invite."} else {"Create a group or join an existing squad."});
_currentEmpty ctrlShow ((!_hasCurrent && {!_hasPending}) || {_hasCurrent && {_mode isEqualTo "INVITE"} && {!_showInviteList}});
(_display displayCtrl BN_KOTH_IDC_GROUP_CURRENT_TITLE) ctrlSetText (if (_mode isEqualTo "INVITE") then {"INVITE PLAYER"} else {if (_mode isEqualTo "RENAME") then {"RENAME GROUP"} else {"MY GROUP"}});

private _availableRow = lbCurSel _availableList;
private _availableSelected = _availableRow >= 0 && {!((_availableList lbData _availableRow) isEqualTo "")} && {(_availableList lbValue _availableRow) isEqualTo 0};
private _currentRow = lbCurSel _currentList;
private _selectedUid = if (_currentRow >= 0) then {_currentList lbData _currentRow} else {""};
private _selectedMember = createHashMap;
if (_hasCurrent && {!(_selectedUid isEqualTo "")}) then {
    {
        if ((_x getOrDefault ["uid", ""]) isEqualTo _selectedUid) exitWith {_selectedMember = _x};
    } forEach (_current getOrDefault ["members", []]);
};
private _selectedNonLeader = (count _selectedMember) > 0 && {!(_selectedMember getOrDefault ["leader", false])};
private _selectedDeployed = _selectedNonLeader && {_selectedMember getOrDefault ["deployed", false]};

private _setActionState = {
    params ["_idc", "_visible", "_enabled"];
    private _control = _display displayCtrl _idc;
    _control ctrlShow _visible;
    _control ctrlEnable (_visible && {_enabled});
};
private _mainMode = _mode isEqualTo "MAIN";
private _inviteMode = _mode isEqualTo "INVITE";
private _renameMode = _mode isEqualTo "RENAME";
[BN_KOTH_IDC_GROUP_JOIN, _mainMode && {!_hasCurrent}, _availableSelected] call _setActionState;
[BN_KOTH_IDC_GROUP_CREATE, _mainMode && {!_hasCurrent}, _state getOrDefault ["canCreate", false]] call _setActionState;
[BN_KOTH_IDC_GROUP_LEAVE, _mainMode && {_hasCurrent}, _hasCurrent] call _setActionState;
[BN_KOTH_IDC_GROUP_KICK, _mainMode && {_isLeader}, _selectedNonLeader] call _setActionState;
[BN_KOTH_IDC_GROUP_TRANSFER, _mainMode && {_isLeader}, _selectedDeployed] call _setActionState;
[BN_KOTH_IDC_GROUP_DISBAND, _mainMode && {_isLeader}, _isLeader] call _setActionState;
[BN_KOTH_IDC_GROUP_INVITE, _mainMode && {_isLeader}, (count _inviteCandidates) > 0] call _setActionState;
[BN_KOTH_IDC_GROUP_RENAME, _mainMode && {_isLeader}, _isLeader] call _setActionState;
private _lockControl = _display displayCtrl BN_KOTH_IDC_GROUP_LOCK;
_lockControl ctrlSetText (if (_current getOrDefault ["locked", false]) then {"UNLOCK GROUP"} else {"LOCK GROUP"});
[BN_KOTH_IDC_GROUP_LOCK, _mainMode && {_isLeader}, _isLeader] call _setActionState;
private _renameEdit = _display displayCtrl BN_KOTH_IDC_GROUP_RENAME_EDIT;
_renameEdit ctrlShow _renameMode;
if (_renameMode && {!_selectionOnly} && {(ctrlText _renameEdit) isEqualTo ""}) then {_renameEdit ctrlSetText (_current getOrDefault ["label", ""])};
(_display displayCtrl BN_KOTH_IDC_GROUP_MODAL_CONFIRM) ctrlSetText (if (_inviteMode) then {"INVITE"} else {"CONFIRM"});
[BN_KOTH_IDC_GROUP_MODAL_CONFIRM, _inviteMode || {_renameMode}, if (_inviteMode) then {_selectedUid isNotEqualTo ""} else {!((ctrlText _renameEdit) isEqualTo "")}] call _setActionState;
[BN_KOTH_IDC_GROUP_MODAL_BACK, _inviteMode || {_renameMode}, true] call _setActionState;
private _pendingTitle = _display displayCtrl BN_KOTH_IDC_GROUP_PENDING_TITLE;
private _pendingDetail = _display displayCtrl BN_KOTH_IDC_GROUP_PENDING_DETAIL;
_pendingTitle ctrlShow (!_hasCurrent && {_hasPending} && {_mainMode});
_pendingDetail ctrlShow (!_hasCurrent && {_hasPending} && {_mainMode});
_pendingDetail ctrlSetText (if (_hasPending) then {format ["%1 from %2", _pendingInvite getOrDefault ["groupName", "GROUP"], _pendingInvite getOrDefault ["leaderName", "Unknown"]]} else {""});
[BN_KOTH_IDC_GROUP_INVITE_ACCEPT, !_hasCurrent && {_hasPending} && {_mainMode}, true] call _setActionState;
[BN_KOTH_IDC_GROUP_INVITE_DECLINE, !_hasCurrent && {_hasPending} && {_mainMode}, true] call _setActionState;
true
