class CfgBnKothPersistence
{
    schemaVersion = 5;
    backend = "EXTDB3";
    saveDebounceSeconds = 15;
    sessionFallbackOnFailure = 1;
    extdbDatabase = "BN_KOTH";
    extdbProtocol = "BNKOTH";
    extdbSqlCustomFile = "bn_koth.ini";
    queryTimeoutSeconds = 5;
    savedKitMaxCount = 6;
    // Total price to unlock each numbered slot. Slot 1 is free.
    savedKitSlotPrices[] = {0, 10000, 20000, 40000, 80000, 160000};
    savedKitMaxNameLength = 32;
    vehicleProgressionMaxSerializedCharacters = 250000;
};
