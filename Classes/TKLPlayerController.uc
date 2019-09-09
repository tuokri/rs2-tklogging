class TKLPlayerController extends ROPlayerController;

function WasTeamKilled(ROPlayerReplicationInfo TeamKiller)
{
    local string TeamKillerSteamId64;
    local string VictimSteamId64;

    if(TeamKiller != none)
    {
        TeamKillerSteamId64 = class'OnlineSubsystem'.static.UniqueNetIdToString(TeamKiller.UniqueId);
        VictimSteamId64 = class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerReplicationInfo.UniqueId);

        LogInternal(((((((("TKLogging: '" $ TeamKiller.PlayerName) $ "' [") $ TeamKillerSteamId64) $ "] teamkilled '")
            $ PlayerReplicationInfo.PlayerName) $ "' [") $ VictimSteamId64) $ "]");
    }

    super.WasTeamKilled(TeamKiller);
}
