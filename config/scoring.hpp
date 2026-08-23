class CfgBnKothScoring
{
	scoreLimit = 100;
	scoreTick = 1;
	scoreTickInterval = 15;

	class progression
	{
		// Live reward hooks. Keep these values server-authoritative and config-tunable.
		xpPerControlTick = 10;
		xpPerPriorityTick = 20;
		xpPerKill = 25;

		// XP required for each next level uses:
		// base + (levelIndex * linearStep) + (levelIndex^2 * quadraticStep).
		// Cumulative XP is the only value that needs persistence; level is derived.
		xpLevelBase = 500;
		xpLevelLinearStep = 75;
		xpLevelQuadraticStep = 0.12;
		maxLevel = 270;
	};

	prepareDuration = 10;
	endingDuration = 8;
	resetDuration = 5;
};
