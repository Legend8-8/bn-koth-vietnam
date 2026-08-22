/*
    File: fn_menu_evaluateWeaponComposition.sqf
    Author: Legend
    Description: Evaluates one client-local weapon composition draft against
        generated factual compatibility data for presentation gating only.
        The server validator remains authoritative for accepted loadouts.
    Execution: Client
    Parameters:
        0: Canonical base weapon classname <STRING>
        1: Attachment classnames <ARRAY>
        2: Magazine classnames <ARRAY>
        3: Compatibility config root <CONFIG>
    Returns:
        Presentation validation result <HASHMAP>
    Public: No
*/

params [
    ["_weaponClass", "", [""]],
    ["_attachments", [], [[]]],
    ["_magazines", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];

private _fail = {
    params ["_code", "_message", ["_resolvedWeaponClass", "", [""]]];

    createHashMapFromArray [
        ["available", false],
        ["success", false],
        ["state", "INVALID"],
        ["complete", false],
        ["code", _code],
        ["message", _message],
        ["resolvedWeaponClass", _resolvedWeaponClass],
        ["attachments", []],
        ["magazines", []],
        ["structuralAttachments", []],
        ["ordinaryAttachments", []],
        ["possibleCompletions", []]
    ]
};

_weaponClass = toLower _weaponClass;
if (_weaponClass isEqualTo "") exitWith {
    ["ERR_MALFORMED_REQUEST", "Weapon composition requires a base weapon classname."] call _fail
};

if !(isClass _compatibilityCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "Weapon composition requires canonical compatibility config.", _weaponClass] call _fail
};

private _invalidAttachmentType = _attachments findIf {!(_x isEqualType "")};
if (_invalidAttachmentType >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", "Attachments must be classnames.", _weaponClass] call _fail
};

private _invalidMagazineType = _magazines findIf {!(_x isEqualType "")};
if (_invalidMagazineType >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", "Magazines must be classnames.", _weaponClass] call _fail
};

private _emptyAttachmentIndex = _attachments findIf {toLower _x isEqualTo ""};
if (_emptyAttachmentIndex >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", "Attachments must not contain empty classnames.", _weaponClass] call _fail
};

private _emptyMagazineIndex = _magazines findIf {toLower _x isEqualTo ""};
if (_emptyMagazineIndex >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", "Magazines must not contain empty classnames.", _weaponClass] call _fail
};

private _canonicalAttachments = [];
{
    private _attachment = toLower _x;
    _canonicalAttachments pushBackUnique _attachment;
} forEach _attachments;
_canonicalAttachments sort true;

private _canonicalMagazines = [];
{
    private _magazine = toLower _x;
    _canonicalMagazines pushBackUnique _magazine;
} forEach _magazines;
_canonicalMagazines sort true;

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _variantIndexCfg = _compatibilityCfg >> "WeaponVariantByBaseAndAttachments";
private _transformingCfg = _compatibilityCfg >> "WeaponVariantTransformingAttachments";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
private _weaponAttachmentsCfg = _compatibilityCfg >> "WeaponAttachments";

if (
    !(isClass _sourceWeaponsCfg) ||
    {!(isClass _sourceMagazinesCfg)} ||
    {!(isClass _sourceItemsCfg)} ||
    {!(isClass _variantIndexCfg)} ||
    {!(isClass _transformingCfg)} ||
    {!(isClass _weaponMagazinesCfg)} ||
    {!(isClass _weaponAttachmentsCfg)}
) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "Weapon composition requires complete generated compatibility data.", _weaponClass] call _fail
};

private _requestedWeaponCfg = _sourceWeaponsCfg >> _weaponClass;
if !(isClass _requestedWeaponCfg) exitWith {
    ["ERR_UNKNOWN_WEAPON", format ["Weapon '%1' does not exist in canonical source catalogue.", _weaponClass], _weaponClass] call _fail
};

private _variantOf = getText (_requestedWeaponCfg >> "variantOf");
if !(_variantOf isEqualTo "") exitWith {
    ["ERR_WEAPON_NOT_BASE", format ["Weapon '%1' is structural variant-derived and cannot be used as base draft intent.", _weaponClass], _weaponClass] call _fail
};

private _unknownAttachmentIndex = _canonicalAttachments findIf {!(isClass (_sourceItemsCfg >> _x))};
if (_unknownAttachmentIndex >= 0) exitWith {
    private _unknownAttachment = _canonicalAttachments select _unknownAttachmentIndex;
    ["ERR_UNKNOWN_ATTACHMENT", format ["Attachment '%1' does not exist in canonical source catalogue.", _unknownAttachment], _weaponClass] call _fail
};

private _transformingAttachments = [];
private _transformingEntryCfg = _transformingCfg >> _weaponClass;
if (isClass _transformingEntryCfg) then {
    _transformingAttachments = (getArray (_transformingEntryCfg >> "values")) apply {toLower _x};
};

private _structuralRequested = [];
private _ordinaryRequested = [];
{
    if (_x in _transformingAttachments) then {
        _structuralRequested pushBackUnique _x;
    } else {
        _ordinaryRequested pushBackUnique _x;
    };
} forEach _canonicalAttachments;
_structuralRequested sort true;
_ordinaryRequested sort true;

private _variantKey = if ((count _structuralRequested) isEqualTo 0) then {
    "k_none"
} else {
    "k_" + (_structuralRequested joinString "__")
};

private _resolvedWeaponClass = _weaponClass;
private _indexBaseCfg = _variantIndexCfg >> _weaponClass;
private _hasStructuralAttachments = (count _structuralRequested) > 0;

if (_hasStructuralAttachments && {!(isClass _indexBaseCfg)}) exitWith {
    ["ERR_VARIANT_UNRESOLVED", format ["No structural variant index available for base weapon '%1'.", _weaponClass], _weaponClass] call _fail
};

private _unknownMagazineIndex = _canonicalMagazines findIf {!(isClass (_sourceMagazinesCfg >> _x))};
if (_unknownMagazineIndex >= 0) exitWith {
    private _unknownMagazine = _canonicalMagazines select _unknownMagazineIndex;
    ["ERR_UNKNOWN_MAGAZINE", format ["Magazine '%1' does not exist in canonical source catalogue.", _unknownMagazine], _weaponClass] call _fail
};

private _variantEntry = _indexBaseCfg >> _variantKey;
private _hasVariantEntry = isClass _variantEntry;

if (_hasVariantEntry) then {
    private _isAmbiguous = getNumber (_variantEntry >> "ambiguous");
    if (_isAmbiguous <= 0) then {
        private _entryStructural = (getArray (_variantEntry >> "structuralAttachments")) apply {toLower _x};
        _entryStructural sort true;

        if (_entryStructural isEqualTo _structuralRequested) then {
            _resolvedWeaponClass = toLower (getText (_variantEntry >> "resolvedWeaponClass"));
        };
    };
};

private _isSubsetOf = {
    params ["_subset", "_candidate"];
    (_subset findIf {!(_x in _candidate)}) < 0
};

private _isAttachmentSetCompatible = {
    params ["_resolvedClass"];

    private _compatibleAttachments = [];
    private _compatibleCfg = _weaponAttachmentsCfg >> _resolvedClass;
    if (isClass _compatibleCfg) then {
        _compatibleAttachments = (getArray (_compatibleCfg >> "values")) apply {toLower _x};
    };

    (_ordinaryRequested findIf {!(_x in _compatibleAttachments)}) < 0
};

private _isMagazineSetCompatible = {
    params ["_resolvedClass"];

    private _compatibleMagazines = [];
    private _compatibleCfg = _weaponMagazinesCfg >> _resolvedClass;
    if (isClass _compatibleCfg) then {
        _compatibleMagazines = (getArray (_compatibleCfg >> "values")) apply {toLower _x};
    };

    (_canonicalMagazines findIf {!(_x in _compatibleMagazines)}) < 0
};

private _possibleCompletions = [];
if (_hasStructuralAttachments && {!_hasVariantEntry}) then {
    {
        private _candidateCfg = _x;
        if ((getNumber (_candidateCfg >> "ambiguous")) > 0) then {continue;};

        private _candidateStructural = (getArray (_candidateCfg >> "structuralAttachments")) apply {toLower _x};
        _candidateStructural sort true;
        if !((count _structuralRequested) < (count _candidateStructural)) then {continue;};
        if !([_structuralRequested, _candidateStructural] call _isSubsetOf) then {continue;};

        private _candidateResolvedWeapon = toLower (getText (_candidateCfg >> "resolvedWeaponClass"));
        if (_candidateResolvedWeapon isEqualTo "") then {continue;};
        if !(isClass (_sourceWeaponsCfg >> _candidateResolvedWeapon)) then {continue;};
        if !([_candidateResolvedWeapon] call _isAttachmentSetCompatible) then {continue;};
        if !([_candidateResolvedWeapon] call _isMagazineSetCompatible) then {continue;};

        _possibleCompletions pushBack createHashMapFromArray [
            ["resolvedWeaponClass", _candidateResolvedWeapon],
            ["structuralAttachments", _candidateStructural]
        ];
    } forEach ("true" configClasses _indexBaseCfg);
};

if (_hasStructuralAttachments && {!_hasVariantEntry}) exitWith {
    if ((count _possibleCompletions) <= 0) exitWith {
        ["ERR_VARIANT_UNRESOLVED", format ["No possible non-ambiguous structural completion exists for requested attachment set on base weapon '%1'.", _weaponClass], _weaponClass] call _fail
    };

    createHashMapFromArray [
        ["available", true],
        ["success", true],
        ["state", "INCOMPLETE"],
        ["complete", false],
        ["code", "INCOMPLETE_STRUCTURAL"],
        ["message", "Weapon composition draft requires additional structural attachment selection."],
        ["resolvedWeaponClass", ""],
        ["attachments", _canonicalAttachments],
        ["magazines", _canonicalMagazines],
        ["structuralAttachments", _structuralRequested],
        ["ordinaryAttachments", _ordinaryRequested],
        ["possibleCompletions", _possibleCompletions]
    ]
};

private _isAmbiguous = if (_hasVariantEntry) then {
    getNumber (_variantEntry >> "ambiguous")
} else {
    0
};

if (_isAmbiguous > 0) exitWith {
    ["ERR_VARIANT_AMBIGUOUS", format ["Structural variant mapping for '%1' is ambiguous for requested attachments.", _weaponClass], _weaponClass] call _fail
};

private _entryStructuralMatches = true;
if (_hasVariantEntry) then {
    private _entryStructuralCheck = (getArray (_variantEntry >> "structuralAttachments")) apply {toLower _x};
    _entryStructuralCheck sort true;
    _entryStructuralMatches = _entryStructuralCheck isEqualTo _structuralRequested;
};

if !(_entryStructuralMatches) exitWith {
    ["ERR_VARIANT_INDEX_INCONSISTENT", "Structural variant index data is inconsistent for requested attachment set.", _weaponClass] call _fail
};

if (_hasVariantEntry && {_resolvedWeaponClass isEqualTo ""}) exitWith {
    ["ERR_VARIANT_UNRESOLVED", format ["Structural variant could not be resolved for base weapon '%1'.", _weaponClass], _weaponClass] call _fail
};

if !(isClass (_sourceWeaponsCfg >> _resolvedWeaponClass)) exitWith {
    ["ERR_VARIANT_RESOLVED_CLASS_MISSING", format ["Resolved weapon '%1' is missing from source catalogue.", _resolvedWeaponClass], _weaponClass] call _fail
};

private _resolvedAttachmentCompat = [];
private _resolvedAttachmentCfg = _weaponAttachmentsCfg >> _resolvedWeaponClass;
if (isClass _resolvedAttachmentCfg) then {
    _resolvedAttachmentCompat = (getArray (_resolvedAttachmentCfg >> "values")) apply {toLower _x};
};

private _incompatibleAttachmentIndex = _ordinaryRequested findIf {!(_x in _resolvedAttachmentCompat)};
if (_incompatibleAttachmentIndex >= 0) exitWith {
    private _badAttachment = _ordinaryRequested select _incompatibleAttachmentIndex;
    ["ERR_INCOMPATIBLE_ATTACHMENT", format ["Attachment '%1' is not compatible with resolved weapon '%2'.", _badAttachment, _resolvedWeaponClass], _resolvedWeaponClass] call _fail
};

private _resolvedMagazineCompat = [];
private _resolvedMagazineCfg = _weaponMagazinesCfg >> _resolvedWeaponClass;
if (isClass _resolvedMagazineCfg) then {
    _resolvedMagazineCompat = (getArray (_resolvedMagazineCfg >> "values")) apply {toLower _x};
};

private _incompatibleMagazineIndex = _canonicalMagazines findIf {!(_x in _resolvedMagazineCompat)};
if (_incompatibleMagazineIndex >= 0) exitWith {
    private _badMagazine = _canonicalMagazines select _incompatibleMagazineIndex;
    ["ERR_INCOMPATIBLE_MAGAZINE", format ["Magazine '%1' is not compatible with resolved weapon '%2'.", _badMagazine, _resolvedWeaponClass], _resolvedWeaponClass] call _fail
};

createHashMapFromArray [
    ["available", true],
    ["success", true],
    ["state", "VALID"],
    ["complete", true],
    ["code", "OK"],
    ["message", "Weapon composition draft is factually valid."],
    ["resolvedWeaponClass", _resolvedWeaponClass],
    ["attachments", _canonicalAttachments],
    ["magazines", _canonicalMagazines],
    ["structuralAttachments", _structuralRequested],
    ["ordinaryAttachments", _ordinaryRequested],
    ["possibleCompletions", []]
]