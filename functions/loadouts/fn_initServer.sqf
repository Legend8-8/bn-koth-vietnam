/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Builds server-local resolved loadout definitions from config-authored equipment choices and canonical S.O.G. facts.
    Execution: Server
    Parameters:
        None
    Returns:
        Loadout definition count <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMap];
missionNamespace setVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
missionNamespace setVariable ["BN_KOTH_loadoutsInitialized", false];

private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogueClass = if (isClass _settingsCfg) then {getText (_settingsCfg >> "catalogueClass")} else {"CfgBnKothArsenal"};
if (_catalogueClass isEqualTo "") then {_catalogueClass = "CfgBnKothArsenal";};

private _arsenalCfg = missionConfigFile >> _catalogueClass;
private _loadoutsCfg = _arsenalCfg >> "Loadouts";
private _compatibilityCfg = _arsenalCfg >> "Equipment" >> "Compatibility";
private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
if (!(isClass _arsenalCfg) || {!(isClass _loadoutsCfg)} || {!(isClass _compatibilityCfg)} || {!(isClass _sourceWeaponsCfg)} || {!(isClass _sourceItemsCfg)}) exitWith {
    [format ["Loadouts init skipped: %1 loadout or compatibility config missing", _catalogueClass], "WARN"] call bn_koth_fnc_common_log;
    0
};

private _resolveSide = {
    params ["_token"];
    switch (toUpper _token) do {
        case "WEST": {west}; case "EAST": {east};
        case "RESISTANCE"; case "GUER": {resistance};
        case "CIVILIAN": {civilian}; default {sideUnknown};
    }
};

private _buildTemplateLoadout = {
    params ["_unitClass", "_sideToken"];
    private _side = [_sideToken] call _resolveSide;
    if (_side isEqualTo sideUnknown || {!(isClass (configFile >> "CfgVehicles" >> _unitClass))}) exitWith {[]};
    private _group = createGroup [_side, true];
    private _unit = _group createUnit [_unitClass, [0, 0, 0], [], 0, "NONE"];
    private _loadout = getUnitLoadout _unit;
    deleteVehicle _unit;
    if (!isNull _group && {(count units _group) isEqualTo 0}) then {deleteGroup _group;};
    _loadout
};

private _validateWearable = {
    params ["_className", "_kind"];
    if (_className isEqualTo "") exitWith {true};
    switch (_kind) do {
        case "uniform": {private _c=configFile>>"CfgWeapons">>_className; isClass _c && {getNumber (_c>>"ItemInfo">>"type") isEqualTo 801}};
        case "vest": {private _c=configFile>>"CfgWeapons">>_className; isClass _c && {getNumber (_c>>"ItemInfo">>"type") isEqualTo 701}};
        case "backpack": {private _c=configFile>>"CfgVehicles">>_className; isClass _c && {getNumber (_c>>"isBackpack") > 0}};
        case "headgear": {private _c=configFile>>"CfgWeapons">>_className; isClass _c && {getNumber (_c>>"ItemInfo">>"type") isEqualTo 605}};
        case "facewear": {isClass (configFile >> "CfgGlasses" >> _className)};
        default {false};
    }
};

private _buildCargoEntry = {
    params ["_className", "_count"];
    private _magCfg = configFile >> "CfgMagazines" >> _className;
    if (isClass _magCfg) exitWith {
        private _capacity = getNumber (_magCfg >> "count");
        if (_capacity > 0) then {[_className, _count, _capacity]} else {[]}
    };
    if (isClass (configFile >> "CfgWeapons" >> _className) || {isClass (configFile >> "CfgVehicles" >> _className)}) exitWith {[_className, _count]};
    []
};

private _definitions = createHashMap;
private _loadedCount = 0;

{
    private _cfg = _x;
    private _id = configName _cfg;
    private _sideToken = toUpper (getText (_cfg >> "side"));
    private _source = toUpper (getText (_cfg >> "source"));
    private _unitClass = getText (_cfg >> "unitClass");
    private _failure = "";
    private _loadout = [];
    private _resolvedMagazines = createHashMap;

    if ((_id isEqualTo "") || {_sideToken isEqualTo ""}) then {_failure = "missing id or side";};
    if (_failure isEqualTo "" && {([_sideToken] call _resolveSide) isEqualTo sideUnknown}) then {_failure = format ["invalid side '%1'", _sideToken];};
    if (_failure isEqualTo "" && {!(_source isEqualTo "UNIT_CLASS_TEMPLATE")}) then {_failure = format ["unsupported source '%1'", _source];};
    if (_failure isEqualTo "" && {_unitClass isEqualTo ""}) then {_failure = "UNIT_CLASS_TEMPLATE missing unitClass";};
    if (_failure isEqualTo "") then {
        _loadout = [_unitClass, _sideToken] call _buildTemplateLoadout;
        if !(_loadout isEqualType [] && {(count _loadout) >= 10}) then {_failure = "template did not produce a valid Unit Loadout Array";};
    };

    private _weaponSpecs = [
        ["primary", "PRIMARY", "Primary", true, 0],
        ["launcher", "LAUNCHER", "Launcher", false, 1],
        ["handgun", "HANDGUN", "Handgun", true, 2]
    ];

    {
        if (_failure isEqualTo "") then {
            _x params ["_name", "_token", "_label", "_required", "_index"];
            private _weaponClass = toLower (getText (_cfg >> (_name + "Weapon")));
            private _attachments = getArray (_cfg >> (_name + "Attachments"));
            if (_weaponClass isEqualTo "") then {
                if (_required) then {_failure = format ["required %1Weapon is empty", _name];} else {
                    private _templateSlot = _loadout select _index;
                    _loadout set [_index, if (_templateSlot isEqualType [] && {(count _templateSlot) >= 7}) then {["", "", "", "", [], [], ""]} else {[]}];
                };
            } else {
                private _weaponMetadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
                private _weaponSidePolicy = [
                    _sideToken,
                    _weaponMetadata,
                    false
                ] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
                if !(_weaponSidePolicy getOrDefault ["allowed", false]) then {
                    _failure = format [
                        "%1 weapon '%2' is not allowed for %3 (%4)",
                        _label,
                        _weaponClass,
                        _sideToken,
                        _weaponSidePolicy getOrDefault ["code", "LOCKED_SIDE"]
                    ];
                };

                private _weaponFactCfg = _sourceWeaponsCfg >> _weaponClass;
                private _magazineClass = if (isClass _weaponFactCfg) then {toLower (getText (_weaponFactCfg >> "baseMagazine"))} else {""};
                private _compatibleMagazines = if (isClass _weaponFactCfg) then {(getArray (_weaponFactCfg >> "compatibleMagazines")) apply {toLower _x}} else {[]};
                if (_magazineClass isEqualTo "" || {!(_magazineClass in _compatibleMagazines)}) then {
                    _failure = format ["%1 weapon '%2' has no valid canonical baseMagazine", _label, _weaponClass];
                } else {
                    private _validation = [createHashMapFromArray [
                        ["weaponClass", _weaponClass], ["magazines", [_magazineClass]], ["attachments", _attachments]
                    ], _compatibilityCfg, _token, _label] call bn_koth_fnc_loadouts_validateWeaponComposition;
                    if !(_validation getOrDefault ["success", false]) then {
                        _failure = format ["%1 validation failed (%2): %3", _label, _validation getOrDefault ["code", "ERR_WEAPON"], _validation getOrDefault ["message", "unknown error"]];
                    } else {
                        private _slotResult = [_name, _validation getOrDefault ["validatedWeapon", createHashMap]] call bn_koth_fnc_loadouts_buildWeaponSlot;
                        if !(_slotResult getOrDefault ["success", false]) then {
                            _failure = format ["%1 slot build failed (%2): %3", _label, _slotResult getOrDefault ["code", "ERR_SLOT"], _slotResult getOrDefault ["message", "unknown error"]];
                        } else {
                            _loadout set [_index, _slotResult getOrDefault ["slot", []]];
                            _resolvedMagazines set [_name, _magazineClass];
                        };
                    };
                };
            };
        };
    } forEach _weaponSpecs;

    private _cargoByContainer = createHashMapFromArray [["uniform", []], ["vest", []], ["backpack", []]];
    {
        if (_failure isEqualTo "") then {
            _x params ["_kind", "_index"];
            private _className = toLower (getText (_cfg >> _kind));
            if !([_className, _kind] call _validateWearable) then {_failure = format ["configured %1 '%2' is invalid", _kind, _className];} else {
                if !(_className isEqualTo "") then {
                    private _metadata = ["Wearables", _className] call bn_koth_fnc_loadouts_getItemMetadata;
                    private _sidePolicy = [
                        _sideToken,
                        _metadata,
                        true
                    ] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
                    if !(_sidePolicy getOrDefault ["allowed", false]) then {
                        _failure = format [
                            "configured %1 '%2' violates %3 appearance policy (%4)",
                            _kind,
                            _className,
                            _sideToken,
                            _sidePolicy getOrDefault ["code", "LOCKED_APPEARANCE_SIDE"]
                        ];
                    };
                };
                switch (_kind) do {
                    case "uniform"; case "vest"; case "backpack": {_loadout set [_index, if (_className isEqualTo "") then {[]} else {[_className, []]}];};
                    default {_loadout set [_index, _className];};
                };
            };
        };
    } forEach [["uniform",3],["vest",4],["backpack",5],["headgear",6],["facewear",7]];

    if (_failure isEqualTo "") then {
        private _binocular = toLower (getText (_cfg >> "binocular"));
        if (_binocular isEqualTo "") then {
            private _templateBinocular = _loadout select 8;
            _loadout set [8, if (_templateBinocular isEqualType []) then {[]} else {""}];
        } else {
            private _type = [_binocular] call BIS_fnc_itemType;
            if !((_type isEqualType []) && {(count _type) >= 2} && {(toLower (_type select 1)) isEqualTo "binocular"}) then {_failure = format ["configured binocular '%1' is invalid", _binocular];} else {
                _loadout set [8, [_binocular, "", "", "", [], [], ""]];
            };
        };
    };

    if (_failure isEqualTo "") then {
        private _assigned = (getArray (_cfg >> "assignedItems")) apply {toLower _x};
        if !(_assigned isEqualType [] && {(count _assigned) isEqualTo 6}) then {
            _failure = "assignedItems must contain six classes in Arma slot order";
        } else {
            {
                if (_failure isEqualTo "") then {
                    private _assignedCheck = [_forEachIndex, _x, _sourceItemsCfg] call bn_koth_fnc_loadouts_validateAssignedItemSlot;
                    if !(_assignedCheck getOrDefault ["success", false]) then {
                        _failure = format ["assignedItems validation failed (%1): %2", _assignedCheck getOrDefault ["code", "ERR_ASSIGNED"], _assignedCheck getOrDefault ["message", "unknown error"]];
                    };
                };
            } forEach _assigned;
            if (_failure isEqualTo "") then {_loadout set [9, _assigned];};
        };
    };

    {
        if (_failure isEqualTo "") then {
            if !(_x isEqualType [] && {(count _x) isEqualTo 3}) then {_failure = "cargo entries must be {classname, count, container}";} else {
                _x params ["_className", "_count", "_container"];
                _className = toLower _className; _container = toLower _container;
                if !((_count isEqualType 0) && {_count > 0} && {_container in ["uniform","vest","backpack"]}) then {_failure = format ["cargo entry for '%1' has invalid count or container", _className];} else {
                    private _entry = [_className, _count] call _buildCargoEntry;
                    if ((count _entry) isEqualTo 0) then {_failure = format ["cargo class '%1' is invalid", _className];} else {
                        private _entries = _cargoByContainer get _container; _entries pushBack _entry; _cargoByContainer set [_container, _entries];
                    };
                };
            };
        };
    } forEach (getArray (_cfg >> "cargo"));

    {
        if (_failure isEqualTo "") then {
            _x params ["_name", "_token", "_label", "_required", "_index"];
            if !((getText (_cfg >> (_name + "Weapon"))) isEqualTo "") then {
                private _magazine = _resolvedMagazines getOrDefault [_name, ""];
                private _count = getNumber (_cfg >> (_name + "MagazineCount"));
                private _container = toLower (getText (_cfg >> (_name + "MagazineContainer")));
                if (_count < 0 || {!(_container in ["uniform","vest","backpack"])}) then {_failure = format ["%1 spare magazine count or container is invalid", _label];} else {
                    if (_count > 0) then {
                        private _entry = [_magazine, _count] call _buildCargoEntry;
                        if ((count _entry) isEqualTo 0) then {_failure = format ["%1 magazine '%2' has invalid capacity", _label, _magazine];} else {
                            private _entries = _cargoByContainer get _container; _entries pushBack _entry; _cargoByContainer set [_container, _entries];
                        };
                    };
                };
            };
        };
    } forEach _weaponSpecs;

    {
        if (_failure isEqualTo "") then {
            _x params ["_container", "_index"];
            private _slot = _loadout select _index;
            private _entries = _cargoByContainer get _container;
            if ((count _entries) > 0 && {!(_slot isEqualType [] && {(count _slot) >= 2} && {!((_slot select 0) isEqualTo "")})}) then {_failure = format ["%1 cargo configured but no %1 is equipped", _container];} else {
                if (_slot isEqualType [] && {(count _slot) >= 2}) then {_slot set [1, _entries]; _loadout set [_index, _slot];};
            };
        };
    } forEach [["uniform",3],["vest",4],["backpack",5]];

    if (_failure isEqualTo "") then {
        _definitions set [_id, createHashMapFromArray [["id",_id],["sideToken",_sideToken],["source",_source],["unitClass",_unitClass],["loadout",_loadout]]];
        _loadedCount = _loadedCount + 1;
        [format ["Loadout '%1' initialized from configured starter equipment.", _id], "INFO"] call bn_koth_fnc_common_log;
    } else {[format ["Loadout '%1' skipped: %2", _id, _failure], "WARN"] call bn_koth_fnc_common_log;};
} forEach ("true" configClasses _loadoutsCfg);

missionNamespace setVariable ["BN_KOTH_loadoutDefinitions", _definitions];
missionNamespace setVariable ["BN_KOTH_loadoutsInitialized", true];
[format ["Loadouts initialized: %1 definition(s) loaded", _loadedCount], "INFO"] call bn_koth_fnc_common_log;
_loadedCount
