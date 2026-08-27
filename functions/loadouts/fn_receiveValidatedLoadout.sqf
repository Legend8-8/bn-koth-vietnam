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

#include "..\..\ui\menu\idcs.hpp"

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
    private _pendingKitOperation = uiNamespace getVariable ["BN_KOTH_menuPendingKitOperation", ""];
    if !(_pendingKitOperation isEqualTo "") then {
        uiNamespace setVariable ["BN_KOTH_menuPendingKitOperation", ""];
        uiNamespace setVariable ["BN_KOTH_menuPendingKitId", ""];
        uiNamespace setVariable ["BN_KOTH_menuPendingKitName", ""];
    };
    systemChat format [
        "[KOTH] %1: %2",
        if !(_pendingKitOperation isEqualTo "") then {"Saved loadout rejected"} else {"Loadout rejected"},
        _validationResult getOrDefault ["message", "Request rejected."]
    ];
};

if (isNull player) exitWith {};

private _validatedLoadout = _validationResult getOrDefault ["validatedLoadout", []];
if ((_validatedLoadout isEqualType []) && {(count _validatedLoadout) >= 10}) then {
    uiNamespace setVariable ["BN_KOTH_menuIntendedLoadout", +_validatedLoadout];

    // Snapshot responses are read-only, but they still own the client menu's
    // authoritative intended-loadout view. Refresh an open menu immediately
    // instead of waiting for another player interaction.
    private _menuDisplay = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
    if (isNull _menuDisplay) then {
        _menuDisplay = findDisplay BN_KOTH_IDD_MENU;
    };

    if (!isNull _menuDisplay) then {
        [
            uiNamespace getVariable ["BN_KOTH_menuActivePage", "LOADOUT"]
        ] call bn_koth_fnc_menu_refresh;
    };
};

private _shouldApply = _validationResult getOrDefault ["shouldApply", true];
if (!_shouldApply) exitWith {};

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

    uiNamespace setVariable ["BN_KOTH_menuPendingKitOperation", ""];
    uiNamespace setVariable ["BN_KOTH_menuPendingKitId", ""];
    uiNamespace setVariable ["BN_KOTH_menuPendingKitName", ""];
};

private _mutationOp = _validationResult getOrDefault ["mutationOp", ""];
private _savedKitId = _validationResult getOrDefault ["savedKitId", ""];
private _pendingKitOperation = uiNamespace getVariable ["BN_KOTH_menuPendingKitOperation", ""];
private _pendingKitId = uiNamespace getVariable ["BN_KOTH_menuPendingKitId", ""];
private _pendingKitName = uiNamespace getVariable ["BN_KOTH_menuPendingKitName", ""];
if (
    (_mutationOp isEqualTo "load_local_kit")
    && {!(_pendingKitOperation isEqualTo "")}
    && {_savedKitId isEqualTo _pendingKitId}
) then {
    if (_pendingKitOperation isEqualTo "EDIT") then {
        uiNamespace setVariable ["BN_KOTH_menuKitEditId", _savedKitId];
        uiNamespace setVariable ["BN_KOTH_menuKitEditName", _pendingKitName];
        [format ["EDITING SAVED LOADOUT: %1", toUpper _pendingKitName]] call bn_koth_fnc_ui_notify;
    } else {
        uiNamespace setVariable ["BN_KOTH_menuKitEditId", ""];
        uiNamespace setVariable ["BN_KOTH_menuKitEditName", ""];
        [format ["LOADOUT APPLIED: %1", toUpper _pendingKitName]] call bn_koth_fnc_ui_notify;
    };
    uiNamespace setVariable ["BN_KOTH_menuPendingKitOperation", ""];
    uiNamespace setVariable ["BN_KOTH_menuPendingKitId", ""];
    uiNamespace setVariable ["BN_KOTH_menuPendingKitName", ""];
    ["LOADOUT"] call bn_koth_fnc_menu_refresh;
};

