class TKLLogger extends Object;

var FileWriter Writer;

function LogIfTeamKill(Controller Killer, Controller KilledPlayer)
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

                LogRecord = "(" $ TimeStamp() $ ")";
                LogRecord $= " '" $ Killer.PlayerReplicationInfo.PlayerName;
                LogRecord $= "' [" $ KillerSteamId64Hex $ "]";
                LogRecord $= " teamkilled '" $ KilledPlayer.PlayerReplicationInfo.PlayerName;
                LogRecord $= "' [" $ KilledPlayerSteamId64Hex $ "]";
                LogRecord $= " with " $ "<" $ Cause $ ">";

                if (Writer != None)
                {
                	Writer.Logf(LogRecord);
                }
                else
                {
                	`log("TKLMutator_ERROR: Attempted logging on NULL FileWriter!");
                }
            }
        }
    }
}

function Initialize(String FileName, FileWriter TKLWriter)
{
	`log("TKLMutator_INFO: initializing TKLLogger");

	Writer = TKLWriter;

	if(FileName == "")
	{
		FileName = "KillLog.log";
	}

	Writer.OpenFile(FileName, FWFT_Log,, True, True);
	Writer.Logf("--- KillLog Begin: " $ TimeStamp() $ " ---");
}

function Destroy()
{
	if (Writer != None)
	{
		Writer.Logf("--- KillLog End: " $ TimeStamp() $ " ---");
		Writer.CloseFile();
		Writer.Destroy();
	}
}
