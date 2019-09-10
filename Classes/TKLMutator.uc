class TKLMutator extends ROMutator
    config(Game_TKLMutator);

    var config bool LogTeamKills;

function PreBeginPlay()
{
    `log("PreBeginPlay()",, 'TKLogging');
    if(LogTeamKills)
    {
        `log("logging enabled",, 'TKLogging');
        ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'TKLPlayerController';
    }
    super(Mutator).PreBeginPlay();
}
