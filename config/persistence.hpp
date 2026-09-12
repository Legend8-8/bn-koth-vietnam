class CfgBnKothPersistence
{
    schemaVersion = 3;
    backend = "EXTDB3";
    saveDebounceSeconds = 15;
    sessionFallbackOnFailure = 1;
    extdbDatabase = "BN_KOTH";
    extdbProtocol = "BNKOTH";
    extdbSqlCustomFile = "bn_koth.ini";
    queryTimeoutSeconds = 5;
    savedKitMaxCount = 12;
    savedKitMaxIdLength = 64;
    savedKitMaxNameLength = 32;
    savedKitMaxLoadoutCharacters = 60000;
    savedKitMaxSerializedCharacters = 500000;
};
