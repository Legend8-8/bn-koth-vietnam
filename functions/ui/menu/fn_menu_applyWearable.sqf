/*
    File: fn_menu_applyWearable.sqf
    Author: Legend
    Description: Submits one explicit wearable selection as client intent. The
        server validates factual class and entitlement before application.
    Execution: Client
    Parameters:
        0: Wearable slot (uniform or backpack) <STRING>
        1: Requested classname <STRING>
    Returns: True when submitted <BOOL>
    Public: No
*/

params [["_slot", "", [""]], ["_itemClass", "", [""]]];
if (!hasInterface) exitWith {false};
private _slotLower = toLower _slot;
private _class = toLower _itemClass;
if !(_slotLower in ["uniform", "vest", "backpack", "headgear", "facewear", "binocular"]) exitWith {false};
if ((_slotLower isEqualTo "uniform") && {_class isEqualTo ""}) exitWith {false};

if (_slotLower isEqualTo "binocular") exitWith {
    [createHashMapFromArray [["mutation",createHashMapFromArray [["op","set_binocular"],["binocularClass",_class]]]]] call bn_koth_fnc_loadouts_request;
    true
};
private _classKey = format ["%1Class", _slotLower];
private _slotPayload = createHashMapFromArray [[_classKey, _class]];

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        [_slotLower, _slotPayload]
    ]]
];
[_request] call bn_koth_fnc_loadouts_request;
true
