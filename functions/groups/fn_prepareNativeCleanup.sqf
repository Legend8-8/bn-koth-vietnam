/*
    File: fn_prepareNativeCleanup.sqf
    Author: Legend
    Description: Enables and completes cleanup of a managed native group on its locality owner.
    Execution: Native group owner on server instruction
    Parameters:
        0: Native group <GROUP>
        1: Logical group ID <STRING>
        2: Logical revision <NUMBER>
    Returns: Whether cleanup ownership was accepted <BOOL>
    Public: Yes
*/

params [
    ["_nativeGroup", grpNull, [grpNull]],
    ["_groupId", "", [""]],
    ["_revision", -1, [0]]
];

if (!isRemoteExecuted || {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
if (isNull _nativeGroup || {_groupId isEqualTo ""} || {_revision < 0} || {!local _nativeGroup}) exitWith {false};
if ((_nativeGroup getVariable ["BN_KOTH_logicalGroupId", ""]) isNotEqualTo _groupId) exitWith {false};
if ((_nativeGroup getVariable ["BN_KOTH_logicalGroupRevision", -2]) isNotEqualTo _revision) exitWith {false};

_nativeGroup deleteGroupWhenEmpty true;
if (!isNull _nativeGroup && {(count units _nativeGroup) isEqualTo 0}) then {
    deleteGroup _nativeGroup;
};
true
