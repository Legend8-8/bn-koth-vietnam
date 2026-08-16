/*
    File: fn_menu_applyAssigned.sqf
    Author: GitHub Copilot
    Description: Sends pending assigned-equipment intent through the authoritative loadout mutation path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingAssigned", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _available = _pending getOrDefault ["available", false];
private _assignedIndex = _pending getOrDefault ["assignedIndex", -1];

if (!_available || {!(_assignedIndex isEqualType 0)} || {!(_assignedIndex in [0, 1, 2, 3, 4, 5])}) exitWith {
    ["ASSIGNED EQUIPMENT SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _itemClass = _pending getOrDefault ["itemClass", ""];
if !(_itemClass isEqualType "") then {
    _itemClass = "";
};

private _request = createHashMapFromArray [
    ["mutation", createHashMapFromArray [
        ["op", "set_assigned"],
        ["assignedIndex", _assignedIndex],
        ["itemClass", _itemClass]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["ASSIGNED EQUIPMENT REQUEST SENT."] call bn_koth_fnc_ui_notify;
true
