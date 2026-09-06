/*
    File: fn_applyNativeLeadership.sqf
    Author: Legend
    Description: Applies server-selected native leadership on the remote group owner.
    Execution: Native group owner on server instruction
    Parameters:
        0: Native group <GROUP>
        1: Desired native leader <OBJECT>
        2: Logical revision <NUMBER>
    Returns: Whether leadership was applied <BOOL>
    Public: Yes
*/

params [
    ["_nativeGroup", grpNull, [grpNull]],
    ["_leaderUnit", objNull, [objNull]],
    ["_revision", -1, [0]]
];

if (!isRemoteExecuted || {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
if (isNull _nativeGroup || {isNull _leaderUnit} || {!local _nativeGroup}) exitWith {false};
if !(_leaderUnit in (units _nativeGroup)) exitWith {false};
if ((_nativeGroup getVariable ["BN_KOTH_logicalGroupRevision", -2]) isNotEqualTo _revision) exitWith {false};

_nativeGroup selectLeader _leaderUnit;
true
