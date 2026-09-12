/*
    File: fn_purchaseWeapon.sqf
    Author: Legend
    Description: Requests one permanent weapon entitlement transaction from
        the shared server-authoritative acquisition owner. Does not equip it.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Requested weapon classname <STRING>
    Returns:
        Structured acquisition result <HASHMAP>
    Public: Yes
*/

params [["_uid", "", [""]], ["_weaponClass", "", [""]]];

[_uid, _weaponClass, "PURCHASE"] call bn_koth_fnc_progression_acquisition_acquireWeapon
