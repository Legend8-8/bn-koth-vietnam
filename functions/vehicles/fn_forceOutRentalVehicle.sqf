/* Author: Legend; Execution: Client; Public: Yes */
params [["_vehicle",objNull,[objNull]]];
if (!hasInterface || {remoteExecutedOwner != 2} || {isNull _vehicle}) exitWith {};
if ((vehicle player) isEqualTo _vehicle) then {moveOut player};
