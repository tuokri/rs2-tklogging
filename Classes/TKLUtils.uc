class TKLUtils extends Object;

static function TKL_LogIfTeamKill(String TimeStamp, Controller Killer, 
	Controller KilledPlayer, String KillerWeapon)
{
    local string KillerSteamId64Hex;
    local string KilledPlayerSteamId64Hex;
    local string LogRecord;

    if (Killer != None && KilledPlayer != None)
    {
        if (Killer.PlayerReplicationInfo != None 
        	&& KilledPlayer.PlayerReplicationInfo != None)
        {
            if (Killer.GetTeamNum() == KilledPlayer.GetTeamNum())
            {
                KillerSteamId64Hex = class'OnlineSubsystem'.static.UniqueNetIdToString(
                    Killer.PlayerReplicationInfo.UniqueId);
                KilledPlayerSteamId64Hex = class'OnlineSubsystem'.static.UniqueNetIdToString(
                    KilledPlayer.PlayerReplicationInfo.UniqueId);

                LogRecord = "(" $ TimeStamp $ ")";
                LogRecord $= " '" $ Killer.PlayerReplicationInfo.PlayerName;
                LogRecord $= "' [" $ KillerSteamId64Hex $ "]";
                LogRecord $= " teamkilled '" $ KilledPlayer.PlayerReplicationInfo.PlayerName;
                LogRecord $= "' [" $ KilledPlayerSteamId64Hex $ "]";
                LogRecord $= " with " $ "<" $ KillerWeapon $ ">";

                `log(LogRecord,, 'TKLogging');
            }
        }
    }
}
