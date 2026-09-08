/*
    File: fn_updateDownedPresentation.sqf
    Author: Legend
    Description: Maintains the local fixed casualty camera and downed-player actions.
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
private _camera = uiNamespace getVariable ["BN_KOTH_downedCamera", objNull];
private _cameraUnit = uiNamespace getVariable ["BN_KOTH_downedCameraUnit", objNull];

private _teardown = {
    if (!isNull _boundUnit) then {
        {_boundUnit removeAction _x} forEach _actionIds;
        _boundUnit setVariable ["BN_KOTH_giveUpPendingLocal", nil, false];
    };

    if (!isNull _camera) then {
        _camera cameraEffect ["TERMINATE", "BACK"];
        camDestroy _camera;
    };

    uiNamespace setVariable ["BN_KOTH_downedActionBinding", [objNull, []]];
    uiNamespace setVariable ["BN_KOTH_downedCamera", objNull];
    uiNamespace setVariable ["BN_KOTH_downedCameraUnit", objNull];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", false];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", -1];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpOwnRequestActive", false];
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

if (
    uiNamespace getVariable ["BN_KOTH_casualtyHelpRequestPending", false]
    && {(diag_tickTime - (uiNamespace getVariable ["BN_KOTH_casualtyHelpRequestPendingAt", diag_tickTime])) >= 2}
) then {
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", false];
    uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", -1];
};

if (!_shouldPresent) exitWith {
    if (!isNull _boundUnit || {!isNull _camera}) then {
        call _teardown;
    };
    false
};

if (!isNull _boundUnit && {!(_boundUnit isEqualTo _unit)}) then {
    call _teardown;
    _binding = [objNull, []];
    _boundUnit = objNull;
    _actionIds = [];
    _camera = objNull;
    _cameraUnit = objNull;
};

if (isNull _camera || {!(_cameraUnit isEqualTo _unit)}) then {
    [] call bn_koth_fnc_menu_close;

    private _config = missionConfigFile >> "CfgBnKothRespawn";
    private _offset = getArray (_config >> "casualtyCameraOffset");
    if !(_offset isEqualType [] && {count _offset isEqualTo 3}) then {_offset = [0, -3.25, 2.15]};
    private _targetHeight = getNumber (_config >> "casualtyCameraTargetHeight");
    private _fov = getNumber (_config >> "casualtyCameraFov");
    if (_fov <= 0) then {_fov = 0.7};

    _camera = "camera" camCreate [0, 0, 0];
    _camera attachTo [_unit, _offset];
    _camera camSetTarget (_unit modelToWorldVisual [0, 0, _targetHeight]);
    _camera camSetFov _fov;
    _camera cameraEffect ["Internal", "BACK"];
    _camera camCommit 0;
    showCinemaBorder false;
    uiNamespace setVariable ["BN_KOTH_downedCamera", _camera];
    uiNamespace setVariable ["BN_KOTH_downedCameraUnit", _unit];
};

// Reassert the fixed target and FOV so view/zoom inputs cannot turn this into a scouting camera.
private _config = missionConfigFile >> "CfgBnKothRespawn";
private _targetHeight = getNumber (_config >> "casualtyCameraTargetHeight");
private _fov = getNumber (_config >> "casualtyCameraFov");
if (_fov <= 0) then {_fov = 0.7};
_camera camSetTarget (_unit modelToWorldVisual [0, 0, _targetHeight]);
_camera camSetFov _fov;
_camera camCommit 0;

if (isNull _boundUnit) then {
    private _respawnId = _unit addAction [
        "<t color='#ff6b6b'>RESPAWN / GIVE UP</t>",
        {
            params ["_target", "_caller"];
            if (!(_caller isEqualTo player) || {!(_target isEqualTo player)}) exitWith {};
            if !([player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {};
            if (player getVariable ["BN_KOTH_giveUpPendingLocal", false]) exitWith {};

            player setVariable ["BN_KOTH_giveUpPendingLocal", true, false];
            [player, 3] call VN_fnc_revive_action_respawn;
        },
        nil,
        1001,
        false,
        true,
        "",
        "[player] call bn_koth_fnc_respawn_isIncapacitated && {!(player getVariable ['BN_KOTH_giveUpPendingLocal', false])}",
        5,
        false
    ];

    private _helpId = _unit addAction [
        "<t color='#ffd966'>CALL FOR HELP</t>",
        {
            params ["_target", "_caller"];
            if (!(_caller isEqualTo player) || {!(_target isEqualTo player)}) exitWith {};
            if !([player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {};
            if (uiNamespace getVariable ["BN_KOTH_casualtyHelpOwnRequestActive", false]) exitWith {};
            if (uiNamespace getVariable ["BN_KOTH_casualtyHelpRequestPending", false]) exitWith {};

            uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", true];
            uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", diag_tickTime];
            [] remoteExecCall ["bn_koth_fnc_respawn_requestCasualtyHelp", 2];
        },
        nil,
        1000,
        false,
        true,
        "",
        "[player] call bn_koth_fnc_respawn_isIncapacitated && {!(uiNamespace getVariable ['BN_KOTH_casualtyHelpOwnRequestActive', false])} && {!(uiNamespace getVariable ['BN_KOTH_casualtyHelpRequestPending', false])}",
        5,
        false
    ];

    uiNamespace setVariable ["BN_KOTH_downedActionBinding", [_unit, [_respawnId, _helpId]]];
};

true
