class CfgBnKothScoring
{
	scoreLimit = 100;
	scoreTick = 1;
	scoreTickInterval = 30;

	class progression
	{
		// Live reward hooks. Keep these values server-authoritative and config-tunable.
		xpPerParticipationTick = 5;
		xpPerControlBonus = 5;
		xpPerPriorityBonus = 20;
		xpPerKill = 25;
		// Configurable roadmap rewards. Zero preserves current balance while the
		// authoritative mechanisms remain available for live tuning.
		xpPerAssist = 0;
		xpTeamkillPenalty = 0;
		xpRoundParticipationBonus = 0;
		xpRoundWinnerBonus = 0;
		// Presentation-only kill-streak thresholds. Empty disables milestone notices.
		streakMilestones[] = {};
		// Provisional beta value; requires trusted native revive attribution before use.
		xpPerRevive = 25;

		class transportInsertion
		{
			// Initial reward surface: curated rotary-wing transports only.
			xpPerPassenger = 25;
			minimumTransportSeconds = 20;
			minimumTransportDistance = 500;
			confirmationWindowSeconds = 30;
			maximumBoardedSeconds = 900;
			samePairCooldownSeconds = 600;
			eligibleStoreCategories[] = {"ROTARY"};
			eligibleVehicleRoles[] = {"TRANSPORT"};
		};

		// XP required for each next level uses:
		// base + (levelIndex * linearStep) + (levelIndex^2 * quadraticStep).
		// Cumulative XP is the only value that needs persistence; level is derived.
		xpLevelBase = 500;
		xpLevelLinearStep = 75;
		xpLevelQuadraticStep = 0.12;
		maxLevel = 270;
	};

	class economy
	{
		// Provisional session-economy values. Rebalance after economy playtesting.
		startingCash = 1000;
		cashPerKill = 50;
		cashPerParticipationTick = 5;
		cashPerControlBonus = 5;
		cashPerPriorityBonus = 20;
		cashPerTransportPassenger = 25;
		cashPerAssist = 0;
		cashTeamkillPenalty = 0;
		cashRoundParticipationBonus = 0;
		cashRoundWinnerBonus = 0;
		// Provisional beta value; requires trusted native revive attribution before use.
		cashPerRevive = 25;
	};

	prepareDuration = 10;
	endingDuration = 8;
	resetDuration = 5;
};
