/*
    File: test_groups.sqf
    Author: Legend
    Description: Focused logical group invariant and request-boundary checks.
    Execution: Server debug console after mission initialization
    Parameters: None
    Returns: Failure messages <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Run group tests on the server."]};

private _failures = [];
private _check = {
    params ["_name", "_condition"];
    if (!_condition) then {_failures pushBack _name};
};

private _savedGroups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _savedRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _savedActive = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _savedRevision = missionNamespace getVariable ["BN_KOTH_groupsRevision", 0];
private _savedInvites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];

private _record = {
    params ["_uid", "_state", "_deployed", "_side"];
    createHashMapFromArray [
        ["uid", _uid],
        ["state", _state],
        ["deployed", _deployed],
        ["assignedSide", _side],
        ["currentUnit", objNull],
        ["ownerId", -1],
        ["name", _uid]
    ]
};

private _setFixture = {
    params ["_leaderRecord", "_memberRecords", "_activeUids"];
    private _records = createHashMapFromArray [["leader", _leaderRecord]];
    {_records set [_x get "uid", _x]} forEach _memberRecords;
    private _logical = createHashMapFromArray [
        ["id", "group_1"],
        ["sequence", 1],
        ["displayName", "SQUAD 1"],
        ["locked", false],
        ["leaderUid", "leader"],
        ["memberUids", ["leader", "memberWest", "memberEast"]],
        ["revision", 1],
        ["nativeGroup", grpNull],
        ["nativeSide", sideUnknown]
    ];
    missionNamespace setVariable ["BN_KOTH_groups", createHashMapFromArray [["group_1", _logical]]];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
    missionNamespace setVariable ["BN_KOTH_activeParticipants", _activeUids];
    missionNamespace setVariable ["BN_KOTH_groupsRevision", 0];
};

private _leaderLobby = ["leader", "LOBBY", false, sideUnknown] call _record;
private _memberWest = ["memberWest", "ACTIVE", true, west] call _record;
private _memberEast = ["memberEast", "ACTIVE", true, east] call _record;
[_leaderLobby, [_memberWest, _memberEast], ["memberWest", "memberEast"]] call _setFixture;
[] call bn_koth_fnc_groups_reconcile;
private _logical = (missionNamespace getVariable ["BN_KOTH_groups", createHashMap]) get "group_1";
["Undeployed leader remains logical leader", (_logical get "leaderUid") isEqualTo "leader"] call _check;
["Undeployed leader retains inconclusive members", (_logical get "memberUids") isEqualTo ["leader", "memberWest", "memberEast"]] call _check;
["Opposite-side members are not removed before leader side authority", (_logical get "revision") isEqualTo 1] call _check;
["No native group is materialized without leader side authority", isNull (_logical get "nativeGroup")] call _check;

[] call bn_koth_fnc_groups_releaseNativeGroups;
_logical = (missionNamespace getVariable ["BN_KOTH_groups", createHashMap]) get "group_1";
["Round release preserves logical leader", (_logical get "leaderUid") isEqualTo "leader"] call _check;
["Round release preserves logical membership", (_logical get "memberUids") isEqualTo ["leader", "memberWest", "memberEast"]] call _check;

private _leaderRespawning = ["leader", "RESPAWNING", true, west] call _record;
[_leaderRespawning, [_memberWest, _memberEast], ["leader", "memberWest", "memberEast"]] call _setFixture;
[] call bn_koth_fnc_groups_reconcile;
_logical = (missionNamespace getVariable ["BN_KOTH_groups", createHashMap]) get "group_1";
["Leader death/respawn does not change logical leadership", (_logical get "leaderUid") isEqualTo "leader"] call _check;

[_leaderLobby, [_memberWest, _memberEast], ["memberWest", "memberEast"]] call _setFixture;
["Actual leader removal succeeds", ["leader"] call bn_koth_fnc_groups_removeMember] call _check;
_logical = (missionNamespace getVariable ["BN_KOTH_groups", createHashMap]) get "group_1";
["Actual leader removal selects deterministic deployed successor", (_logical get "leaderUid") isEqualTo "memberWest"] call _check;
["Successor remains a member", (_logical get "leaderUid") in (_logical get "memberUids")] call _check;

private _requestSource = preprocessFileLineNumbers "functions\groups\fn_request.sqf";
private _reconcileSource = preprocessFileLineNumbers "functions\groups\fn_reconcile.sqf";
private _leadershipSource = preprocessFileLineNumbers "functions\groups\fn_applyNativeLeadership.sqf";
private _cleanupSource = preprocessFileLineNumbers "functions\groups\fn_prepareNativeCleanup.sqf";
private _publishSource = preprocessFileLineNumbers "functions\groups\fn_publishUpdate.sqf";
private _mutationSource = preprocessFileLineNumbers "functions\groups\fn_mutate.sqf";
private _presentationSource = preprocessFileLineNumbers "functions\groups\fn_buildPresentationState.sqf";
private _candidateSource = preprocessFileLineNumbers "functions\groups\fn_isInviteCandidate.sqf";
private _roundReleaseSource = preprocessFileLineNumbers "functions\teams\fn_returnAllToLobby.sqf";
private _groupUiSource = preprocessFileLineNumbers "functions\ui\groups\fn_refresh.sqf";
private _groupActionSource = preprocessFileLineNumbers "functions\ui\groups\fn_action.sqf";
private _deathSource = preprocessFileLineNumbers "functions\respawn\fn_handlePlayerDeath.sqf";
private _respawnSource = preprocessFileLineNumbers "functions\respawn\fn_handlePlayerRespawn.sqf";
private _keybindSource = loadFile "config\esc_menu.hpp";
private _gameModeSource = loadFile "config\gameMode.hpp";
private _localLeadershipStart = _reconcileSource find "if (local _native) then {";
private _localLeadershipTail = if (_localLeadershipStart >= 0) then {_reconcileSource select [_localLeadershipStart]} else {""};
private _localLeadershipEnd = _localLeadershipTail find "} else {";
private _localLeadershipBranch = if (_localLeadershipEnd >= 0) then {_localLeadershipTail select [0, _localLeadershipEnd]} else {""};
private _modeReturnStart = _groupActionSource find "if (_operation in [""INVITE"", ""RENAME""]) then {";
private _modeReturnBranch = if (_modeReturnStart >= 0) then {_groupActionSource select [_modeReturnStart]} else {""};
["Client request payload contains only operation and target", (_requestSource find "[_operation, _target] remoteExecCall") >= 0] call _check;
["Server request resolves caller from remoteExecutedOwner", (_requestSource find "private _ownerId = remoteExecutedOwner") >= 0] call _check;
["Snapshot exits before mutation and reconciliation", (_requestSource find "if (_operation isEqualTo ""SNAPSHOT"") exitWith") < (_requestSource find "private _mutation =") ] call _check;
["Reconciliation cannot mutate logical leaderUid", (_reconcileSource find "_logical set [""leaderUid""") < 0] call _check;
["Server-local leadership uses selectLeader directly", (_localLeadershipBranch find "_native selectLeader _desiredNativeLeader") >= 0] call _check;
["Server-local leadership branch does not invoke the remote endpoint", (_localLeadershipBranch find "bn_koth_fnc_groups_applyNativeLeadership") < 0] call _check;
["Remote leadership endpoint requires server RemoteExec", (_leadershipSource find "!isRemoteExecuted") >= 0 && {(_leadershipSource find "remoteExecutedOwner isNotEqualTo 2") >= 0}] call _check;
["Remote leadership validates locality, membership and revision", (_leadershipSource find "!local _nativeGroup") >= 0 && {(_leadershipSource find "_leaderUnit in (units _nativeGroup)") >= 0} && {(_leadershipSource find "BN_KOTH_logicalGroupRevision") >= 0}] call _check;
["Remote native cleanup requires server and local managed group", (_cleanupSource find "!isRemoteExecuted") >= 0 && {(_cleanupSource find "remoteExecutedOwner isNotEqualTo 2") >= 0} && {(_cleanupSource find "!local _nativeGroup") >= 0} && {(_cleanupSource find "deleteGroupWhenEmpty true") >= 0}] call _check;
["Empty publication impact never falls back to all active players", (_publishSource find "count _impacts) isEqualTo 0") >= 0 && {(_publishSource find "+_active") < 0}] call _check;
["Death and respawn derive affected group impact", (_deathSource find "groups_capturePresentationImpact") >= 0 && {(_respawnSource find "groups_capturePresentationImpact") >= 0}] call _check;
["Death and respawn have no unconditional group publication", (_deathSource find "[] call bn_koth_fnc_groups_publishUpdate") < 0 && {(_respawnSource find "[] call bn_koth_fnc_groups_publishUpdate") < 0}] call _check;
["New groups default open with a stable display name", (_mutationSource find "[""displayName"", format [""SQUAD %1""") >= 0 && {(_mutationSource find "[""locked"", false]") >= 0}] call _check;
["Ordinary JOIN rejects locked groups", (_mutationSource find "GROUP_LOCKED") >= 0] call _check;
["Invite creation and acceptance share server eligibility", ({_mutationSource find _x >= 0} count ["TARGET_INELIGIBLE", "ACCEPT_INVITE", "groups_isInviteCandidate"]) isEqualTo 3] call _check;
["Duplicate invite rejection remains server-side", (_mutationSource find "INVITE_PENDING") >= 0 && {(_mutationSource find "serverTime < (_existingInvite getOrDefault") >= 0}] call _check;
["Successful invite notifies the target to open Group Menu", (_mutationSource find "Group invite from %1 to %2. Open Group Menu to respond.") >= 0 && {(_mutationSource find "[_targetOwnerId") >= 0}] call _check;
["Invite notification does not assume the default physical key", (_mutationSource find "Press U") < 0] call _check;
["Successful invite refreshes target and leader presentation", (_mutationSource find "[_target, _uid]") >= 0] call _check;
["Invite candidates require authoritative side and player registry state", (_candidateSource find "assignedSide") >= 0 && {(_candidateSource find "getPlayerUID") >= 0} && {(_candidateSource find "currentUnit") >= 0}] call _check;
["Invite presentation is requester-specific", (_presentationSource find "inviteCandidates") >= 0 && {(_presentationSource find "pendingInvite") >= 0} && {(_presentationSource find "groups_isInviteCandidate") >= 0}] call _check;
["Pending invite targets are excluded from the invite chooser", (_presentationSource find "private _hasActiveInvite") >= 0 && {(_presentationSource find "if (!_hasActiveInvite") >= 0}] call _check;
["Invite and rename submissions immediately redraw MAIN mode", (_modeReturnBranch find "uiNamespace setVariable [""BN_KOTH_groupMenuMode"", ""MAIN""];") >= 0 && {(_modeReturnBranch find "[] call bn_koth_fnc_groupMenu_refresh;") > (_modeReturnBranch find "uiNamespace setVariable [""BN_KOTH_groupMenuMode"", ""MAIN""];")}] call _check;
["Rename validation rejects length, controls and structured text markers", (_mutationSource find "maxDisplayNameLength") >= 0 && {(_mutationSource find "_x < 32") >= 0} && {(_mutationSource find "toArray ""<>&""") >= 0}] call _check;
["Round return clears transient invites", (_roundReleaseSource find "groups_clearInvites") >= 0] call _check;
["Group UI marks locked groups and keeps contextual invite controls", (_groupUiSource find "LOCKED") >= 0 && {(_groupUiSource find "INVITE") >= 0} && {(_groupUiSource find "ctrlShow _visible") >= 0}] call _check;
["Group Menu uses the shared configurable U default", (_keybindSource find "class group_menu") >= 0 && {(_keybindSource find "defaultKey = DIK_U") >= 0} && {(_keybindSource find "bn_koth_fnc_groupMenu_open") >= 0}] call _check;
["Vanilla team switching is disabled", (_gameModeSource find "enableTeamSwitch = 0") >= 0] call _check;

private _unrelatedImpact = [["unrelatedUngroupedUid"], []] call bn_koth_fnc_groups_capturePresentationImpact;
["Ungrouped lifecycle impact has no group recipients", (_unrelatedImpact getOrDefault ["groupIds", []]) isEqualTo [] && {(_unrelatedImpact getOrDefault ["memberUids", []]) isEqualTo []} && {(_unrelatedImpact getOrDefault ["sides", []]) isEqualTo []}] call _check;
["Empty impact publication sends nothing", ([] call bn_koth_fnc_groups_publishUpdate) isEqualTo 0] call _check;

missionNamespace setVariable ["BN_KOTH_groups", _savedGroups];
missionNamespace setVariable ["BN_KOTH_playerRecords", _savedRecords];
missionNamespace setVariable ["BN_KOTH_activeParticipants", _savedActive];
missionNamespace setVariable ["BN_KOTH_groupsRevision", _savedRevision];
missionNamespace setVariable ["BN_KOTH_groupInvites", _savedInvites];

diag_log format ["[BN_KOTH_TEST] Groups: %1 failure(s): %2", count _failures, _failures];
_failures
