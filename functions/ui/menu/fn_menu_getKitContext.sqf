/*
    File: fn_menu_getKitContext.sqf
    Author: Legend
    Description: Reads the shared local kit storage contract for menu and team intent.
        Three-field legacy records remain an unassigned archive; never infer a team.
    Execution: Client (unscheduled)
    Parameters: 0: Requested team token, empty for current server-projected team <STRING>
    Returns: Local kits, team preference and presentation-only slot access <HASHMAP>
    Public: No
*/
params [["_sideToken", "", [""]]];
if (!hasInterface) exitWith {createHashMap};
if (_sideToken isEqualTo "") then {
    private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
    _sideToken = toUpper str (_assignments getOrDefault [getPlayerUID player, sideUnknown]);
};
private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
if !(_kits isEqualType []) then {_kits = []};
if (_kits isEqualTo []) then {
    private _old = profileNamespace getVariable ["BN_KOTH_savedKits_v1", createHashMap];
    if (_old isEqualType createHashMap) then {
        private _loadout = _old getOrDefault ["slot1", []];
        if (_loadout isEqualType [] && {count _loadout >= 10}) then {
            _kits pushBack ["kit_migrated_slot1", "MIGRATED KIT", +_loadout];
            profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
            profileNamespace setVariable ["BN_KOTH_savedKits_v1", nil];
            saveProfileNamespace;
        };
    };
};
_kits = _kits select {_x isEqualType [] && {count _x >= 3} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType ""} && {(_x select 2) isEqualType []}};
private _teamKits = _kits select {
    count _x >= 5 && {(_x select 3) isEqualTo _sideToken}
    && {(_x select 4) isEqualType 0} && {finite (_x select 4)}
    && {(_x select 4) >= 1} && {(_x select 4) isEqualTo floor (_x select 4)}
};
private _preferences = profileNamespace getVariable ["BN_KOTH_preferredSpawnKitIds", createHashMap];
if !(_preferences isEqualType createHashMap) then {_preferences = createHashMap};
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _unlocked = _progression getOrDefault ["unlockedLoadoutSlots", 1];
if !(_unlocked isEqualType 0 && {finite _unlocked} && {_unlocked >= 1} && {_unlocked isEqualTo floor _unlocked}) then {_unlocked = 1};
private _preferredId = _preferences getOrDefault [_sideToken, ""];
if !(_preferredId isEqualType "") then {_preferredId = ""};
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maximum = floor ((getNumber (_cfg >> "savedKitMaxCount")) max 1);
createHashMapFromArray [
    ["sideToken", _sideToken], ["kits", _kits], ["teamKits", _teamKits],
    ["legacyKits", _kits select {count _x isEqualTo 3}],
    ["preferences", _preferences], ["preferredId", _preferredId],
    ["unlocked", _unlocked min _maximum], ["maximum", _maximum],
    ["prices", getArray (_cfg >> "savedKitSlotPrices")]
]
