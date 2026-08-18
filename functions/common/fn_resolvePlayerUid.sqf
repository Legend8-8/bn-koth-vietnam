/*
    File: fn_resolvePlayerUid.sqf
    Description: Resolves the tracked BN_KOTH player UID for an entity,
        matching the entity's own UID first and falling back to the
        currentUnit lookup used elsewhere in the mission (initServer.sqf's
        EntityKilled EH, fn_handlePlayerDeath.sqf). Factored out here so a
        third copy of the same lookup isn't needed for combat_handleKill,
        which has to resolve two entities (killer and victim) instead of one.
    Execution: Server
    Parameters:
        0: Entity to resolve <OBJECT>
        1: BN_KOTH_playerRecords hashmap <HASHMAP>
    Returns:
        Resolved UID, or "" if unresolved <STRING>
    Public: Yes
*/

params ["_entity", "_records"];

if (!isServer) exitWith {""};
if (isNull _entity) exitWith {""};
if !(_records isEqualType createHashMap) exitWith {""};

private _uid = getPlayerUID _entity;

if !(_uid isEqualTo "") then {
    private _record = _records get _uid;
    if !(_record isEqualType createHashMap) then {
        _uid = "";
    };
};

if (_uid isEqualTo "") then {
    {
        private _candidateUid = _x;
        private _candidateRecord = _records get _candidateUid;

        if (_candidateRecord isEqualType createHashMap) then {
            private _candidateUnit = _candidateRecord getOrDefault ["currentUnit", objNull];
            if (!isNull _candidateUnit && {_candidateUnit isEqualTo _entity}) exitWith {
                _uid = _candidateUid;
            };
        };
    } forEach (keys _records);
};

_uid
