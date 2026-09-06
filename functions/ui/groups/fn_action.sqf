/*
    File: fn_action.sqf
    Author: Legend
    Description: Submits one narrow Group Menu action using selected presentation IDs.
    Execution: Client
    Parameters:
        0: Operation <STRING>
    Returns: Whether a request was submitted <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\groups\idcs.hpp"

params [["_operation", "", [""]]];
if (!hasInterface) exitWith {false};
private _display = uiNamespace getVariable ["BN_KOTH_groupMenuDisplay", displayNull];
if (isNull _display) exitWith {false};

_operation = toUpper _operation;
if (_operation in ["OPEN_INVITE", "OPEN_RENAME", "BACK"]) exitWith {
    uiNamespace setVariable ["BN_KOTH_groupMenuMode", switch (_operation) do {case "OPEN_INVITE": {"INVITE"}; case "OPEN_RENAME": {"RENAME"}; default {"MAIN"}}];
    if (_operation isEqualTo "OPEN_RENAME") then {
        private _state = missionNamespace getVariable ["BN_KOTH_groupStateLocal", createHashMap];
        private _current = _state getOrDefault ["currentGroup", createHashMap];
        (_display displayCtrl BN_KOTH_IDC_GROUP_RENAME_EDIT) ctrlSetText (_current getOrDefault ["label", ""]);
    };
    [] call bn_koth_fnc_groupMenu_refresh;
    true
};
if (_operation isEqualTo "TOGGLE_LOCK") then {
    private _state = missionNamespace getVariable ["BN_KOTH_groupStateLocal", createHashMap];
    private _current = _state getOrDefault ["currentGroup", createHashMap];
    _operation = if (_current getOrDefault ["locked", false]) then {"UNLOCK"} else {"LOCK"};
};
if (_operation isEqualTo "MODAL_CONFIRM") then {
    private _mode = uiNamespace getVariable ["BN_KOTH_groupMenuMode", "MAIN"];
    if (_mode isEqualTo "RENAME") then {
        _operation = "RENAME";
    } else {
        if (_mode isEqualTo "INVITE") then {_operation = "INVITE"};
    };
};
private _target = "";
if (_operation isEqualTo "JOIN") then {
    private _list = _display displayCtrl BN_KOTH_IDC_GROUP_AVAILABLE;
    private _row = lbCurSel _list;
    if (_row < 0) exitWith {};
    _target = _list lbData _row;
};
if (_operation in ["KICK", "TRANSFER", "INVITE"]) then {
    private _list = _display displayCtrl BN_KOTH_IDC_GROUP_CURRENT;
    private _row = lbCurSel _list;
    if (_row < 0) exitWith {};
    _target = _list lbData _row;
};
if (_operation isEqualTo "RENAME") then {
    _target = ctrlText (_display displayCtrl BN_KOTH_IDC_GROUP_RENAME_EDIT);
};
if ((_operation in ["JOIN", "KICK", "TRANSFER", "INVITE", "RENAME"]) && {_target isEqualTo ""}) exitWith {false};

[_operation, _target] call bn_koth_fnc_groups_request;
if (_operation in ["INVITE", "RENAME"]) then {
    uiNamespace setVariable ["BN_KOTH_groupMenuMode", "MAIN"];
    [] call bn_koth_fnc_groupMenu_refresh;
};
true
