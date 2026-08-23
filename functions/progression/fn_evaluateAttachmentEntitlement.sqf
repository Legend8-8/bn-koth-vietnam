/*
    File: fn_evaluateAttachmentEntitlement.sqf
    Author: Legend
    Description: Evaluates server-owned KOTH side and progression entitlement
        for one factual attachment through the shared item policy path.
        Unconfigured combat equipment remains temporarily uncontrolled.
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

_attachmentClass = toLower _attachmentClass;
private _result = [_uid, "Attachments", _attachmentClass, false] call bn_koth_fnc_progression_evaluateItemEntitlement;
_result set ["attachmentClass", _attachmentClass];
_result
