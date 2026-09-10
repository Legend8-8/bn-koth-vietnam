/*
    File: fn_receiveState.sqf
    Author: tylervip
    Edited: Legend
    Edited: Mongo
    Description: Receives and applies server state snapshot on client.
    Execution: Client
    Parameters:
        0: State payload <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params ["_payload"];

if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

missionNamespace setVariable ["BN_KOTH_clientSnapshot", _payload];

if !(_payload isEqualType createHashMap) exitWith {};

private _keyMap = createHashMapFromArray [
    ["roundState", "BN_KOTH_roundState"],
    ["groupState", "BN_KOTH_groupStateLocal"],
    ["liveLeaders", "BN_KOTH_liveLeaders"],
    ["roundResult", "BN_KOTH_roundResult"],
    ["playerProgression", "BN_KOTH_playerProgressionLocal"],
    ["vehicleRentalState", "BN_KOTH_vehicleRentalStateLocal"],
    ["playerStates", "BN_KOTH_playerStates"],
    ["playerTeamAssignments", "BN_KOTH_playerTeamAssignments"],
    ["playerNames", "BN_KOTH_playerNames"],
    ["playerLevels", "BN_KOTH_playerLevels"],
    ["teamCounts", "BN_KOTH_teamCounts"],
    ["activeParticipants", "BN_KOTH_activeParticipants"],
    ["selectedLocationId", "BN_KOTH_selectedLocationId"],
    ["previousLocationId", "BN_KOTH_previousLocationId"],
    ["activeLocationId", "BN_KOTH_activeLocationId"],
    ["activeZoneMarker", "BN_KOTH_activeZoneMarker"],
    ["activeRespawnWestMarker", "BN_KOTH_activeRespawnWestMarker"],
    ["activeRespawnEastMarker", "BN_KOTH_activeRespawnEastMarker"],
    ["activeWestBaseZoneMarker", "BN_KOTH_activeWestBaseZoneMarker"],
    ["activeEastBaseZoneMarker", "BN_KOTH_activeEastBaseZoneMarker"],
    ["voteOpen", "BN_KOTH_voteOpen"],
    ["voteCandidates", "BN_KOTH_voteCandidates"],
    ["voteTotals", "BN_KOTH_voteTotals"],
    ["votesByUid", "BN_KOTH_votesByUid"],
    ["voteEndAt", "BN_KOTH_voteEndAt"],
    ["zoneState", "BN_KOTH_zoneState"],
    ["zoneController", "BN_KOTH_zoneController"],
    ["zonePopulation", "BN_KOTH_zonePopulation"],
    ["scoreProgress", "BN_KOTH_scoreProgress"],
    ["maxPlayers", "BN_KOTH_maxPlayers"],
    ["maxTeamPlayers", "BN_KOTH_maxTeamPlayers"],
    ["winningSide", "BN_KOTH_winningSide"],
    ["teamScores", "BN_KOTH_teamScores"],
    ["scoreLimit", "BN_KOTH_scoreLimit"],
    ["prepareEndAt", "BN_KOTH_prepareEndAt"],
    ["endingEndAt", "BN_KOTH_endingEndAt"],
    ["resetEndAt", "BN_KOTH_resetEndAt"]
];

{
    private _key = _x;
    private _value = _payload get _key;
    missionNamespace setVariable [_key, _value];

    private _bnKey = _keyMap getOrDefault [_key, ""];
    if !(_bnKey isEqualTo "") then {
        missionNamespace setVariable [_bnKey, _value];
    };
} forEach (keys _payload);

private _savedKitState = _payload getOrDefault ["playerProgression", createHashMap];
if (_savedKitState isEqualType createHashMap && {_savedKitState getOrDefault ["savedKitsAuthoritative", false]}) then {
    private _serverKits = _savedKitState getOrDefault ["savedKits", []];
    private _localKits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
    private _serverInitialized = _savedKitState getOrDefault ["savedKitsInitialized", false];
    // A non-empty durable set wins. An empty first-time set deliberately keeps
    // legacy profile kits usable until the player next creates/updates them.
    if (_serverInitialized || {(count _serverKits) > 0} || {!(_localKits isEqualType [])} || {(count _localKits) isEqualTo 0}) then {
        profileNamespace setVariable ["BN_KOTH_savedKits_v2", +_serverKits];
        profileNamespace setVariable ["BN_KOTH_preferredSpawnKitId", _savedKitState getOrDefault ["preferredSavedKitId", ""]];
        uiNamespace setVariable ["BN_KOTH_savedKitsServerSynced", true];
        saveProfileNamespace;
    };
};

[] call bn_koth_fnc_progression_perks_applyMedicTraitLocal;
[] call bn_koth_fnc_ui_evaluateStateReadiness;
[] call bn_koth_fnc_ui_results_update;
[] call bn_koth_fnc_ui_transition_update;
[] call bn_koth_fnc_ui_updateLobbyBlackout;
[] call bn_koth_fnc_ui_updateLobbyRepresentationContainment;

[] call bn_koth_fnc_ui_updateLobbyLifecycle;
[] call bn_koth_fnc_groupMenu_refresh;
[] call bn_koth_fnc_ui_refreshHud;
[] call bn_koth_fnc_ui_refreshLobby;

private _menuDisplay = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _menuDisplay) then {
    if ((uiNamespace getVariable ["BN_KOTH_menuActivePage", ""]) isEqualTo "STORE") then {
        uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", ""];
    };
    [] call bn_koth_fnc_menu_refresh;
};
