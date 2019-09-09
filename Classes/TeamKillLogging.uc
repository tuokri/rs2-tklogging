class TeamKillLogging extends ROMutator;

function PreBeginPlay()
{
    LogInternal("TKLogging: PreBeginPlay()");
    ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'TKLPlayerController';
    super(Mutator).PreBeginPlay();
}
