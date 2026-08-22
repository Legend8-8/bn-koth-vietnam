class CfgBnKothTeams
{
	// Keep initial scope simple: two playable sides.
	playableSides[] = {"WEST", "EAST"};

	// Mid-round team switching (esc menu) locks once the leading side reaches this percent of scoreLimit.
	switchTeamScoreLimitPercent = 60;

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
