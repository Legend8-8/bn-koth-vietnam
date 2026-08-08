// Runs on the server for each joining player.

diag_log "[BN_KOTH][INFO] initPlayerServer.sqf entered";

params ["_player", "_didJip"];

if (!isServer) exitWith {};
if (isNull _player) exitWith {};

diag_log format ["[BN_KOTH][INFO] initPlayerServer native call owner=%1 uid='%2' didJip=%3", owner _player, getPlayerUID _player, _didJip];

[_player, _didJip] spawn {
	params ["_playerObj", "_joinedInProgress"];

	private _attempt = 0;
	private _registered = false;

	while {!_registered && {_attempt < 40} && {!isNull _playerObj}} do {
		_attempt = _attempt + 1;

		private _ownerId = owner _playerObj;
		private _uid = getPlayerUID _playerObj;
		private _isPlayerObj = isPlayer _playerObj;

		if (_attempt isEqualTo 1) then {
			[format ["initPlayerServer start owner=%1 uid='%2' isPlayer=%3 didJip=%4", _ownerId, _uid, _isPlayerObj, _joinedInProgress], "INFO"] call bn_koth_fnc_common_log;
		};

		_registered = [_playerObj] call bn_koth_fnc_teams_registerPlayer;
		if (!_registered) then {
			sleep 0.5;
		};
	};

	if (!_registered) exitWith {
		[format ["initPlayerServer failed to register player after %1 attempts owner=%2 uid='%3'", _attempt, owner _playerObj, getPlayerUID _playerObj], "ERROR"] call bn_koth_fnc_common_log;
	};

	[format ["initPlayerServer registration complete owner=%1 uid='%2' attempts=%3", owner _playerObj, getPlayerUID _playerObj, _attempt], "INFO"] call bn_koth_fnc_common_log;

	[_playerObj] call bn_koth_fnc_respawn_initPlayerServer;
	[_playerObj] call bn_koth_fnc_ui_sendStateToClient;
};
