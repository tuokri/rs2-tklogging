class TKLPlayerController extends ROPlayerController;

function WasTeamKilled(ROPlayerReplicationInfo TeamKiller)
{
    if(TeamKiller != none)
    {
        local String TeamKillerSteamId64 = class'OnlineSubsystem'.static.UniqueNetIdToString(TeamKiller.UniqueId);
        local String VictimSteamId64 = class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerReplicationInfo.UniqueId);

        Log(((((((("TKLogging: '" $ TeamKiller.PlayerName) $ "' [") $ TeamKillerSteamId64) $ "] teamkilled '")
            $ PlayerReplicationInfo.PlayerName) $ "' [") $ VictimSteamId64) $ "]");
    }

    super.WasTeamKilled(TeamKiller);
}
