/*
    File: fn_receiveValidatedLoadout.sqf
    Author: Legend
    Description: Receives a server-validated loadout result on the requesting player's machine and applies it through the owned local application path.
    Execution: Client
    Parameters:
        0: Validation result from bn_koth_fnc_loadouts_validateLoadout <HASHMAP>
    Returns:
        None
    Public: No
*/

params [
    ["_validationResult", createHashMap, [createHashMap]]
];

if (!hasInterface) exitWith {};

// This function is network-facing only as the server response endpoint.
// Reject local/manual/client-originated execution.
if (!isRemoteExecuted) exitWith {
    ["Rejected non-remote validated loadout delivery on client.", "WARN"] call bn_koth_fnc_common_log;
};

if !(remoteExecutedOwner isEqualTo 2) exitWith {
    [
        format [
            "Rejected validated loadout delivery from non-server owner %1.",
            remoteExecutedOwner
        ],
        "WARN"
    ] call bn_koth_fnc_common_log;
};

if !(_validationResult isEqualType createHashMap) exitWith {};

if !(_validationResult getOrDefault ["success", false]) exitWith {
    systemChat format [
        "[KOTH] Loadout rejected: %1",
        _validationResult getOrDefault ["message", "Request rejected."]
    ];
};

if (isNull player) exitWith {};

private _validatedLoadout = _validationResult getOrDefault ["validatedLoadout", []];
if ((_validatedLoadout isEqualType []) && {(count _validatedLoadout) >= 10}) then {
    uiNamespace setVariable ["BN_KOTH_menuIntendedLoadout", +_validatedLoadout];
};

private _shouldApply = _validationResult getOrDefault ["shouldApply", true];
if (!_shouldApply) exitWith {
    systemChat format [
        "[KOTH] %1",
        _validationResult getOrDefault ["message", "Loadout intent updated."]
    ];
};

private _applyResult = [
    player,
    _validationResult
] call bn_koth_fnc_loadouts_applyLoadout;

if !(_applyResult getOrDefault ["success", false]) exitWith {
    [
        format [
            "Validated loadout application failed locally code=%1 message=%2",
            _applyResult getOrDefault ["code", "ERR_APPLY"],
            _applyResult getOrDefault ["message", "Unknown application failure."]
        ],
        "WARN"
    ] call bn_koth_fnc_common_log;

    systemChat format [
        "[KOTH] Loadout application failed: %1",
        _applyResult getOrDefault ["message", "Unknown failure."]
    ];
};

systemChat "[KOTH] Loadout applied.";
