/*
    File: fn_isSuppressor.sqf
    Author: Legend
    Description: Classifies one attachment from generated factual SourceItems metadata.
    Execution: Any
    Public: No
*/
params [["_itemClass", "", [""]]];
if (_itemClass isEqualTo "") exitWith {false};
private _settings = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogue = getText (_settings >> "catalogueClass");
if (_catalogue isEqualTo "") then {_catalogue = "CfgBnKothArsenal"};
private _cfg = missionConfigFile >> _catalogue >> "Equipment" >> "Compatibility" >> "SourceItems" >> (toLower _itemClass);
isClass _cfg && {toLower (getText (_cfg >> "itemType")) isEqualTo "suppressor"} && {"suppressor" in (getArray (_cfg >> "traits") apply {toLower _x})}
