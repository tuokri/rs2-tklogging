class TKLMutator extends ROMutator
    config(Game_TKLMutator);

    var config bool bLogTeamKills;

function PreBeginPlay()
{
    `log("PreBeginPlay()",, 'TKLogging');
    if(bLogTeamKills)
    {
        `log("logging enabled",, 'TKLogging');
    }
    super.PreBeginPlay();
}

function ScoreKill(Controller Killer, Controller KilledPlayer)
{
    `log("---------------------- TKLOGGING ----------------------",, 'TKLogging');

    if(bLogTeamKills)
    {
        `tklog(TimeStamp(), Killer, KilledPlayer);
    }
    super.ScoreKill(Killer, KilledPlayer);
}
