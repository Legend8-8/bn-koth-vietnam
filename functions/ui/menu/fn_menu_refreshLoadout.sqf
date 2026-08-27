/*
    File: fn_menu_refreshLoadout.sqf
    Author: Legend
    Description: Renders the main LOADOUT overview page.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
        1: Intended loadout snapshot <ARRAY>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [
    ["_display", displayNull, [displayNull]],
    ["_intendedLoadout", [], [[]]]
];

if (isNull _display) exitWith {};

private _arsenalEnabled = uiNamespace getVariable [
    "BN_KOTH_menuArsenalEnabled",
    false
];

private _resolveItemPicture = {
    params ["_className"];
    if (_className isEqualTo "") exitWith {""};
    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {_cfg = configFile >> "CfgVehicles" >> _className;};
    if !(isClass _cfg) then {_cfg = configFile >> "CfgGlasses" >> _className;};
    if !(isClass _cfg) then {_cfg = configFile >> "CfgMagazines" >> _className;};
    if !(isClass _cfg) exitWith {""};
    getText (_cfg >> "picture")
};

private _resolveItemName = {
    params ["_className"];

    if (_className isEqualTo "") exitWith {"NONE"};

    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgVehicles" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgGlasses" >> _className;
    };

    if !(isClass _cfg) exitWith {toUpper _className};

    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {toUpper _className} else {_displayName}
};

private _readWeaponNameFromLoadoutSlot = {
    params ["_loadout", "_index"];
    if !((_loadout isEqualType []) && {(count _loadout) > _index}) exitWith {"NONE"};
    private _slot = _loadout select _index;
    if !((_slot isEqualType []) && {(count _slot) >= 1}) exitWith {"NONE"};
    [toLower (_slot select 0)] call _resolveItemName
};

private _readContainerNameFromLoadoutSlot = {
    params ["_loadout", "_index"];
    if !((_loadout isEqualType []) && {(count _loadout) > _index}) exitWith {"NONE"};
    private _slot = _loadout select _index;
    if !((_slot isEqualType []) && {(count _slot) >= 1}) exitWith {"NONE"};
    [toLower (_slot select 0)] call _resolveItemName
};

private _readStringSlotName = {
    params ["_loadout", "_index"];
    if !((_loadout isEqualType []) && {(count _loadout) > _index}) exitWith {"NONE"};
    private _slot = _loadout select _index;
    if !(_slot isEqualType "") exitWith {"NONE"};
    [toLower _slot] call _resolveItemName
};

private _setLine = {
    params ["_ctrl", "_label", "_value"];
    _ctrl ctrlSetText format ["%1: %2", _label, _value];
};

private _fitRowValue = {
    params ["_value"];
    private _maximumLength = 34;
    if ((count _value) <= _maximumLength) exitWith {_value};
    format ["%1...", _value select [0, _maximumLength - 3]]
};

private _ctrlTextPrimary = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_PRIMARY;
private _ctrlTextHandgun = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_HANDGUN;
private _ctrlTextLauncher = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_LAUNCHER;
private _ctrlTextUniform = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_UNIFORM;
private _ctrlTextVest = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_VEST;
private _ctrlTextHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_HEADGEAR;
private _ctrlTextBackpack = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_BACKPACK;
private _ctrlTextEquipment = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_EQUIPMENT;
private _ctrlPicPrimary = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_PRIMARY;
private _ctrlPicHandgun = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_HANDGUN;
private _ctrlPicLauncher = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_LAUNCHER;
private _ctrlPicUniform = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_UNIFORM;
private _ctrlPicVest = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_VEST;
private _ctrlPicHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_HEADGEAR;
private _ctrlPicBackpack = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_BACKPACK;
private _ctrlPicEquipment = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_EQUIPMENT;
private _ctrlSectionTitle = _display displayCtrl BN_KOTH_IDC_MENU_SECTION_TITLE;
private _ctrlNotice = _display displayCtrl BN_KOTH_IDC_MENU_NOTICE;
private _ctrlFooter = _display displayCtrl BN_KOTH_IDC_MENU_FOOTER_TEXT;
private _ctrlKitManage = _display displayCtrl BN_KOTH_IDC_MENU_KIT_MANAGE;
private _ctrlKitSaveCurrent = _display displayCtrl BN_KOTH_IDC_MENU_KIT_SAVE_CURRENT;

private _ctrlPrimary = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_PRIMARY;
private _ctrlHandgun = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HANDGUN;
private _ctrlLauncher = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_LAUNCHER;
private _ctrlUniform = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_UNIFORM;
private _ctrlVest = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_VEST;
private _ctrlHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HEADGEAR;
private _ctrlBackpack = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BACKPACK;
private _ctrlFacewear = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_FACEWEAR;
private _ctrlBinocular = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BINOCULAR;
private _ctrlEquipment = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_EQUIPMENT;

private _ctrlPrimaryButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_PRIMARY_BUTTON;
private _ctrlHandgunButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HANDGUN_BUTTON;
private _ctrlLauncherButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_LAUNCHER_BUTTON;
private _ctrlUniformButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_UNIFORM_BUTTON;
private _ctrlVestButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_VEST_BUTTON;
private _ctrlBackpackButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BACKPACK_BUTTON;
private _ctrlHeadgearButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HEADGEAR_BUTTON;
private _ctrlFacewearButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_FACEWEAR_BUTTON;
private _ctrlBinocularButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BINOCULAR_BUTTON;
private _ctrlEquipmentButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_EQUIPMENT_BUTTON;
private _ctrlCargoButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_CARGO_BUTTON;

private _primaryName = [_intendedLoadout, 0] call _readWeaponNameFromLoadoutSlot;
private _handgunName = [_intendedLoadout, 2] call _readWeaponNameFromLoadoutSlot;
private _launcherName = [_intendedLoadout, 1] call _readWeaponNameFromLoadoutSlot;
private _uniformName = [_intendedLoadout, 3] call _readContainerNameFromLoadoutSlot;
private _vestName = [_intendedLoadout, 4] call _readContainerNameFromLoadoutSlot;
private _backpackName = [_intendedLoadout, 5] call _readContainerNameFromLoadoutSlot;
private _headgearName = [_intendedLoadout, 6] call _readStringSlotName;
private _facewearName = [_intendedLoadout, 7] call _readStringSlotName;

private _binocularName = "NONE";
if ((count _intendedLoadout) > 8) then {
    private _binocSlot = _intendedLoadout select 8;
    if (_binocSlot isEqualType "") then {
        _binocularName = [toLower _binocSlot] call _resolveItemName;
    } else {
        if ((_binocSlot isEqualType []) && {(count _binocSlot) > 0}) then {
            _binocularName = [toLower (_binocSlot select 0)] call _resolveItemName;
        };
    };
};

_ctrlSectionTitle ctrlSetText "LOADOUT";
_ctrlNotice ctrlSetText (
    if (_arsenalEnabled) then {
        "SERVER-AUTHORITATIVE INTENDED KIT"
    } else {
        "ARSENAL LOCKED - USE YOUR TEAM MAPBOARD"
    }
);

{
    _x ctrlShow false;
} forEach [
    _ctrlFacewear,
    _ctrlBinocular,
    _ctrlFacewearButton,
    _ctrlBinocularButton,
    _ctrlCargoButton
];

{
    _x ctrlShow true;
} forEach [
    _ctrlPrimary,
    _ctrlHandgun,
    _ctrlLauncher,
    _ctrlUniform,
    _ctrlVest,
    _ctrlHeadgear,
    _ctrlBackpack,
    _ctrlEquipment,
    _ctrlPrimaryButton,
    _ctrlHandgunButton,
    _ctrlLauncherButton,
    _ctrlUniformButton,
    _ctrlVestButton,
    _ctrlHeadgearButton,
    _ctrlBackpackButton,
    _ctrlEquipmentButton,
    _ctrlPicPrimary,
    _ctrlPicHandgun,
    _ctrlPicLauncher,
    _ctrlPicUniform,
    _ctrlPicVest,
    _ctrlPicHeadgear,
    _ctrlPicBackpack,
    _ctrlPicEquipment
];

{
    _x ctrlShow false;
} forEach [_ctrlPrimary, _ctrlHandgun, _ctrlLauncher, _ctrlUniform, _ctrlVest, _ctrlHeadgear, _ctrlBackpack, _ctrlEquipment];

private _rowDefs = [
    [_ctrlTextPrimary, _ctrlPrimaryButton, "PRIMARY", _primaryName],
    [_ctrlTextHandgun, _ctrlHandgunButton, "HANDGUN", _handgunName],
    [_ctrlTextLauncher, _ctrlLauncherButton, "LAUNCHER", _launcherName],
    [_ctrlTextUniform, _ctrlUniformButton, "UNIFORM", _uniformName],
    [_ctrlTextVest, _ctrlVestButton, "VEST", _vestName],
    [_ctrlTextHeadgear, _ctrlHeadgearButton, "HEADGEAR", _headgearName],
    [_ctrlTextBackpack, _ctrlBackpackButton, "BACKPACK", _backpackName],
    [_ctrlTextEquipment, _ctrlEquipmentButton, "EQUIPMENT", "ASSIGNED GEAR"]
];

{
    _x params ["_textCtrl", "_buttonCtrl", "_label", "_value"];

    _textCtrl ctrlShow true;
    private _displayValue = [_value] call _fitRowValue;
    _textCtrl ctrlSetStructuredText parseText format [
        "<t font='RobotoCondensed' size='0.66' color='#A29D90'>%1</t><br/><t font='PuristaSemiBold' size='0.88' color='#E9E5DB'>%2</t>",
        _label,
        _displayValue
    ];

    _buttonCtrl ctrlSetText "";
    _buttonCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
} forEach _rowDefs;

private _browserAction = {
    params ["_slot"];
    format ["uiNamespace setVariable ['BN_KOTH_menuBrowserSlot','%1']; uiNamespace setVariable ['BN_KOTH_menuBrowserSnapPending',true]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;", _slot]
};
_ctrlPrimaryButton buttonSetAction (["primary"] call _browserAction);
_ctrlHandgunButton buttonSetAction (["handgun"] call _browserAction);
_ctrlLauncherButton buttonSetAction (["launcher"] call _browserAction);
_ctrlUniformButton buttonSetAction (["uniform"] call _browserAction);
_ctrlVestButton buttonSetAction (["vest"] call _browserAction);
_ctrlHeadgearButton buttonSetAction (["headgear"] call _browserAction);
_ctrlBackpackButton buttonSetAction (["backpack"] call _browserAction);
_ctrlEquipmentButton buttonSetAction "uiNamespace setVariable ['BN_KOTH_menuBrowserSlot','assigned']; uiNamespace setVariable ['BN_KOTH_menuAssignedStage',1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot',-1]; uiNamespace setVariable ['BN_KOTH_menuBrowserSnapPending',false]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage',0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";

private _classAt = {
    params ["_index", ["_stringSlot", false]];
    if !((_intendedLoadout isEqualType []) && {(count _intendedLoadout) > _index}) exitWith {""};
    private _slot = _intendedLoadout select _index;
    if (_stringSlot) exitWith {if (_slot isEqualType "") then {toLower _slot} else {""}};
    if ((_slot isEqualType []) && {(count _slot) > 0}) then {toLower (_slot select 0)} else {""}
};

private _primaryClass = [0] call _classAt;
private _launcherClass = [1] call _classAt;
private _handgunClass = [2] call _classAt;
private _uniformClass = [3] call _classAt;
private _vestClass = [4] call _classAt;
private _backpackClass = [5] call _classAt;
private _headgearClass = [6, true] call _classAt;

_ctrlPicPrimary ctrlSetText ([_primaryClass] call _resolveItemPicture);
_ctrlPicHandgun ctrlSetText ([_handgunClass] call _resolveItemPicture);
_ctrlPicLauncher ctrlSetText ([_launcherClass] call _resolveItemPicture);
_ctrlPicUniform ctrlSetText ([_uniformClass] call _resolveItemPicture);
_ctrlPicVest ctrlSetText ([_vestClass] call _resolveItemPicture);
_ctrlPicHeadgear ctrlSetText ([_headgearClass] call _resolveItemPicture);
_ctrlPicBackpack ctrlSetText ([_backpackClass] call _resolveItemPicture);

_ctrlPicEquipment ctrlSetText "";

{
    _x ctrlEnable (!isNull player && {_arsenalEnabled});
} forEach [_ctrlPrimaryButton, _ctrlHandgunButton, _ctrlLauncherButton, _ctrlUniformButton, _ctrlVestButton, _ctrlBackpackButton, _ctrlHeadgearButton, _ctrlEquipmentButton];

private _editKitId = uiNamespace getVariable ["BN_KOTH_menuKitEditId", ""];
if !(_editKitId isEqualTo "") then {
    _ctrlFooter ctrlSetText "";
    _ctrlFooter ctrlShow false;
    _ctrlKitManage ctrlSetText "CANCEL EDIT";
    _ctrlKitManage buttonSetAction "uiNamespace setVariable ['BN_KOTH_menuKitEditId','']; uiNamespace setVariable ['BN_KOTH_menuKitEditName','']; ['LOADOUT'] call bn_koth_fnc_menu_refresh;";
    _ctrlKitSaveCurrent ctrlSetText "SAVE CHANGES";
    _ctrlKitSaveCurrent buttonSetAction format ["%1 call bn_koth_fnc_menu_saveSessionKit;", str ["", _editKitId, "UPDATE"]];
} else {
    _ctrlFooter ctrlSetText "";
    _ctrlFooter ctrlShow false;
    _ctrlKitManage ctrlSetText "MANAGE LOADOUTS";
    _ctrlKitManage buttonSetAction "uiNamespace setVariable ['BN_KOTH_menuKitPage',0]; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;";
    _ctrlKitSaveCurrent ctrlSetText "SAVE CURRENT KIT";
    _ctrlKitSaveCurrent buttonSetAction "uiNamespace setVariable ['BN_KOTH_menuKitSelectedId','']; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;";
};
