/*
    File: fn_closeLobby.sqf
    Author: Legend
    Description: Closes the production KOTH lobby dialog on the local client.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\lobby\idcs.hpp"

if (!hasInterface) exitWith {};

private _refreshLoop = uiNamespace getVariable ["BN_KOTH_lobbyRefreshLoop", scriptNull];
if (_refreshLoop isEqualType scriptNull && {!scriptDone _refreshLoop}) then {
    terminate _refreshLoop;
    uiNamespace setVariable ["BN_KOTH_lobbyRefreshLoop", scriptNull];
};

private _display = uiNamespace getVariable ["BN_KOTH_lobbyDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_LOBBY;
};

if (!isNull _display) then {
    _display closeDisplay 2;
};
