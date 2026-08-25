class CfgBnKothPersistence
{
    schemaVersion = 1;
    backend = "EXTDB3";
    saveDebounceSeconds = 15;
    sessionFallbackOnFailure = 1;
    extdbDatabase = "BN_KOTH";
    extdbProtocol = "BNKOTH";
    extdbSqlCustomFile = "bn_koth.ini";
    queryTimeoutSeconds = 5;
};
