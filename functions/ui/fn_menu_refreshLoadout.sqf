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

#include "..\..\ui\menu\idcs.hpp"

params [
    ["_display", displayNull, [displayNull]],
    ["_intendedLoadout", [], [[]]]
];

if (isNull _display) exitWith {};

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

private _ctrlSectionTitle = _display displayCtrl BN_KOTH_IDC_MENU_SECTION_TITLE;
private _ctrlNotice = _display displayCtrl BN_KOTH_IDC_MENU_NOTICE;
private _ctrlFooter = _display displayCtrl BN_KOTH_IDC_MENU_FOOTER_TEXT;

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
private _ctrlAttachmentsButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_ATTACHMENTS_BUTTON;

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
_ctrlNotice ctrlSetText "SERVER-AUTHORITATIVE INTENDED KIT";

{
    _x ctrlShow false;
} forEach [
    _ctrlPrimary,
    _ctrlHandgun,
    _ctrlLauncher,
    _ctrlUniform,
    _ctrlVest,
    _ctrlBackpack,
    _ctrlHeadgear,
    _ctrlFacewear,
    _ctrlBinocular,
    _ctrlEquipment
];

{
    _x ctrlShow true;
} forEach [
    _ctrlPrimaryButton,
    _ctrlHandgunButton,
    _ctrlLauncherButton,
    _ctrlUniformButton,
    _ctrlVestButton,
    _ctrlBackpackButton,
    _ctrlHeadgearButton,
    _ctrlFacewearButton,
    _ctrlBinocularButton,
    _ctrlEquipmentButton,
    _ctrlCargoButton,
    _ctrlAttachmentsButton
];

private _assignedCount = 0;
if ((count _intendedLoadout) > 9) then {
    private _assigned = _intendedLoadout select 9;
    if (_assigned isEqualType []) then {
        _assignedCount = {_x isEqualType "" && {!(_x isEqualTo "")}} count _assigned;
    };
};

private _cargoEntries = 0;
{
    if ((count _intendedLoadout) > _x) then {
        private _slot = _intendedLoadout select _x;
        if ((_slot isEqualType []) && {(count _slot) > 1}) then {
            private _cargo = _slot select 1;
            if (_cargo isEqualType []) then {
                _cargoEntries = _cargoEntries + (count _cargo);
            };
        };
    };
} forEach [3, 4, 5];

[_ctrlPrimary, "PRIMARY", _primaryName] call _setLine;
[_ctrlHandgun, "HANDGUN", _handgunName] call _setLine;
[_ctrlLauncher, "LAUNCHER", _launcherName] call _setLine;
[_ctrlUniform, "UNIFORM", _uniformName] call _setLine;
[_ctrlVest, "VEST", _vestName] call _setLine;
[_ctrlBackpack, "BACKPACK", _backpackName] call _setLine;
[_ctrlHeadgear, "HEADGEAR", _headgearName] call _setLine;
[_ctrlFacewear, "FACEWEAR", _facewearName] call _setLine;
[_ctrlBinocular, "BINOCULAR", _binocularName] call _setLine;
[_ctrlEquipment, "EQUIPMENT", format ["ASSIGNED %1 | CARGO ENTRIES %2", _assignedCount, _cargoEntries]] call _setLine;

_ctrlPrimaryButton ctrlSetText format ["PRIMARY: %1", _primaryName];
_ctrlHandgunButton ctrlSetText format ["HANDGUN: %1", _handgunName];
_ctrlLauncherButton ctrlSetText format ["LAUNCHER: %1", _launcherName];
_ctrlUniformButton ctrlSetText format ["UNIFORM: %1", _uniformName];
_ctrlVestButton ctrlSetText format ["VEST: %1", _vestName];
_ctrlBackpackButton ctrlSetText format ["BACKPACK: %1", _backpackName];
_ctrlHeadgearButton ctrlSetText format ["HEADGEAR: %1", _headgearName];
_ctrlFacewearButton ctrlSetText format ["FACEWEAR: %1", _facewearName];
_ctrlBinocularButton ctrlSetText format ["BINOCULAR: %1", _binocularName];
_ctrlEquipmentButton ctrlSetText "ASSIGNED EQUIPMENT";
_ctrlCargoButton ctrlSetText "CARGO / ITEMS";
_ctrlAttachmentsButton ctrlSetText "ATTACHMENTS";

{
    _x ctrlEnable !isNull player;
} forEach [
    _ctrlPrimaryButton,
    _ctrlHandgunButton,
    _ctrlLauncherButton,
    _ctrlUniformButton,
    _ctrlVestButton,
    _ctrlBackpackButton,
    _ctrlHeadgearButton,
    _ctrlFacewearButton,
    _ctrlBinocularButton,
    _ctrlEquipmentButton,
    _ctrlCargoButton,
    _ctrlAttachmentsButton
];

_ctrlFooter ctrlSetText "SESSION KIT: USE SAVE KIT / LOAD KIT / DELETE KIT IN BOTTOM BAR";
