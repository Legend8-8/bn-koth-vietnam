/*
    File: fn_menu_requestPerk.sqf
    Author: Legend
    Description: Sends one selected perk intent through the narrow server endpoint.
    Execution: Client
    Public: No
*/
params [["_operation", "", [""]], ["_perkId", "suppressor", [""]]];
if (!hasInterface) exitWith {false};
[_operation, _perkId] call bn_koth_fnc_progression_perks_request;
true
