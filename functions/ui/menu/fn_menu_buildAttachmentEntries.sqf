/*
    File: fn_menu_buildAttachmentEntries.sqf
    Author: Legend
    Description: Builds attachment add/remove entries using structural transform and ordinary attachment compatibility data.
    Execution: Client
    Parameters:
        0: Intended loadout snapshot <ARRAY>
        1: Compatibility config root <CONFIG>
    Returns:
        Selector entries <ARRAY<HashMap>>
    Public: No
*/

params [
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];

private _entries = [];
if !(isClass _compatibilityCfg) exitWith {_entries};

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _weaponAttachmentsCfg = _compatibilityCfg >> "WeaponAttachments";
private _transformingCfg = _compatibilityCfg >> "WeaponVariantTransformingAttachments";
private _variantIndexCfg = _compatibilityCfg >> "WeaponVariantByBaseAndAttachments";

if (
    !(isClass _sourceWeaponsCfg) ||
    {!(isClass _sourceItemsCfg)} ||
    {!(isClass _weaponAttachmentsCfg)} ||
    {!(isClass _transformingCfg)} ||
    {!(isClass _variantIndexCfg)}
) exitWith {_entries};

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

private _resolveBaseWeapon = {
    params ["_weaponClass"];

    private _cursor = toLower _weaponClass;
    if (_cursor isEqualTo "") exitWith {""};

    private _guard = 0;
    while {_guard < 20} do {
        private _cursorCfg = _sourceWeaponsCfg >> _cursor;
        if !(isClass _cursorCfg) exitWith {};

        private _variantOf = toLower (getText (_cursorCfg >> "variantOf"));
        if (_variantOf isEqualTo "") exitWith {};

        _cursor = _variantOf;
        _guard = _guard + 1;
    };

    _cursor
};

private _evaluateAttachmentSet = {
    params ["_baseWeaponClass", "_attachments"];

    private _result = createHashMapFromArray [
        ["available", false],
        ["resolvedWeaponClass", _baseWeaponClass]
    ];

    private _transformingAttachments = [];
    private _transformCfg = _transformingCfg >> _baseWeaponClass;
    if (isClass _transformCfg) then {
        _transformingAttachments = (getArray (_transformCfg >> "values")) apply {toLower _x};
    };

    private _structural = [];
    private _ordinary = [];

    {
        private _attachment = toLower _x;
        if (_attachment in _transformingAttachments) then {
            _structural pushBackUnique _attachment;
        } else {
            _ordinary pushBackUnique _attachment;
        };
    } forEach _attachments;

    _structural sort true;
    _ordinary sort true;

    private _resolvedWeaponClass = _baseWeaponClass;
    private _valid = true;

    if ((count _structural) > 0) then {
        private _baseVariantCfg = _variantIndexCfg >> _baseWeaponClass;

        if !(isClass _baseVariantCfg) then {
            _valid = false;
        };

        if (_valid) then {
            private _variantKey = "k_" + (_structural joinString "__");
            private _variantCfg = _baseVariantCfg >> _variantKey;

            if !(isClass _variantCfg) then {
                _valid = false;
            } else {
                if ((getNumber (_variantCfg >> "ambiguous")) > 0) then {
                    _valid = false;
                } else {
                    private _expectedStructural = getArray (_variantCfg >> "structuralAttachments");
                    _expectedStructural = _expectedStructural apply {toLower _x};
                    _expectedStructural sort true;

                    if !(_expectedStructural isEqualTo _structural) then {
                        _valid = false;
                    } else {
                        _resolvedWeaponClass = toLower (getText (_variantCfg >> "resolvedWeaponClass"));

                        if (
                            (_resolvedWeaponClass isEqualTo "") ||
                            {!(isClass (_sourceWeaponsCfg >> _resolvedWeaponClass))}
                        ) then {
                            _valid = false;
                        };
                    };
                };
            };
        };
    };

    if (_valid) then {
        private _resolvedAttachmentCompat = [];
        private _resolvedAttachmentCfg = _weaponAttachmentsCfg >> _resolvedWeaponClass;
        if (isClass _resolvedAttachmentCfg) then {
            _resolvedAttachmentCompat = (getArray (_resolvedAttachmentCfg >> "values")) apply {toLower _x};
        };

        private _incompatibleOrdinary = _ordinary findIf {!(_x in _resolvedAttachmentCompat)};
        if (_incompatibleOrdinary >= 0) then {
            _valid = false;
        };
    };

    if (_valid) then {
        _result set ["available", true];
        _result set ["resolvedWeaponClass", _resolvedWeaponClass];
    };

    _result
};

{
    _x params ["_slotName", "_slotIndex", "_slotLabel"];

    private _slot = _intendedLoadout select _slotIndex;
    if !((_slot isEqualType []) && {(count _slot) >= 7}) then {continue;};

    private _weaponClass = toLower (_slot select 0);
    if (_weaponClass isEqualTo "") then {continue;};

    private _baseWeaponClass = [_weaponClass] call _resolveBaseWeapon;
    if (_baseWeaponClass isEqualTo "") then {
        _baseWeaponClass = _weaponClass;
    };

    private _currentAttachments = [];
    {
        private _att = toLower (_slot select _x);
        if !(_att isEqualTo "") then {
            _currentAttachments pushBackUnique _att;
        };
    } forEach [1, 2, 3, 6];
    _currentAttachments sort true;

    {
        private _attClass = toLower _x;
        private _attName = [_attClass] call _resolveItemName;

        private _remainingAttachments = _currentAttachments - [_attClass];
        private _removeResult = [_baseWeaponClass, _remainingAttachments] call _evaluateAttachmentSet;
        private _removeAvailable = _removeResult getOrDefault ["available", false];

        _entries pushBack (createHashMapFromArray [
            ["displayName", if (_removeAvailable) then {
                format ["%1 REMOVE: %2", _slotLabel, _attName]
            } else {
                format ["%1 REMOVE: %2 [INCOMPATIBLE]", _slotLabel, _attName]
            }],
            ["weaponSlot", _slotName],
            ["attachmentClass", _attClass],
            ["mode", "remove"],
            ["available", _removeAvailable],
            ["equipped", true]
        ]);
    } forEach _currentAttachments;

    private _candidateAdds = [];

    private _transformCfg = _transformingCfg >> _baseWeaponClass;
    if (isClass _transformCfg) then {
        {
            private _attClass = toLower _x;
            if (_attClass in _currentAttachments) then {continue;};
            if !(isClass (_sourceItemsCfg >> _attClass)) then {continue;};
            _candidateAdds pushBackUnique _attClass;
        } forEach (getArray (_transformCfg >> "values"));
    };

    private _ordinaryCfg = _weaponAttachmentsCfg >> _weaponClass;
    if (isClass _ordinaryCfg) then {
        {
            private _attClass = toLower _x;
            if (_attClass in _currentAttachments) then {continue;};
            if !(isClass (_sourceItemsCfg >> _attClass)) then {continue;};
            _candidateAdds pushBackUnique _attClass;
        } forEach (getArray (_ordinaryCfg >> "values"));
    };

    _candidateAdds sort true;

    {
        private _attClass = _x;
        private _attName = [_attClass] call _resolveItemName;

        private _candidateAttachments = +_currentAttachments;
        _candidateAttachments pushBackUnique _attClass;
        _candidateAttachments sort true;

        private _addResult = [_baseWeaponClass, _candidateAttachments] call _evaluateAttachmentSet;
        private _addAvailable = _addResult getOrDefault ["available", false];

        _entries pushBack (createHashMapFromArray [
            ["displayName", if (_addAvailable) then {
                format ["%1 ADD: %2", _slotLabel, _attName]
            } else {
                format ["%1 ADD: %2 [INCOMPATIBLE]", _slotLabel, _attName]
            }],
            ["weaponSlot", _slotName],
            ["attachmentClass", _attClass],
            ["mode", "add"],
            ["available", _addAvailable],
            ["equipped", false]
        ]);
    } forEach _candidateAdds;

} forEach [
    ["primary", 0, "PRIMARY"],
    ["launcher", 1, "LAUNCHER"],
    ["handgun", 2, "HANDGUN"]
];

_entries
