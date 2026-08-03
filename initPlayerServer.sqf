// Runs on the server for each joining player.

params ["_player", "_didJip"];

if (!isServer) exitWith {};
if (isNull _player) exitWith {};

[_player] call bn_koth_fnc_respawn_initPlayerServer;
[_player] call bn_koth_fnc_ui_sendStateToClient;
