/*
    File: fn_evaluateAttachmentEntitlement.sqf
    Author: Legend
    Description: Evaluates server-owned minimum-level entitlement for one
        factual attachment. Unconfigured attachments remain unrestricted.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Attachment classname <STRING>
    Returns:
        Attachment entitlement result <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_attachmentClass", "", [""]]
];

private _fail = {
    params ["_code", "_message"];

    createHashMapFromArray [
        ["success", false],
        ["entitled", false],
        ["code", _code],
        ["message", _message],
        ["attachmentClass", toLower _attachmentClass]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Attachment entitlement must be evaluated on the server."] call _fail
};

if (_uid isEqualTo "") exitWith {
    ["ERR_INVALID_PLAYER", "Attachment entitlement requires a player UID."] call _fail
};

_attachmentClass = toLower _attachmentClass;
if (_attachmentClass isEqualTo "") exitWith {
    ["ERR_ATTACHMENT_CLASS_EMPTY", "Attachment entitlement requires a classname."] call _fail
};

private _metadataCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> "Attachments" >> _attachmentClass;
private _configured = isClass _metadataCfg;
private _minLevel = 1;
private _hasMinLevel = _configured && {isNumber (_metadataCfg >> "minLevel")};

if (_hasMinLevel) then {
    _minLevel = (getNumber (_metadataCfg >> "minLevel")) max 1;
};

private _playerLevel = 1;
private _progressionError = createHashMap;
if (_hasMinLevel) then {
    private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
    if !(_progressionByUid isEqualType createHashMap) then {
        _progressionError = ["ERR_PROGRESSION_STATE", "Authoritative progression state is unavailable."] call _fail;
    } else {
        private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
        if !(_progression isEqualType createHashMap) then {
            _progression = createHashMap;
        };
        _playerLevel = (_progression getOrDefault ["level", 1]) max 1;
    };
};

if ((count _progressionError) > 0) exitWith {_progressionError};

private _entitled = _playerLevel >= _minLevel;
createHashMapFromArray [
    ["success", true],
    ["entitled", _entitled],
    ["code", if (_entitled) then {"ENTITLED_ATTACHMENT"} else {"LOCKED_ATTACHMENT_LEVEL"}],
    ["message", if (_entitled) then {
        "Attachment minimum-level entitlement satisfied."
    } else {
        format ["Attachment requires level %1.", _minLevel]
    }],
    ["attachmentClass", _attachmentClass],
    ["configured", _configured],
    ["hasMinLevel", _hasMinLevel],
    ["playerLevel", _playerLevel],
    ["minLevel", _minLevel]
]
