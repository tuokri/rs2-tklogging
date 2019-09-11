class TKLMutator extends ROMutator
    config(Game_TKLMutator);

    var config bool bLogTeamKills;

function PreBeginPlay()
{
    `log("PreBeginPlay()",, 'TKLogging');
    if (bLogTeamKills)
    {
        `log("logging enabled",, 'TKLogging');
    }
    super.PreBeginPlay();
}

function ScoreKill(Controller Killer, Controller KilledPlayer)
{
    local string Cause;

    `logd("---------------------- TKLOGGING ----------------------");

    if (bLogTeamKills)
    {
        if (KilledPlayer != None)
        {
            Cause = GetItemName(string(
                ROPawn(KilledPlayer.Pawn).LastTakeHitInfo.DamageType));
        }

        `tklog(TimeStamp(), Killer, KilledPlayer, Cause);
    }
    super.ScoreKill(Killer, KilledPlayer);
}
