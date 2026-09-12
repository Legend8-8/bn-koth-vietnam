/*
    File: fn_validateWeaponComposition.sqf
    Author: Legend
    Description: Validate one requested weapon composition against canonical arsenal compatibility data.
    Execution: Server
    Parameters:
        0: Weapon composition request <HASHMAP>
           weaponClass <STRING>
           magazines <ARRAY> (optional)
           attachments <ARRAY> (optional)
        1: Canonical compatibility config root <CONFIG>
        2: Error-code slot token <STRING>
        3: Human-readable slot label <STRING>
    Returns:
        Validation result <HASHMAP>
    Public: No
*/

params [
    ["_composition", createHashMap, [createHashMap]],
    ["_compatibilityCfg", configNull, [configNull]],
    ["_slotToken", "WEAPON", [""]],
    ["_slotLabel", "Weapon", [""]]
];

private _fail = {
    params ["_code", "_message"];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["validatedWeapon", createHashMap]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Weapon composition validation must run on server."] call _fail
};

if !(isClass _compatibilityCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", format ["%1 validation requires canonical compatibility config.", _slotLabel]] call _fail
};

private _requestedWeaponClass = _composition getOrDefault ["weaponClass", ""];
if !(_requestedWeaponClass isEqualType "") exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 weaponClass must be a string.", _slotLabel]] call _fail
};

_requestedWeaponClass = toLower _requestedWeaponClass;
if (_requestedWeaponClass isEqualTo "") exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 request missing weaponClass.", _slotLabel]] call _fail
};

private _requestedMagazines = _composition getOrDefault ["magazines", []];
if !(_requestedMagazines isEqualType []) exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 magazines must be an array of classnames.", _slotLabel]] call _fail
};

private _requestedAttachments = _composition getOrDefault ["attachments", []];
if !(_requestedAttachments isEqualType []) exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 attachments must be an array of classnames.", _slotLabel]] call _fail
};

private _invalidMagazineType = _requestedMagazines findIf {!(_x isEqualType "")};
if (_invalidMagazineType >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 magazines contains non-string entry.", _slotLabel]] call _fail
};

private _requestedMagazinesCanonical = _requestedMagazines apply {toLower _x};
private _emptyMagazineClass = _requestedMagazinesCanonical findIf {_x isEqualTo ""};
if (_emptyMagazineClass >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 magazines contains empty classname.", _slotLabel]] call _fail
};

private _canonicalMagazines = [];
{
    _canonicalMagazines pushBackUnique _x;
} forEach _requestedMagazinesCanonical;
_canonicalMagazines sort true;

private _invalidAttachmentType = _requestedAttachments findIf {!(_x isEqualType "")};
if (_invalidAttachmentType >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 attachments contains non-string entry.", _slotLabel]] call _fail
};

private _requestedAttachmentsCanonical = _requestedAttachments apply {toLower _x};
private _emptyAttachmentClass = _requestedAttachmentsCanonical findIf {_x isEqualTo ""};
if (_emptyAttachmentClass >= 0) exitWith {
    ["ERR_MALFORMED_REQUEST", format ["%1 attachments contains empty classname.", _slotLabel]] call _fail
};

private _canonicalAttachments = [];
{
    _canonicalAttachments pushBackUnique _x;
} forEach _requestedAttachmentsCanonical;
_canonicalAttachments sort true;

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _variantIndexCfg = _compatibilityCfg >> "WeaponVariantByBaseAndAttachments";
private _transformingCfg = _compatibilityCfg >> "WeaponVariantTransformingAttachments";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
private _weaponAttachmentsCfg = _compatibilityCfg >> "WeaponAttachments";

private _requestedWeaponCfg = _sourceWeaponsCfg >> _requestedWeaponClass;
if !(isClass _requestedWeaponCfg) exitWith {
    [
        format ["ERR_UNKNOWN_%1_WEAPON", _slotToken],
        format ["%1 weapon '%2' does not exist in canonical source catalogue.", _slotLabel, _requestedWeaponClass]
    ] call _fail
};

private _variantOf = getText (_requestedWeaponCfg >> "variantOf");
if !(_variantOf isEqualTo "") exitWith {
    [
        format ["ERR_%1_WEAPON_NOT_BASE", _slotToken],
        format ["%1 weapon '%2' is structural variant-derived and cannot be requested as base intent.", _slotLabel, _requestedWeaponClass]
    ] call _fail
};

private _unknownAttachmentIndex = _canonicalAttachments findIf {!(isClass (_sourceItemsCfg >> _x))};
if (_unknownAttachmentIndex >= 0) exitWith {
    private _unknownAttachment = _canonicalAttachments select _unknownAttachmentIndex;
    [
        "ERR_UNKNOWN_ATTACHMENT",
        format ["Requested attachment '%1' does not exist in canonical source catalogue.", _unknownAttachment]
    ] call _fail
};

private _transformingAttachments = [];
private _transformingEntryCfg = _transformingCfg >> _requestedWeaponClass;
if (isClass _transformingEntryCfg) then {
    _transformingAttachments = getArray (_transformingEntryCfg >> "values");
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

private _resolvedWeaponClass = _requestedWeaponClass;
private _indexBaseCfg = _variantIndexCfg >> _requestedWeaponClass;
private _hasStructuralAttachments = (count _structuralRequested) > 0;

if (_hasStructuralAttachments && {!(isClass _indexBaseCfg)}) exitWith {
    [
        "ERR_VARIANT_UNRESOLVED",
        format ["No structural variant index available for base weapon '%1'.", _requestedWeaponClass]
    ] call _fail
};

private _variantEntry = _indexBaseCfg >> _variantKey;
private _hasVariantEntry = isClass _variantEntry;

if (_hasStructuralAttachments && {!_hasVariantEntry}) exitWith {
    [
        "ERR_VARIANT_UNRESOLVED",
        format ["No confirmed structural variant exists for requested attachment set on base weapon '%1'.", _requestedWeaponClass]
    ] call _fail
};

if (_hasVariantEntry) then {
    private _isAmbiguous = getNumber (_variantEntry >> "ambiguous");
    if (_isAmbiguous <= 0) then {
        private _entryStructural = getArray (_variantEntry >> "structuralAttachments");
        _entryStructural sort true;

        if (_entryStructural isEqualTo _structuralRequested) then {
            _resolvedWeaponClass = getText (_variantEntry >> "resolvedWeaponClass");
        };
    };
};

private _isAmbiguous = if (_hasVariantEntry) then {
    getNumber (_variantEntry >> "ambiguous")
} else {
    0
};

if (_isAmbiguous > 0) exitWith {
    [
        "ERR_VARIANT_AMBIGUOUS",
        format ["Structural variant mapping for '%1' is ambiguous for requested attachments.", _requestedWeaponClass]
    ] call _fail
};

private _entryStructuralMatches = true;
if (_hasVariantEntry) then {
    private _entryStructuralCheck = getArray (_variantEntry >> "structuralAttachments");
    _entryStructuralCheck sort true;
    _entryStructuralMatches = _entryStructuralCheck isEqualTo _structuralRequested;
};

if !(_entryStructuralMatches) exitWith {
    [
        "ERR_VARIANT_INDEX_INCONSISTENT",
        "Structural variant index data is inconsistent for requested attachment set."
    ] call _fail
};

if (_hasVariantEntry && {_resolvedWeaponClass isEqualTo ""}) exitWith {
    [
        "ERR_VARIANT_UNRESOLVED",
        format ["Structural variant could not be resolved for base weapon '%1'.", _requestedWeaponClass]
    ] call _fail
};

if !(isClass (_sourceWeaponsCfg >> _resolvedWeaponClass)) exitWith {
    [
        "ERR_VARIANT_RESOLVED_CLASS_MISSING",
        format ["Resolved canonical weapon '%1' is missing from source catalogue.", _resolvedWeaponClass]
    ] call _fail
};

private _resolvedEngineCfg = configFile >> "CfgWeapons" >> _resolvedWeaponClass;
if !(isClass _resolvedEngineCfg) exitWith {
    [
        "ERR_RESOLVED_WEAPON_CONFIG_MISSING",
        format ["Resolved canonical weapon '%1' is missing from CfgWeapons.", _resolvedWeaponClass]
    ] call _fail
};

private _expectedWeaponType = switch (_slotToken) do {
    case "PRIMARY": {1};
    case "HANDGUN": {2};
    case "LAUNCHER": {4};
    default {-1};
};

private _resolvedWeaponType = getNumber (_resolvedEngineCfg >> "type");

if (
    (_expectedWeaponType >= 0) &&
    {!(_resolvedWeaponType isEqualTo _expectedWeaponType)}
) exitWith {
    [
        format ["ERR_%1_WEAPON_SLOT_MISMATCH", _slotToken],
        format [
            "%1 weapon '%2' has engine weapon type %3 but slot '%4' requires type %5.",
            _slotLabel,
            _resolvedWeaponClass,
            _resolvedWeaponType,
            toLower _slotToken,
            _expectedWeaponType
        ]
    ] call _fail
};

private _resolvedAttachmentCompat = [];
private _resolvedAttachmentCfg = _weaponAttachmentsCfg >> _resolvedWeaponClass;
if (isClass _resolvedAttachmentCfg) then {
    _resolvedAttachmentCompat = getArray (_resolvedAttachmentCfg >> "values");
};

private _incompatibleAttachmentIndex = _ordinaryRequested findIf {!(_x in _resolvedAttachmentCompat)};
if (_incompatibleAttachmentIndex >= 0) exitWith {
    private _badAttachment = _ordinaryRequested select _incompatibleAttachmentIndex;
    [
        "ERR_INCOMPATIBLE_ATTACHMENT",
        format ["Attachment '%1' is not compatible with canonical weapon '%2'.", _badAttachment, _resolvedWeaponClass]
    ] call _fail
};

private _unknownMagazineIndex = _canonicalMagazines findIf {!(isClass (_sourceMagazinesCfg >> _x))};
if (_unknownMagazineIndex >= 0) exitWith {
    private _unknownMagazine = _canonicalMagazines select _unknownMagazineIndex;
    [
        "ERR_UNKNOWN_MAGAZINE",
        format ["Requested magazine '%1' does not exist in canonical source catalogue.", _unknownMagazine]
    ] call _fail
};

private _resolvedMagazineCompat = [];
private _resolvedMagazineCfg = _weaponMagazinesCfg >> _resolvedWeaponClass;
if (isClass _resolvedMagazineCfg) then {
    _resolvedMagazineCompat = getArray (_resolvedMagazineCfg >> "values");
};

private _incompatibleMagazineIndex = _canonicalMagazines findIf {!(_x in _resolvedMagazineCompat)};
if (_incompatibleMagazineIndex >= 0) exitWith {
    private _badMagazine = _canonicalMagazines select _incompatibleMagazineIndex;
    [
        "ERR_INCOMPATIBLE_MAGAZINE",
        format ["Magazine '%1' is not compatible with canonical weapon '%2'.", _badMagazine, _resolvedWeaponClass]
    ] call _fail
};

private _validatedWeapon = createHashMapFromArray [
    ["weaponClass", _resolvedWeaponClass],
    ["magazines", _canonicalMagazines],
    ["attachments", _canonicalAttachments],
    ["structuralAttachments", _structuralRequested],
    ["ordinaryAttachments", _ordinaryRequested]
];

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", format ["%1 composition request validated.", _slotLabel]],
    ["validatedWeapon", _validatedWeapon]
]
