/*
    File: fn_build_openMenu.sqf
    Author: tylervip
    Description: Opens a simple custom build menu so players can choose a configured fortification without the fragile SOG wheel dependency.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if !(call bn_koth_fnc_build_canBuild) exitWith {
    hint "Build menu unavailable right now.";
};

if (missionNamespace getVariable ["BN_KOTH_buildPlacementActive", false]) exitWith {
    hint "A build placement is already active.";
};

private _buildCfg = missionConfigFile >> "CfgBnKothBuild";
if !(isClass _buildCfg) exitWith {
    hint "Build configuration is unavailable.";
};

private _root = _buildCfg >> "Objects";
private _catalog = [];

{
    private _key = configName _x;
    private _className = getText (_x >> "classname");
    if (_className isEqualTo "") then {continue;};

    private _displayName = getText (_x >> "displayName");
    if (_displayName isEqualTo "") then {_displayName = _key;};

    private _category = getText (_x >> "category");
    if (_category isEqualTo "") then {_category = "General";};

    private _cost = getNumber (_x >> "cost");
    _catalog pushBack [_key, _displayName, _category, _className, _cost];
} forEach ("true" configClasses _root);

if ((count _catalog) <= 0) exitWith {
    hint "No buildable objects are configured.";
};

private _displayId = 6900;
if !(isNull (findDisplay _displayId)) then {
    closeDialog 0;
};

private _opened = createDialog "BN_KOTH_RscBuildMenu";
if !(_opened) exitWith {
    hint "Failed to open build menu.";
};

waitUntil {!isNull (findDisplay _displayId)};
private _display = findDisplay _displayId;
private _list = _display displayCtrl 6901;
private _info = _display displayCtrl 6904;

lbClear _list;

{
    _x params ["_key", "_displayName", "_category", "_className", "_cost"];
    private _index = _list lbAdd format ["%1  [%2]  %3", _displayName, _category, _cost];
    _list lbSetData [_index, _key];
    _list lbSetTooltip [_index, format ["%1\n%2\nCost: %3\nClass: %4", _displayName, _category, _cost, _className]];
} forEach _catalog;

_list lbSetCurSel 0;

private _selectedKey = _list lbData 0;
missionNamespace setVariable ["BN_KOTH_buildMenuCatalog", _catalog];
missionNamespace setVariable ["BN_KOTH_buildMenuSelectedKey", _selectedKey];

_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrlList", "_index"];
    private _display = ctrlParent _ctrlList;
    if (isNull _display) exitWith {};
    private _info = _display displayCtrl 6904;
    private _catalog = missionNamespace getVariable ["BN_KOTH_buildMenuCatalog", []];
    if ((count _catalog) <= 0) exitWith {
        _info ctrlSetStructuredText parseText "<t size='0.9'>No build data available.</t>";
    };

    private _key = _ctrlList lbData _index;
    private _entry = [];
    {
        if ((_x select 0) isEqualTo _key) exitWith {_entry = _x};
    } forEach _catalog;

    if ((count _entry) <= 0) exitWith {
        _info ctrlSetStructuredText parseText "<t size='0.9'>No selection.</t>";
    };

    _entry params ["_itemKey", "_displayName", "_category", "_className", "_cost"];
    private _text = format [
        "<t size='0.8' color='#EDE7DA'>%1</t><br/><t size='0.7' color='#C4C9C1'>%2</t><br/><t size='0.7' color='#C9D5A7'>Cost: %3</t><br/><t size='0.7' color='#D9C9A6'>Class: %4</t>",
        _displayName,
        _category,
        _cost,
        _className
    ];
    _info ctrlSetStructuredText parseText _text;
    missionNamespace setVariable ["BN_KOTH_buildMenuSelectedKey", _key];
}];

private _placeButton = _display displayCtrl 6902;
_placeButton buttonSetAction "
    private _display = findDisplay 6900;
    if (isNull _display) exitWith {};
    private _list = _display displayCtrl 6901;
    private _index = lbCurSel _list;
    private _key = if (_index >= 0) then {_list lbData _index} else {missionNamespace getVariable ['BN_KOTH_buildMenuSelectedKey', '']};
    if (_key isEqualTo '') exitWith {hint 'No build item selected.';};
    closeDialog 0;
    [_key] spawn {
        params ['_selectedKey'];
        sleep 0.05;
        if !(isNull (findDisplay 6900)) then {
            closeDialog 0;
        };
        [_selectedKey] call bn_koth_fnc_build_onSelect;
    };
";

private _closeButton = _display displayCtrl 6903;
_closeButton buttonSetAction "closeDialog 0;";

_list lbSetCurSel 0;
