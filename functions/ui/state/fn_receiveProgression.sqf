/*
    File: fn_receiveProgression.sqf
    Author: Legend
    Description: Applies an authoritative server progression update to the local
        presentation copy and refreshes the deployed menu when it is open.
    Execution: Client
    Parameters:
        0: Progression payload <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params [["_progression", createHashMap, [createHashMap]]];

if (!hasInterface) exitWith {};

// Remote progression updates are server-to-client only. A listen-server host may
// also receive the update by direct local call from the authoritative server.
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

if ((count _progression) == 0) exitWith {};

private _uid = _progression getOrDefault ["uid", ""];
private _xp = _progression getOrDefault ["xp", -1];
private _level = _progression getOrDefault ["level", -1];

if (_uid isEqualTo "" || {_xp < 0} || {_level < 1}) exitWith {};

private _localUid = if (!isNull player) then {getPlayerUID player} else {""};
if !(_localUid isEqualTo _uid) exitWith {};

private _localProgression = missionNamespace getVariable [
    "BN_KOTH_playerProgressionLocal",
    createHashMap
];
if !(_localProgression isEqualType createHashMap) then {
    _localProgression = createHashMap;
};

{
    _localProgression set [_x, _progression get _x];
} forEach (keys _progression);

missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", _localProgression];
[] call bn_koth_fnc_progression_perks_applyMedicTraitLocal;

if (_progression getOrDefault ["savedKitsAuthoritative", false]) then {
    private _serverKits = _progression getOrDefault ["savedKits", []];
    private _localKits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
    private _serverPreferred = _progression getOrDefault ["preferredSavedKitId", ""];
    private _serverInitialized = _progression getOrDefault ["savedKitsInitialized", false];
    private _serverSynced = uiNamespace getVariable ["BN_KOTH_savedKitsServerSynced", false];
    private _shouldSync = if (_serverSynced) then {
        !(_localKits isEqualTo _serverKits)
            || {!((profileNamespace getVariable ["BN_KOTH_preferredSpawnKitId", ""]) isEqualTo _serverPreferred)}
    } else {
        _serverInitialized || {(count _serverKits) > 0} || {!(_localKits isEqualType [])} || {(count _localKits) isEqualTo 0}
    };
    if (_shouldSync) then {
        profileNamespace setVariable ["BN_KOTH_savedKits_v2", +_serverKits];
        profileNamespace setVariable ["BN_KOTH_preferredSpawnKitId", _serverPreferred];
        uiNamespace setVariable ["BN_KOTH_savedKitsServerSynced", true];
        saveProfileNamespace;
    };
};

private _rewardAmount = _progression getOrDefault ["rewardAmount", _progression getOrDefault ["amount", 0]];
private _rewardReason = _progression getOrDefault ["rewardReason", _progression getOrDefault ["reason", ""]];
private _rewardType = toLower (_progression getOrDefault ["rewardType", "xp"]);
private _eventTypes = ["mastery", "acquisition", "perk_purchase", "perk_activation", "level_up", "teamkill", "streak"];
if (!(_rewardAmount isEqualTo 0) || {_rewardType in _eventTypes}) then {
    if !(_rewardReason isEqualTo "") then {
        private _reasonLabel = switch (toLower _rewardReason) do {
            case "kill": {"KILL"};
            case "assist": {"ASSIST"};
            case "control": {"OBJECTIVE"};
            case "priority": {"PRIORITY"};
            case "transport": {"TRANSPORT"};
            case "air_insertion": {"AIR INSERTION"};
            case "round_participation": {"ROUND PARTICIPATION"};
            case "round_winner": {"VICTORY BONUS"};
            case "teamkill": {"TEAMKILL PENALTY"};
            case "objective_participation": {"OBJECTIVE PARTICIPATION"};
            case "objective_control": {"OBJECTIVE CONTROL"};
            case "objective_priority": {"OBJECTIVE + PRIORITY"};
            case "objective_control_priority": {"CONTROL + PRIORITY"};
            case "weapon_kill": {"WEAPON MASTERY"};
            case "revive": {"REVIVE"};
            default {toUpper _rewardReason};
        };

        if (_rewardType isEqualTo "level_up") then {
            _reasonLabel = format ["PROMOTED TO LEVEL %1", _rewardReason];
        };
        if (_rewardType isEqualTo "teamkill") then {_reasonLabel = "TEAMKILL RECORDED"};
        if (_rewardType isEqualTo "acquisition") then {
            _reasonLabel = if ((toLower _rewardReason) isEqualTo "purchase") then {"WEAPON PURCHASED"} else {"WEAPON RENTED"};
        };
        if (_rewardType in ["perk_purchase", "perk_activation"]) then {
            _reasonLabel = format ["%1: %2", if (_rewardType isEqualTo "perk_purchase") then {"PERK PURCHASED"} else {"PERK UPDATED"}, toUpper _rewardReason];
        };

        [_rewardType, _rewardAmount, _reasonLabel] call bn_koth_fnc_ui_addRewardFeedEntry;
    };
};

disableSerialization;
[] call bn_koth_fnc_ui_refreshLobby;
// Store's cached weapon entries must not go stale even when acquired from Arsenal.
uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", ""];
private _menuDisplay = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _menuDisplay) then {
    [_menuDisplay] call bn_koth_fnc_menu_refreshProgressionHeader;

    // Only pages whose presentation depends directly on progression need a
    // targeted repaint. Do not rebuild/re-route the entire deployed menu.
    private _activePage = toUpper (uiNamespace getVariable ["BN_KOTH_menuActivePage", "LOADOUT"]);
    switch (_activePage) do {
        case "PERKS": {
            [_menuDisplay] call bn_koth_fnc_menu_refreshPerks;
        };
        case "STORE": {
            [_menuDisplay] call bn_koth_fnc_menu_refreshStore;
        };
        case "PROGRESSION": {
            [_menuDisplay] call bn_koth_fnc_menu_refreshProgression;
        };
    };
};
