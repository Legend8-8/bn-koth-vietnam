class CfgBnKothTeams
{
	// Keep initial scope simple: two playable sides.
	playableSides[] = {"WEST", "EAST"};

	class West
	{
		side = 1;
		defaultUnitClass = "vn_b_men_sog_07";
	};

	class East
	{
		side = 0;
		defaultUnitClass = "vn_o_men_nva_04";
	};
};
