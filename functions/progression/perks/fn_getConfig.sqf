/*
    File: fn_getConfig.sqf
    Author: Legend
    Description: Projects one authored perk definition into runtime metadata.
    Execution: Any
    Public: No
*/
params [["_perkId", "", [""]]];
private _id = toLower _perkId;
private _root = missionConfigFile >> "CfgBnKothPerks";
private _cfg = _root >> "Perks" >> _id;
if (_id isEqualTo "" || {!isClass _cfg}) exitWith {
    createHashMapFromArray [["success", false], ["code", "UNKNOWN_PERK"], ["perkId", _id]]
};
private _authoredId = toLower (getText (_cfg >> "id"));
if !(_authoredId isEqualTo _id) exitWith {
    createHashMapFromArray [["success", false], ["code", "INVALID_PERK_CONFIG"], ["perkId", _id]]
};
createHashMapFromArray [
    ["success", true], ["code", "PERK_CONFIGURED"], ["perkId", _id],
    ["displayName", getText (_cfg >> "displayName")],
    ["description", getText (_cfg >> "description")],
    ["purchaseCost", getNumber (_cfg >> "purchaseCost")],
    ["purchasable", (getNumber (_cfg >> "purchasable")) > 0],
    ["available", (getNumber (_cfg >> "available")) > 0],
    ["restrictedTraits", (getArray (_cfg >> "restrictedTraits")) apply {toLower _x}],
    ["restrictedClasses", (getArray (_cfg >> "restrictedClasses")) apply {toLower _x}],
    ["restrictionCode", getText (_cfg >> "restrictionCode")],
    ["restrictionMessage", getText (_cfg >> "restrictionMessage")],
    ["maxActivePerks", floor ((getNumber (_root >> "maxActivePerks")) max 0)]
]
