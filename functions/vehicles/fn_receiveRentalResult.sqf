/* Author: Legend; Description: Receives one targeted vehicle rental result and refreshes Store presentation. Execution: Client; Public: Yes */
params [["_result",createHashMap,[createHashMap]]];if (!hasInterface) exitWith {};
if (!isServer && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
missionNamespace setVariable ["BN_KOTH_vehicleRentalStateLocal",_result getOrDefault ["rentalState",createHashMap]];
[_result getOrDefault ["message","Vehicle request completed."]] call bn_koth_fnc_ui_notify;
private _display=uiNamespace getVariable ["BN_KOTH_menuDisplay",displayNull];if (!isNull _display) then {[] call bn_koth_fnc_menu_refresh};
