/*
    File: fn_receivePerkResult.sqf
    Author: Legend
    Description: Receives targeted server perk results and owns confirmation/application presentation.
    Execution: Client
    Public: Yes
*/
params [["_result", createHashMap, [createHashMap]]];
if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
private _code = _result getOrDefault ["code", "UNKNOWN"];
private _message = _result getOrDefault ["message", "Perk request failed."];
if (_code isEqualTo "CONFIRMATION_REQUIRED") exitWith {
    [_message, _result getOrDefault ["perkId", ""]] spawn {
        params ["_warning", "_perkId"];
        private _metadata = [_perkId] call bn_koth_fnc_progression_perks_getConfig;
        private _displayName = _metadata getOrDefault ["displayName", _perkId];
        private _confirmed = [_warning, format ["Deactivate %1", _displayName], true, true] call BIS_fnc_guiMessage;
        if (_confirmed && {_perkId isNotEqualTo ""}) then {["DEACTIVATE_CONFIRM", _perkId] call bn_koth_fnc_menu_requestPerk};
    };
};
if (_code in ["SUPPRESSOR_CLEANUP_REQUIRED", "PERK_CLEANUP_REQUIRED"]) exitWith {
    private _perkId = _result getOrDefault ["perkId", "perk"];
    private _metadata = [_perkId] call bn_koth_fnc_progression_perks_getConfig;
    private _displayName = _metadata getOrDefault ["displayName", _perkId];
    private _token = _result getOrDefault ["cleanupToken", ""];
    private _validation = _result getOrDefault ["cleanupValidation", createHashMap];
    if (_token isEqualTo "" || {!(_validation isEqualType createHashMap)}) exitWith {[format ["%1 cleanup request was invalid; the perk remains active.", _displayName]] call bn_koth_fnc_ui_notify};
    private _applied = [player, _validation] call bn_koth_fnc_loadouts_applyLoadout;
    if !(_applied getOrDefault ["success", false]) exitWith {[format ["%1 cleanup failed; the perk remains active.", _displayName]] call bn_koth_fnc_ui_notify};
    [_token] remoteExecCall ["bn_koth_fnc_progression_perks_ackCleanup", 2];
};
private _managedLoadout = _result getOrDefault ["managedLoadout", []];
if (_managedLoadout isEqualType [] && {(count _managedLoadout) >= 10}) then {
    uiNamespace setVariable ["BN_KOTH_menuIntendedLoadout", +_managedLoadout];
};
[_message] call bn_koth_fnc_ui_notify;
private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _display && {(uiNamespace getVariable ["BN_KOTH_menuActivePage", ""]) isEqualTo "PERKS"}) then {
    [_display] call bn_koth_fnc_menu_refreshProgressionHeader;
    [_display] call bn_koth_fnc_menu_refreshPerks;
};
