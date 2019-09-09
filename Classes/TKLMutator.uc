class TKLMutator extends ROMutator
    config(Game_TKLMutator);

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
