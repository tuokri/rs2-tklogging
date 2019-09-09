class TKLMutator extends ROMutator
	config(TeamKillLogging);

	var config bool LogTeamKills;

function PreBeginPlay()
{
    LogInternal("TKLogging: PreBeginPlay()");
    if(LogTeamKills)
    {
    	LogInternal("TKLogging: logging enabled");
    	ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'TKLPlayerController';
    }
    super(Mutator).PreBeginPlay();
}
