class CfgBnKothPersistence
{
    schemaVersion = 4;
    backend = "EXTDB3";
    saveDebounceSeconds = 15;
    sessionFallbackOnFailure = 1;
    extdbDatabase = "BN_KOTH";
    extdbProtocol = "BNKOTH";
    extdbSqlCustomFile = "bn_koth.ini";
    queryTimeoutSeconds = 5;
    savedKitMaxCount = 12;
    savedKitMaxNameLength = 32;
    vehicleProgressionMaxSerializedCharacters = 250000;
};
