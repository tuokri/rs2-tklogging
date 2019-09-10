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
    local string KillerWeapon;

    `logd("---------------------- TKLOGGING ----------------------");

    if (bLogTeamKills)
    {
        if (Killer.PlayerReplicationInfo != None)
        {
            // Might not be accurate.
            KillerWeapon = GetItemName(string(Killer.Pawn.Weapon));
        }

        `tklog(TimeStamp(), Killer, KilledPlayer, KillerWeapon);
    }
    super.ScoreKill(Killer, KilledPlayer);
}
