/*
    File: fn_updateDownedPresentation.sqf
    Author: Legend
    Description: Maintains the local KOTH interactions available to a downed player.
    Execution: Client, from the existing UI lifecycle
    Parameters:
        0: Force immediate teardown before a representation handoff <BOOL>
    Returns:
        True while downed presentation is active <BOOL>
    Public: No
*/

params [["_forceTeardown", false, [false]]];

if (!hasInterface) exitWith {false};

private _binding = uiNamespace getVariable ["BN_KOTH_downedActionBinding", [objNull, []]];
_binding params ["_boundUnit", "_actionIds"];

private _teardown = {
    if (!isNull _boundUnit) then {
        {_boundUnit removeAction _x} forEach _actionIds;
        _boundUnit setVariable ["BN_KOTH_giveUpPendingLocal", nil, false];
    };

    uiNamespace setVariable ["BN_KOTH_downedActionBinding", [objNull, []]];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", false];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", -1];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpOwnRequestActive", false];
    uiNamespace setVariable ["BN_KOTH_reviveRewardReportedUnit", objNull];
};

if (_forceTeardown) exitWith {
    call _teardown;
    false
};

private _unit = player;
private _uid = if (isNull _unit) then {""} else {getPlayerUID _unit};
private _states = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _deployedActive = !isNull _unit
    && {_uid isNotEqualTo ""}
    && {_states isEqualType createHashMap}
    && {(_states getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE"}
    && {_uid in _active}
    && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE"};
private _shouldPresent = _deployedActive && {[_unit] call bn_koth_fnc_respawn_isIncapacitated};
private _reportedUnit = uiNamespace getVariable ["BN_KOTH_reviveRewardReportedUnit", objNull];

if (_shouldPresent) then {
    if !(_reportedUnit isEqualTo _unit) then {
        uiNamespace setVariable ["BN_KOTH_reviveRewardReportedUnit", _unit];
        [_unit] remoteExecCall ["bn_koth_fnc_respawn_reportReviveState", 2];
    };
} else {
    if (!isNull _reportedUnit && {_reportedUnit isEqualTo _unit}) then {
        uiNamespace setVariable ["BN_KOTH_reviveRewardReportedUnit", objNull];
        [_unit] remoteExecCall ["bn_koth_fnc_respawn_reportReviveState", 2];
    };
};

if (
    uiNamespace getVariable ["BN_KOTH_casualtyHelpRequestPending", false]
    && {(diag_tickTime - (uiNamespace getVariable ["BN_KOTH_casualtyHelpRequestPendingAt", diag_tickTime])) >= 2}
) then {
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", false];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", -1];
};

if (!_shouldPresent) exitWith {
    if (!isNull _boundUnit) then {
        call _teardown;
    };
    false
};

if (!isNull _boundUnit && {!(_boundUnit isEqualTo _unit)}) then {
    call _teardown;
    _binding = [objNull, []];
    _boundUnit = objNull;
    _actionIds = [];
};

if (isNull _boundUnit) then {
    private _duration = 0.25;
    private _removeOnCompletion = true;
    private _showWindow = true;
    private _showWhileUnconscious = true;
    private _baseShowCondition = "_target isEqualTo player && {_this isEqualTo player} && {[player] call bn_koth_fnc_respawn_isIncapacitated} && {private _uid = getPlayerUID player; private _states = missionNamespace getVariable ['BN_KOTH_playerStates', createHashMap]; _uid isNotEqualTo '' && {_states isEqualType createHashMap} && {(_states getOrDefault [_uid, 'LOBBY']) isEqualTo 'ACTIVE'} && {_uid in (missionNamespace getVariable ['BN_KOTH_activeParticipants', []])} && {(missionNamespace getVariable ['BN_KOTH_roundState', '']) isEqualTo 'ACTIVE'}}";
    private _baseProgressCondition = "_target isEqualTo player && {_caller isEqualTo player} && {[player] call bn_koth_fnc_respawn_isIncapacitated} && {private _uid = getPlayerUID player; private _states = missionNamespace getVariable ['BN_KOTH_playerStates', createHashMap]; _uid isNotEqualTo '' && {_states isEqualType createHashMap} && {(_states getOrDefault [_uid, 'LOBBY']) isEqualTo 'ACTIVE'} && {_uid in (missionNamespace getVariable ['BN_KOTH_activeParticipants', []])} && {(missionNamespace getVariable ['BN_KOTH_roundState', '']) isEqualTo 'ACTIVE'}}";

    private _respawnShowCondition = _baseShowCondition
        + " && {!(player getVariable ['BN_KOTH_giveUpPendingLocal', false])}";
    private _respawnProgressCondition = _baseProgressCondition
        + " && {!(player getVariable ['BN_KOTH_giveUpPendingLocal', false])}";
    private _respawnId = [
        _unit,
        "<t color='#ff6b6b'>GIVE UP / RESPAWN</t>",
        nil,
        nil,
        _respawnShowCondition,
        _respawnProgressCondition,
        {},
        {},
        {
            params ["_target", "_caller"];
            if (!(_caller isEqualTo player) || {!(_target isEqualTo player)}) exitWith {};
            if !([player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {};
            if (player getVariable ["BN_KOTH_giveUpPendingLocal", false]) exitWith {};
            private _uid = getPlayerUID player;
            private _states = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
            if (
                _uid isEqualTo ""
                || {!(_states isEqualType createHashMap)}
                || {!((_states getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE")}
                || {!(_uid in (missionNamespace getVariable ["BN_KOTH_activeParticipants", []]))}
                || {!((missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE")}
            ) exitWith {};

            player setVariable ["BN_KOTH_giveUpPendingLocal", true, false];
            [player, 3] call VN_fnc_revive_action_respawn;
        },
        {},
        [],
        _duration,
        1000,
        _removeOnCompletion,
        _showWhileUnconscious,
        _showWindow
    ] call VN_fnc_holdActionAdd;

    private _helpShowCondition = _baseShowCondition
        + " && {!(uiNamespace getVariable ['BN_KOTH_casualtyHelpOwnRequestActive', false])} && {!(uiNamespace getVariable ['BN_KOTH_casualtyHelpRequestPending', false])}";
    private _helpProgressCondition = _baseProgressCondition
        + " && {!(uiNamespace getVariable ['BN_KOTH_casualtyHelpOwnRequestActive', false])} && {!(uiNamespace getVariable ['BN_KOTH_casualtyHelpRequestPending', false])}";
    private _helpId = [
        _unit,
        "<t color='#ffd966'>CALL FOR HELP</t>",
        nil,
        nil,
        _helpShowCondition,
        _helpProgressCondition,
        {},
        {},
        {
            params ["_target", "_caller"];
            if (!(_caller isEqualTo player) || {!(_target isEqualTo player)}) exitWith {};
            if !([player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {};
            if (uiNamespace getVariable ["BN_KOTH_casualtyHelpOwnRequestActive", false]) exitWith {};
            if (uiNamespace getVariable ["BN_KOTH_casualtyHelpRequestPending", false]) exitWith {};
            private _uid = getPlayerUID player;
            private _states = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
            if (
                _uid isEqualTo ""
                || {!(_states isEqualType createHashMap)}
                || {!((_states getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE")}
                || {!(_uid in (missionNamespace getVariable ["BN_KOTH_activeParticipants", []]))}
                || {!((missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE")}
            ) exitWith {};

            uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", true];
            uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", diag_tickTime];
            [] remoteExecCall ["bn_koth_fnc_respawn_requestCasualtyHelp", 2];
        },
        {},
        [],
        _duration,
        1001,
        _removeOnCompletion,
        _showWhileUnconscious,
        _showWindow
    ] call VN_fnc_holdActionAdd;

    uiNamespace setVariable ["BN_KOTH_downedActionBinding", [_unit, [_respawnId, _helpId]]];
};

true
