/*
    File: fn_testKillFeedAi.sqf
    Author: Tylervip
    Description: Creates a local AI attacker/victim pair and publishes a synthetic
        kill record so the kill feed can be tested without a live human player.
        This is intended for local Eden / hosted-server UI validation only.
    Execution: Server
    Parameters:
        0: Killer side <SIDE> (default west)
        1: Victim side <SIDE> (default east)
    Returns:
        The generated kill record <HASHMAP>
    Public: Yes
    useage: Local AI attacker/victim pair for testing kill feed.
    [] call bn_koth_fnc_combat_testKillFeedAi;
    [west, east] call bn_koth_fnc_combat_testKillFeedAi;
*/

params [
    ["_killerSide", west, [west]],
    ["_victimSide", east, [west]]
];

if (!isServer) exitWith {createHashMap};

private _killerGroup = createGroup [_killerSide, true];
private _victimGroup = createGroup [_victimSide, true];

private _killerPos = [100, 100, 0];
private _victimPos = [120, 100, 0];

private _killer = _killerGroup createUnit ["vn_b_men_sog_07", _killerPos, [], 0, "NONE"];
private _victim = _victimGroup createUnit ["vn_o_men_nva_04", _victimPos, [], 0, "NONE"];

if (isNull _killer || {isNull _victim}) exitWith {
    ["combat_testKillFeedAi: failed to create AI units", "ERROR"] call bn_koth_fnc_common_log;
    createHashMap
};

_killer allowDamage false;
_victim allowDamage false;

_killer setDir 270;
_victim setDir 90;
_killer setPosATL _killerPos;
_victim setPosATL _victimPos;

private _killerWeapon = primaryWeapon _killer;
if (_killerWeapon isEqualTo "") then {
    _killer addWeapon "vn_m16";
    _killerWeapon = primaryWeapon _killer;
};

private _victimWeapon = primaryWeapon _victim;
if (_victimWeapon isEqualTo "") then {
    _victim addWeapon "vn_type56";
    _victimWeapon = primaryWeapon _victim;
};

_killer selectWeapon _killerWeapon;
_victim selectWeapon _victimWeapon;

private _killerUid = "BN_KOTH_TEST_AI_KILLER";
private _victimUid = "BN_KOTH_TEST_AI_VICTIM";
private _killerName = "AIKillerName24Chars12345";
private _victimName = "AIVictimName24Chars12345";

private _records = createHashMapFromArray [
    [
        _killerUid,
        createHashMapFromArray [
            ["assignedSide", _killerSide],
            ["name", _killerName],
            ["currentUnit", _killer]
        ]
    ],
    [
        _victimUid,
        createHashMapFromArray [
            ["assignedSide", _victimSide],
            ["name", _victimName],
            ["currentUnit", _victim]
        ]
    ]
];

missionNamespace setVariable ["BN_KOTH_playerRecords", _records, true];

private _weaponAttribution = createHashMapFromArray [
    ["result", "ATTRIBUTED"],
    ["canonicalCandidates", [_killerWeapon]],
    ["reason", "TEST_AI_KILL_FEED"]
];

private _kill = [_victim, _killer, objNull, _weaponAttribution] call bn_koth_fnc_combat_handleKill;

if !(_kill isEqualType createHashMap) then {
    _kill = createHashMap;
};

_killer allowDamage true;
_victim allowDamage true;

_kill
