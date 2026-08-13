/*
    File: fn_validateLoadout.sqf
    Author: Legend
    Description: Server-authoritative validation for requested loadout IDs using canonical arsenal configuration.
    Execution: Server
    Parameters:
        0: Requesting player object <OBJECT>
        1: Loadout request <HASHMAP|ARRAY>
           HASHMAP schema:
             loadoutId <STRING> (required)
             side <STRING> (optional, cross-check only)
    Returns:
        Validation result <HASHMAP>
    Public: Yes
*/

params [
    ["_player", objNull, [objNull]],
    ["_request", createHashMap, [createHashMap, []]]
];

private _fail = {
    params ["_code", "_message", ["_loadoutId", "", [""]], ["_sideToken", "", [""]]];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["loadoutId", _loadoutId],
        ["sideToken", _sideToken],
        ["validatedLoadout", []],
        ["validatedPrimary", createHashMap],
        ["validatedBy", ""]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Loadout validation must run on server."] call _fail
};

if (isNull _player || {!isPlayer _player}) exitWith {
    ["ERR_INVALID_PLAYER", "Loadout validation requires a connected player object."] call _fail
};

private _requestedLoadoutId = "";
private _requestedLoadoutIdRaw = objNull;
private _requestedSideToken = "";
private _primaryRequest = createHashMap;
private _hasLoadoutIntent = false;
private _hasPrimaryIntent = false;
private _requestMode = "";

if (_request isEqualType createHashMap) then {
    private _requestKeys = keys _request;
    _hasLoadoutIntent = "loadoutId" in _requestKeys;
    if (_hasLoadoutIntent) then {
        _requestedLoadoutIdRaw = _request get "loadoutId";
    };
    _requestedSideToken = toUpper (_request getOrDefault ["side", ""]);
    _hasPrimaryIntent = "primary" in _requestKeys;
    if (_hasPrimaryIntent) then {
        _primaryRequest = _request getOrDefault ["primary", objNull];
    };
} else {
    if ((_request isEqualType []) && {(count _request) > 0}) then {
        _hasLoadoutIntent = true;
        _requestedLoadoutIdRaw = _request select 0;
    };
};

if (_hasLoadoutIntent && _hasPrimaryIntent) exitWith {
    ["ERR_MALFORMED_REQUEST", "Loadout request must choose exactly one mode: loadoutId or primary."] call _fail
};

if (!(_hasLoadoutIntent) && !(_hasPrimaryIntent)) exitWith {
    ["ERR_MALFORMED_REQUEST", "Loadout request missing explicit validation intent."] call _fail
};

if (_hasPrimaryIntent) then {
    _requestMode = "primary";
    if !(_primaryRequest isEqualType createHashMap) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary validation request must provide primary as a map."] call _fail
    };
} else {
    _requestMode = "configured";
};

if ((_requestMode isEqualTo "configured") && {!(_requestedLoadoutIdRaw isEqualType "")}) exitWith {
    ["ERR_MALFORMED_REQUEST", "Configured loadout request requires loadoutId as a non-empty string."] call _fail
};

if ((_requestMode isEqualTo "configured") && {_requestedLoadoutIdRaw isEqualTo ""}) exitWith {
    ["ERR_MALFORMED_REQUEST", "Configured loadout request requires loadoutId as a non-empty string."] call _fail
};

if (_requestMode isEqualTo "configured") then {
    _requestedLoadoutId = toLower _requestedLoadoutIdRaw;
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    ["ERR_RECORDS_UNAVAILABLE", "Player records are unavailable.", _requestedLoadoutId] call _fail
};

private _uid = getPlayerUID _player;
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    ["ERR_PLAYER_NOT_REGISTERED", "Player is not registered in authoritative team records.", _requestedLoadoutId] call _fail
};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    ["ERR_ASSIGNED_SIDE_INVALID", "Player does not have a valid assigned playable side.", _requestedLoadoutId] call _fail
};

private _authoritativeSideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    case resistance: {"RESISTANCE"};
    case civilian: {"CIVILIAN"};
    default {""};
};

if (_authoritativeSideToken isEqualTo "") exitWith {
    ["ERR_SIDE_TOKEN_UNMAPPED", "Assigned side does not map to a supported side token.", _requestedLoadoutId] call _fail
};

if !(_requestedSideToken isEqualTo "") then {
    if !(_requestedSideToken isEqualTo _authoritativeSideToken) exitWith {
        ["ERR_REQUEST_SIDE_MISMATCH", format ["Requested side '%1' does not match authoritative assigned side '%2'.", _requestedSideToken, _authoritativeSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };
};

private _definitions = missionNamespace getVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
if !(_definitions isEqualType createHashMap) then {
    _definitions = createHashMap;
};

private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogueClass = if (isClass _settingsCfg) then {
    getText (_settingsCfg >> "catalogueClass")
} else {
    "CfgBnKothArsenal"
};
if (_catalogueClass isEqualTo "") then {
    _catalogueClass = "CfgBnKothArsenal";
};

private _arsenalCfg = missionConfigFile >> _catalogueClass;
if !(isClass _arsenalCfg) exitWith {
    ["ERR_CATALOGUE_MISSING", format ["Canonical arsenal config class '%1' is missing.", _catalogueClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _compatibilityCfg = _arsenalCfg >> "Equipment" >> "Compatibility";
if !(_requestMode isEqualTo "configured") then {
    if !(isClass _compatibilityCfg) exitWith {
        ["ERR_COMPATIBILITY_MISSING", "Primary validation requires canonical compatibility config.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };
};

if (_requestMode isEqualTo "primary") exitWith {
    private _requestedWeaponClass = _primaryRequest getOrDefault ["weaponClass", ""];
    if !(_requestedWeaponClass isEqualType "") exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary weaponClass must be a string.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    _requestedWeaponClass = toLower _requestedWeaponClass;
    if (_requestedWeaponClass isEqualTo "") exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary request missing weaponClass.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _requestedMagazines = _primaryRequest getOrDefault ["magazines", []];
    if !(_requestedMagazines isEqualType []) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary magazines must be an array of classnames.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _requestedAttachments = _primaryRequest getOrDefault ["attachments", []];
    if !(_requestedAttachments isEqualType []) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary attachments must be an array of classnames.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _invalidMagazineType = _requestedMagazines findIf {!(_x isEqualType "")};
    if (_invalidMagazineType >= 0) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary magazines contains non-string entry.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _requestedMagazinesCanonical = _requestedMagazines apply {toLower _x};
    private _emptyMagazineClass = _requestedMagazinesCanonical findIf {_x isEqualTo ""};
    if (_emptyMagazineClass >= 0) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary magazines contains empty classname.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _canonicalMagazines = [];
    {
        _canonicalMagazines pushBackUnique _x;
    } forEach _requestedMagazinesCanonical;
    _canonicalMagazines sort true;

    private _invalidAttachmentType = _requestedAttachments findIf {!(_x isEqualType "")};
    if (_invalidAttachmentType >= 0) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary attachments contains non-string entry.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _requestedAttachmentsCanonical = _requestedAttachments apply {toLower _x};
    private _emptyAttachmentClass = _requestedAttachmentsCanonical findIf {_x isEqualTo ""};
    if (_emptyAttachmentClass >= 0) exitWith {
        ["ERR_MALFORMED_REQUEST", "Primary attachments contains empty classname.", _requestedLoadoutId, _authoritativeSideToken] call _fail
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
        ["ERR_UNKNOWN_PRIMARY_WEAPON", format ["Primary weapon '%1' does not exist in canonical source catalogue.", _requestedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _variantOf = getText (_requestedWeaponCfg >> "variantOf");
    if !(_variantOf isEqualTo "") exitWith {
        ["ERR_PRIMARY_WEAPON_NOT_BASE", format ["Primary weapon '%1' is structural variant-derived and cannot be requested as base intent.", _requestedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _unknownAttachmentIndex = _canonicalAttachments findIf {!(isClass (_sourceItemsCfg >> _x))};
    if (_unknownAttachmentIndex >= 0) exitWith {
        private _unknownAttachment = _canonicalAttachments select _unknownAttachmentIndex;
        ["ERR_UNKNOWN_ATTACHMENT", format ["Requested attachment '%1' does not exist in canonical source catalogue.", _unknownAttachment], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _transformingAttachments = [];
    if (isClass (_transformingCfg >> _requestedWeaponClass)) then {
        _transformingAttachments = getArray ((_transformingCfg >> _requestedWeaponClass) >> "values");
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
    if !((count _structuralRequested) isEqualTo 0) then {
        if !(isClass _indexBaseCfg) exitWith {
            ["ERR_VARIANT_UNRESOLVED", format ["No structural variant index available for base weapon '%1'.", _requestedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
        };
    };

    if (isClass (_indexBaseCfg >> _variantKey)) then {
        private _variantEntry = _indexBaseCfg >> _variantKey;
        private _isAmbiguous = getNumber (_variantEntry >> "ambiguous");
        if (_isAmbiguous > 0) exitWith {
            ["ERR_VARIANT_AMBIGUOUS", format ["Structural variant mapping for '%1' is ambiguous for requested attachments.", _requestedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
        };

        private _entryStructural = getArray (_variantEntry >> "structuralAttachments");
        _entryStructural sort true;
        if !(_entryStructural isEqualTo _structuralRequested) exitWith {
            ["ERR_VARIANT_INDEX_INCONSISTENT", "Structural variant index data is inconsistent for requested attachment set.", _requestedLoadoutId, _authoritativeSideToken] call _fail
        };

        _resolvedWeaponClass = getText (_variantEntry >> "resolvedWeaponClass");
        if (_resolvedWeaponClass isEqualTo "") exitWith {
            ["ERR_VARIANT_UNRESOLVED", format ["Structural variant could not be resolved for base weapon '%1'.", _requestedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
        };
    } else {
        if !((count _structuralRequested) isEqualTo 0) exitWith {
            ["ERR_VARIANT_UNRESOLVED", format ["No confirmed structural variant exists for requested attachment set on base weapon '%1'.", _requestedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
        };
    };

    if !(isClass (_sourceWeaponsCfg >> _resolvedWeaponClass)) exitWith {
        ["ERR_VARIANT_RESOLVED_CLASS_MISSING", format ["Resolved canonical weapon '%1' is missing from source catalogue.", _resolvedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _resolvedAttachmentCompat = [];
    if (isClass (_weaponAttachmentsCfg >> _resolvedWeaponClass)) then {
        _resolvedAttachmentCompat = getArray ((_weaponAttachmentsCfg >> _resolvedWeaponClass) >> "values");
    };

    private _incompatibleAttachmentIndex = _ordinaryRequested findIf {!(_x in _resolvedAttachmentCompat)};
    if (_incompatibleAttachmentIndex >= 0) exitWith {
        private _badAttachment = _ordinaryRequested select _incompatibleAttachmentIndex;
        ["ERR_INCOMPATIBLE_ATTACHMENT", format ["Attachment '%1' is not compatible with canonical weapon '%2'.", _badAttachment, _resolvedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _unknownMagazineIndex = _canonicalMagazines findIf {!(isClass (_sourceMagazinesCfg >> _x))};
    if (_unknownMagazineIndex >= 0) exitWith {
        private _unknownMagazine = _canonicalMagazines select _unknownMagazineIndex;
        ["ERR_UNKNOWN_MAGAZINE", format ["Requested magazine '%1' does not exist in canonical source catalogue.", _unknownMagazine], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _resolvedMagazineCompat = [];
    if (isClass (_weaponMagazinesCfg >> _resolvedWeaponClass)) then {
        _resolvedMagazineCompat = getArray ((_weaponMagazinesCfg >> _resolvedWeaponClass) >> "values");
    };

    private _incompatibleMagazineIndex = _canonicalMagazines findIf {!(_x in _resolvedMagazineCompat)};
    if (_incompatibleMagazineIndex >= 0) exitWith {
        private _badMagazine = _canonicalMagazines select _incompatibleMagazineIndex;
        ["ERR_INCOMPATIBLE_MAGAZINE", format ["Magazine '%1' is not compatible with canonical weapon '%2'.", _badMagazine, _resolvedWeaponClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _validatedPrimary = createHashMapFromArray [
        ["weaponClass", _resolvedWeaponClass],
        ["magazines", _canonicalMagazines],
        ["attachments", _canonicalAttachments]
    ];

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Primary composition request validated."],
        ["loadoutId", ""],
        ["sideToken", _authoritativeSideToken],
        ["validatedLoadout", []],
        ["validatedPrimary", _validatedPrimary],
        ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"]
    ]
};

private _definition = _definitions getOrDefault [_requestedLoadoutId, objNull];
if !(_definition isEqualType createHashMap) exitWith {
    ["ERR_UNKNOWN_LOADOUT", format ["Loadout '%1' is not configured in canonical catalogue.", _requestedLoadoutId], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _loadoutSideToken = _definition getOrDefault ["sideToken", ""];
if !(_loadoutSideToken isEqualTo _authoritativeSideToken) exitWith {
    ["ERR_SIDE_RESTRICTED", format ["Loadout '%1' is restricted to side '%2'.", _requestedLoadoutId, _loadoutSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _itemsCfg = _arsenalCfg >> "Equipment" >> "Items";
private _unitClass = _definition getOrDefault ["unitClass", ""];

if !(_unitClass isEqualTo "") then {
    if !(isClass (_itemsCfg >> _unitClass)) exitWith {
        ["ERR_CATALOGUE_ITEM_MISSING", format ["Template unit class '%1' is not present in canonical equipment items.", _unitClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _allowedSides = getArray ((_itemsCfg >> _unitClass) >> "allowedSides");
    if ((count _allowedSides) > 0 && {!(_authoritativeSideToken in _allowedSides)}) exitWith {
        ["ERR_ITEM_SIDE_RESTRICTED", format ["Template unit class '%1' is not allowed for side '%2'.", _unitClass, _authoritativeSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };
};

private _validatedLoadout = _definition getOrDefault ["loadout", []];
if !(_validatedLoadout isEqualType []) then {
    _validatedLoadout = [];
};

if ((count _validatedLoadout) <= 0) exitWith {
    ["ERR_LOADOUT_EMPTY", format ["Loadout '%1' resolved empty.", _requestedLoadoutId], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

// Deliberate future boundary:
// progression entitlement will be checked here via an explicit registered
// progression API function owned by functions/progression when implemented.

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", "Loadout request validated."],
    ["loadoutId", _requestedLoadoutId],
    ["sideToken", _authoritativeSideToken],
    ["validatedLoadout", _validatedLoadout],
    ["validatedPrimary", createHashMap],
    ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"]
]
