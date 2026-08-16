/*
    File: fn_menu_loadSessionKit.sqf
    Author: GitHub Copilot
    Description: Requests server-owned session kit load and re-apply.
    Execution: Client
    Parameters:
        0: Optional slot id <STRING>
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

params [["_slotId", "slot1", [""]]];

if (!hasInterface) exitWith {false};

private _request = createHashMapFromArray [
    ["mutation", createHashMapFromArray [
        ["op", "load_session_kit"],
        ["slotId", toLower _slotId]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["SESSION KIT LOAD REQUEST SENT."] call bn_koth_fnc_ui_notify;
true
