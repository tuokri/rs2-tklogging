class TKLPlayerController extends ROPlayerController;

function WasTeamKilled(ROPlayerReplicationInfo TeamKiller)
{
    local string TeamKillerSteamId64;
    local string VictimSteamId64;
    local string LogRecord;

    if(TeamKiller != none)
    {
        TeamKillerSteamId64 = class'OnlineSubsystem'.static.UniqueNetIdToString(TeamKiller.UniqueId);
        VictimSteamId64 = class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerReplicationInfo.UniqueId);

        LogRecord = TimeStamp();
        LogRecord $= " '" $ TeamKiller.PlayerName $ "' [" $ TeamKillerSteamId64 $ "]";
        LogRecord $= " teamkilled '" $ PlayerReplicationInfo.PlayerName $ "' [";
        LogRecord $= VictimSteamId64 $ "]";

        `log(LogRecord,, 'TKLogging');
    }

    super.WasTeamKilled(TeamKiller);
}
