/*
    File: fn_menu_saveSessionKit.sqf
    Author: Legend
    Description: Requests server-owned session kit save for the current intended loadout.
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
        ["op", "save_session_kit"],
        ["slotId", toLower _slotId]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
true
