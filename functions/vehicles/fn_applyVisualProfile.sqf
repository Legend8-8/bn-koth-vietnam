/*
    File: fn_applyVisualProfile.sqf
    Author: Legend
    Description: Inert server-owned paid-vehicle visual-profile boundary. The
        current release accepts only the empty native profile and changes no texture.
    Execution: Server
    Parameters: 0: vehicle <OBJECT>, 1: normalized metadata <HASHMAP>
    Returns: True for native/default appearance <BOOL>
    Public: No
*/
params [["_vehicle", objNull, [objNull]], ["_metadata", createHashMap, [createHashMap]]];
if (!isServer || {isNull _vehicle}) exitWith {false};
private _profile = _metadata getOrDefault ["visualProfile", ""];
if !(_profile isEqualTo "") exitWith {
    [format ["Inactive vehicle visual profile rejected class=%1 profile=%2", typeOf _vehicle, _profile], "ERROR"] call bn_koth_fnc_common_log;
    false
};
true
