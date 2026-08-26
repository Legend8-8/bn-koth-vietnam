/*
    File: fn_receiveWeaponAcquisitionResult.sqf
    Author: Legend
    Description: Presents one requester-only authoritative Store transaction
        result. Progression state itself arrives through the existing targeted
        progression update path.
    Execution: Client
    Parameters:
        0: Structured acquisition result <HASHMAP>
    Returns: None
    Public: Yes
*/

params [["_result", createHashMap, [createHashMap]]];
if (!hasInterface) exitWith {};
if (!isServer && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

private _code = _result getOrDefault ["code", "UNKNOWN"];
private _message = switch (_code) do {
    case "WEAPON_PURCHASED": {"Weapon purchased."};
    case "WEAPON_RENTED": {"Weapon rented for this server session."};
    case "ALREADY_OWNED": {"Weapon is already owned."};
    case "ALREADY_RENTED": {"Weapon rental is already active."};
    case "INSUFFICIENT_CASH": {"Insufficient cash."};
    case "LOCKED_LEVEL": {"Required weapon level is not complete."};
    case "LOCKED_MASTERY": {"Required weapon mastery is not complete."};
    case "LOCKED_PERK": {"Required weapon perk is not complete."};
    case "CROSS_SIDE_NOT_ALLOWED": {"Weapon is unavailable for your faction."};
    case "PURCHASE_NOT_CONFIGURED": {"Weapon purchase is not configured."};
    case "RENTAL_NOT_CONFIGURED": {"Weapon rental is not configured."};
    default {_result getOrDefault ["message", "Weapon transaction rejected."]};
};

[_message] call bn_koth_fnc_ui_notify;

// Store entries cache progression-derived ownership/rental presentation. One
// authoritative result invalidates that category cache before repainting,
// regardless of whether Store or Arsenal requested the acquisition.
uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", ""];

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _display) then {
    [] call bn_koth_fnc_menu_refresh;
};
