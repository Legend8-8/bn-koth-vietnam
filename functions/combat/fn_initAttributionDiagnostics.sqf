/*
    File: fn_initAttributionDiagnostics.sqf
    Author: Legend
    Description: Registers server attribution collection on created projectile
        objects. Exact hit evidence is server-local and bounded; verbose RPT
        diagnostics remain disabled by default.
    Execution: Server
    Parameters: None
    Returns: Whether server attribution collection is initialized <BOOL>
    Public: No
*/

if (!isServer) exitWith {false};

private _combatCfg = missionConfigFile >> "CfgBnKothCombat";
private _configured = isNumber (_combatCfg >> "attributionDiagnostics")
    && {getNumber (_combatCfg >> "attributionDiagnostics") > 0};
private _diagnosticsEnabled = missionNamespace getVariable ["BN_KOTH_combatAttributionDiagnostics", _configured];
missionNamespace setVariable ["BN_KOTH_combatAttributionDiagnosticsEnabled", _diagnosticsEnabled];
if (missionNamespace getVariable ["BN_KOTH_combatAttributionDiagnosticsInitialized", false]) exitWith {true};

private _maxHits = if (isNumber (_combatCfg >> "attributionMaxHitsPerVictim")) then {
    (round (getNumber (_combatCfg >> "attributionMaxHitsPerVictim"))) max 4
} else {16};
missionNamespace setVariable ["BN_KOTH_combatAttributionMaxHits", _maxHits];
missionNamespace setVariable ["BN_KOTH_combatAttributionDiagnosticsInitialized", true];

private _projectileCreatedId = addMissionEventHandler ["ProjectileCreated", {
    params ["_projectile"];
    if (!isServer || {isNull _projectile}) exitWith {};

    private _parents = getShotParents _projectile;
    _parents params [["_source", objNull], ["_instigator", objNull]];
    private _platform = if (!isNull _source) then {_source} else {
        if (isNull _instigator) then {objNull} else {vehicle _instigator}
    };
    private _sourceKind = if (isNull _instigator) then {"UNKNOWN"} else {
        if (!isNull _platform && {!(_platform isEqualTo _instigator)}) then {"VEHICLE"} else {"INFANTRY"}
    };
    private _inventoryWeapons = if (!isNull _instigator && {_instigator isKindOf "Man"}) then {
        weapons _instigator
    } else {[]};
    private _ammo = toLower (typeOf _projectile);
    private _evaluation = [_ammo, _inventoryWeapons, _sourceKind] call bn_koth_fnc_combat_evaluateWeaponAttribution;
    private _projectileId = netId _projectile;
    if (_projectileId isEqualTo "" || {_projectileId isEqualTo "0:0"}) then {
        _projectileId = str _projectile;
    };

    private _facts = createHashMapFromArray [
        ["projectileId", _projectileId], ["ammo", _ammo],
        ["source", _source], ["instigator", _instigator],
        ["sourceKind", _sourceKind], ["inventoryWeapons", _inventoryWeapons],
        ["createdAt", diag_tickTime], ["createdFrame", diag_frameNo],
        ["evaluation", _evaluation]
    ];
    _projectile setVariable ["BN_KOTH_combatAttributionFacts", _facts, false];

    if (missionNamespace getVariable ["BN_KOTH_combatAttributionDiagnosticsEnabled", false]) then {
        diag_log format ["[BN_KOTH][ATTRIBUTION] PROJECTILE %1", createHashMapFromArray [
            ["projectile", _projectileId], ["ammo", _ammo], ["source", str _source],
            ["instigator", str _instigator], ["sourceKind", _sourceKind],
            ["inventoryWeapons", _inventoryWeapons], ["evaluation", _evaluation]
        ]];
    };

    _projectile addEventHandler ["HitPart", {
        params ["_projectile", "_hitEntity", "_projectileOwner", "_pos", "_velocity", "_normal", "_components", "_radius", "_surfaceType", "_instigator"];
        [_projectile, _hitEntity, _instigator, "DIRECT"] call bn_koth_fnc_combat_recordAttributionHit;
    }];
    _projectile addEventHandler ["HitExplosion", {
        params ["_projectile", "_hitEntity", "_projectileOwner", "_hitSelections", "_instigator"];
        [_projectile, _hitEntity, _instigator, "EXPLOSION"] call bn_koth_fnc_combat_recordAttributionHit;
    }];
    _projectile addEventHandler ["Deleted", {
        params ["_projectile"];
        private _facts = _projectile getVariable ["BN_KOTH_combatAttributionFacts", createHashMap];
        private _createdAt = _facts getOrDefault ["createdAt", -1];
        if (missionNamespace getVariable ["BN_KOTH_combatAttributionDiagnosticsEnabled", false]) then {
            diag_log format ["[BN_KOTH][ATTRIBUTION] PROJECTILE_DELETED projectile=%1 lifetime=%2", _facts getOrDefault ["projectileId", str _projectile], if (_createdAt < 0) then {-1} else {diag_tickTime - _createdAt}];
        };
    }];
}];

missionNamespace setVariable ["BN_KOTH_combatAttributionProjectileCreatedEhId", _projectileCreatedId];
if (_diagnosticsEnabled) then {
    diag_log format ["[BN_KOTH][ATTRIBUTION] ENABLED projectileCreatedEh=%1", _projectileCreatedId];
};
true
