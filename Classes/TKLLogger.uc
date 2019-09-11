class TKLLogger extends Object;

static function LogIfTeamKill(Controller Killer, Controller KilledPlayer, 
	FileWriter Writer, String TimeStamp)
{
    local String KillerSteamId64Hex;
    local String KilledPlayerSteamId64Hex;
    local String LogRecord;
    local String Cause;

    if (Killer != None && KilledPlayer != None)
    {
        if (Killer.PlayerReplicationInfo != None 
        	&& KilledPlayer.PlayerReplicationInfo != None)
        {
            if (Killer.GetTeamNum() == KilledPlayer.GetTeamNum())
            {
            	if (KilledPlayer == Killer)
            	{
            		Cause = "Suicide";
            	}
            	else
            	{
	            	if (KilledPlayer.Pawn != None)
			        {
			            Cause = String(ROPawn(KilledPlayer.Pawn).LastTakeHitInfo.DamageType);
			        }
			        else
			        {
			        	Cause = "UnknownCause";
			        }
            	}

                KillerSteamId64Hex = class'OnlineSubsystem'.static.UniqueNetIdToString(
                    Killer.PlayerReplicationInfo.UniqueId);
                KilledPlayerSteamId64Hex = class'OnlineSubsystem'.static.UniqueNetIdToString(
                    KilledPlayer.PlayerReplicationInfo.UniqueId);

                LogRecord = "(" $ TimeStamp $ ")";
                LogRecord $= " '" $ Killer.PlayerReplicationInfo.PlayerName;
                LogRecord $= "' [" $ KillerSteamId64Hex $ "]";
                LogRecord $= " teamkilled '" $ KilledPlayer.PlayerReplicationInfo.PlayerName;
                LogRecord $= "' [" $ KilledPlayerSteamId64Hex $ "]";
                LogRecord $= " with " $ "<" $ Cause $ ">";

                Writer.Logf(LogRecord);
            }
        }
    }
}
