/*
    File: fn_receiveState.sqf
    Description: Receives and applies server state snapshot on client.
    Execution: Client
*/

params ["_payload"];

if (!hasInterface) exitWith {};

missionNamespace setVariable ["BN_KOTH_clientSnapshot", _payload];

private _roundState = _payload getOrDefault ["roundState", "WAITING"];
private _zoneState = _payload getOrDefault ["zoneState", "NEUTRAL"];

// Placeholder debug HUD text until full UI is implemented.
hintSilent format ["Round: %1\nZone: %2", _roundState, _zoneState];
