/*
    File: test_weaponAttribution.sqf
    Author: Legend
    Description: Focused in-engine tests for fail-closed factual weapon
        attribution. Run after mission functions/config are initialized.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};
private _ammoForWeapon = {
    params ["_weaponClass"];
    private _compatibilityCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility";
    private _weaponMagCfg = _compatibilityCfg >> "WeaponMagazines" >> _weaponClass;
    private _magazines = if (isArray (_weaponMagCfg >> "values")) then {getArray (_weaponMagCfg >> "values")} else {[]};
    if (_magazines isEqualTo []) exitWith {""};
    getText (_compatibilityCfg >> "SourceMagazines" >> (_magazines select 0) >> "ammoClass")
};

private _m16Ammo = ["vn_m16"] call _ammoForWeapon;
private _m1911Ammo = ["vn_m1911"] call _ammoForWeapon;

private _result = [_m16Ammo, ["vn_m16"], "INFANTRY"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["M16 uniquely attributed", (_result getOrDefault ["result", ""]) isEqualTo "ATTRIBUTED"] call _check;
["M16 canonical root", (_result getOrDefault ["canonicalCandidates", []]) isEqualTo ["vn_m16"]] call _check;

_result = [_m16Ammo, ["vn_m16_camo"], "INFANTRY"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["Structural M16 canonicalises", (_result getOrDefault ["canonicalCandidates", []]) isEqualTo ["vn_m16"]] call _check;

_result = [_m16Ammo, ["vn_m16", "vn_gau5a"], "INFANTRY"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["Shared ammo is ambiguous", (_result getOrDefault ["result", ""]) isEqualTo "AMBIGUOUS"] call _check;

_result = [_m1911Ammo, ["vn_m1911"], "INFANTRY"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["Pistol uniquely attributed", (_result getOrDefault ["canonicalCandidates", []]) isEqualTo ["vn_m1911"]] call _check;

_result = ["vn_m67_grenade_ammo", ["vn_m16"], "INFANTRY"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["Grenade does not become rifle", (_result getOrDefault ["result", ""]) isEqualTo "UNKNOWN"] call _check;
["Grenade category rejected", (_result getOrDefault ["reason", ""]) in ["NON_INFANTRY_AMMO_CATEGORY", "NO_COMPATIBLE_CARRIED_WEAPON"]] call _check;

_result = ["vn_40mm_m381_he_ammo", ["vn_m16_m203"], "INFANTRY"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["Underbarrel grenade does not become M16 mastery", (_result getOrDefault ["result", ""]) isEqualTo "UNKNOWN"] call _check;
["Underbarrel grenade category rejected", (_result getOrDefault ["reason", ""]) isEqualTo "NON_INFANTRY_AMMO_CATEGORY"] call _check;

_result = [_m16Ammo, ["vn_m16"], "VEHICLE"] call bn_koth_fnc_combat_evaluateWeaponAttribution;
["Vehicle source fails closed", (_result getOrDefault ["reason", ""]) isEqualTo "NON_INFANTRY_SOURCE"] call _check;

private _makeHit = {
    params ["_observedAt", "_attacker", "_canonicalClass", "_projectileId", ["_victimAlive", true]];
    createHashMapFromArray [
        ["observedAt", _observedAt],
        ["source", _attacker],
        ["instigator", _attacker],
        ["victimAliveAtObservation", _victimAlive],
        ["ammo", format ["ammo_%1", _canonicalClass]],
        ["projectileId", _projectileId],
        ["correlation", createHashMapFromArray [
            ["result", "ATTRIBUTED"],
            ["candidateWeapons", [_canonicalClass]],
            ["canonicalCandidates", [_canonicalClass]]
        ]]
    ]
};

private _aliveHit = [99.9, "attacker_a", "vn_m16", "projectile_1", true] call _makeHit;
_result = [[_aliveHit], "attacker_a", 100, 2] call bn_koth_fnc_combat_evaluateKillAttributionEvidence;
["Alive-at-hit then immediate EntityKilled attributes", (_result getOrDefault ["result", ""]) isEqualTo "ATTRIBUTED"] call _check;

private _staleHit = [97.9, "attacker_a", "vn_m16", "projectile_stale"] call _makeHit;
_result = [[_staleHit], "attacker_a", 100, 2] call bn_koth_fnc_combat_evaluateKillAttributionEvidence;
["Stale hit rejected", (_result getOrDefault ["result", ""]) isEqualTo "UNKNOWN"] call _check;

private _otherAttackerHit = [99.9, "attacker_b", "vn_m16", "projectile_other"] call _makeHit;
_result = [[_otherAttackerHit], "attacker_a", 100, 2] call bn_koth_fnc_combat_evaluateKillAttributionEvidence;
["Different attacker rejected", (_result getOrDefault ["result", ""]) isEqualTo "UNKNOWN"] call _check;

private _m16Hit = [99.8, "attacker_a", "vn_m16", "projectile_m16"] call _makeHit;
private _pistolHit = [99.9, "attacker_a", "vn_m1911", "projectile_m1911"] call _makeHit;
_result = [[_m16Hit, _pistolHit], "attacker_a", 100, 2] call bn_koth_fnc_combat_evaluateKillAttributionEvidence;
["Conflicting recent canonical candidates ambiguous", (_result getOrDefault ["result", ""]) isEqualTo "AMBIGUOUS"] call _check;

private _secondM16Hit = [99.95, "attacker_a", "vn_m16", "projectile_m16_2"] call _makeHit;
_result = [[_m16Hit, _secondM16Hit], "attacker_a", 100, 2] call bn_koth_fnc_combat_evaluateKillAttributionEvidence;
["Multiple recent hits from one canonical root attribute", (_result getOrDefault ["canonicalCandidates", []]) isEqualTo ["vn_m16"]] call _check;
["Single canonical candidate across evidence attributed", (_result getOrDefault ["result", ""]) isEqualTo "ATTRIBUTED"] call _check;

diag_log format ["[BN_KOTH_TEST] Weapon attribution: %1 failure(s): %2", count _failures, _failures];
_failures
