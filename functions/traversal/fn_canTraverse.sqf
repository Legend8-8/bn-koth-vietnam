/*
    File: fn_canTraverse.sqf
    Author: Mango Mongo
    Description: Applies the lightweight local player-state gate for traversal.
    Execution: Client; the supplied unit must be local
    Parameters:
        0: Unit to check <OBJECT>
    Returns:
        Validation result with valid and reason fields <HASHMAP>
    Public: Yes
*/

params [["_unit", objNull, [objNull]]];

private _response = createHashMapFromArray [
    ["valid", false],
    ["reason", "NO_PLAYER"]
];

if (!hasInterface) exitWith {
    _response set ["reason", "NO_INTERFACE"];
    _response
};
if ((getNumber (missionConfigFile >> "CfgBnKothTraversal" >> "enabled")) <= 0) exitWith {
    _response set ["reason", "DISABLED"];
    _response
};
if (isNull _unit) exitWith {_response};
if (!local _unit) exitWith {
    _response set ["reason", "PLAYER_NOT_LOCAL"];
    _response
};
if (!alive _unit) exitWith {
    _response set ["reason", "PLAYER_DEAD"];
    _response
};
if ((lifeState _unit) isEqualTo "INCAPACITATED") exitWith {
    _response set ["reason", "PLAYER_UNCONSCIOUS"];
    _response
};
if !(isNull (objectParent _unit)) exitWith {
    _response set ["reason", "PLAYER_IN_VEHICLE"];
    _response
};
if !(isNull (attachedTo _unit)) exitWith {
    _response set ["reason", "PLAYER_ATTACHED"];
    _response
};
if (underwater _unit) exitWith {
    _response set ["reason", "PLAYER_UNDERWATER"];
    _response
};
if ((stance _unit) isEqualTo "PRONE") exitWith {
    _response set ["reason", "PLAYER_PRONE"];
    _response
};
if !((_unit getVariable ["BN_KOTH_traversalState", "IDLE"]) isEqualTo "IDLE") exitWith {
    _response set ["reason", "ALREADY_TRAVERSING"];
    _response
};

private _weaponRestrictions = getArray (missionConfigFile >> "CfgBnKothTraversal" >> "weaponRestrictions");
if ((currentWeapon _unit) in _weaponRestrictions) exitWith {
    _response set ["reason", "WEAPON_RESTRICTED"];
    _response
};

_response set ["valid", true];
_response set ["reason", "OK"];
_response
