class CfgBnKothPlayerMapMarkers
{
    // Master switch for the local player map marker system.
    enabled = 1;

    // Refresh intervals in seconds for local marker updates.
    refreshIntervalSeconds = 0.1;
    closedRefreshIntervalSeconds = 5;

    // Marker types and colors used for same-side player locations.
    markerType = "mil_triangle";
    markerColor = "ColorWhite";
    markerShadow = 1;
    groupMarkerColor = "ColorGreen";
    micMarkerType = "selector_selectable";
    micMarkerColor = "ColorOrange";
    micTexture = "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa";
    micColor[] = {.85, .4, 0, 1};
    micSize = 22;
    micNameSize = 0.04;

    // Overall visibility for local map markers.
    iconAlpha = 1;

    // Local microphone state monitoring settings.
    micOverlayEnabled = 1;
    micInputAction = "PushToTalk";

    // Big map display used to select the open refresh rate.
    mapDisplayId = 12;

    // Local player marker behavior.
    showPassengerCount = 1;
    showDriverName = 1;
};
