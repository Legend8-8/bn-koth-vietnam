/*
    File: fn_forceCloseInventory.sqf
    Author: Mongo
    Description: Closes the local physical inventory display and provides a throttled safe-zone notice.
    Execution: Client
    Parameters:
        0: Show the blocked-action notice <BOOL> (default: true)
    Returns:
        True when handled on an interface client <BOOL>
    Public: No
*/

params [["_showMessage", true, [true]]];

if (!hasInterface) exitWith {false};

private _display = findDisplay 602;
if (!isNull _display) then {
    _display closeDisplay 2;
};

if (_showMessage) then {
    private _now = diag_tickTime;
    private _nextMessageAt = uiNamespace getVariable ["BN_KOTH_inventoryNextBlockedMessageAt", -1];

    if (_now >= _nextMessageAt) then {
        private _cooldown = missionNamespace getVariable ["BN_KOTH_safeZoneMessageCooldownSeconds", 1];
        uiNamespace setVariable ["BN_KOTH_inventoryNextBlockedMessageAt", _now + _cooldown];
        ["Physical inventory access is disabled inside safe zones."] call bn_koth_fnc_ui_notify;
    };
};

true
