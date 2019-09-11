class TKLMutator extends ROMutator
    config(Game_TKLMutator);

var config Bool bLogTeamKills;
var config String TKLFileName;

var FileWriter Writer;
var String LogRecord;
var String Cause;

function PreBeginPlay()
{  
    `log("TKLMutator_INFO: initializing TKLMutator");
    if (bLogTeamKills)
    {
        `log("TKLMutator_INFO: team kill logging enabled");
        Writer = Spawn(class'FileWriter');
        OpenLogFile(TKLFileName);
    }
    super.PreBeginPlay();
}

function ScoreKill(Controller Killer, Controller KilledPlayer)
{
    if (bLogTeamKills)
    {
        LogIfTeamKill(Killer, KilledPlayer);
    }
    super.ScoreKill(Killer, KilledPlayer);
}

function OpenLogFile(String FileName)
{
    if(FileName == "")
    {
        FileName = "KillLog.log";
    }

    Writer.OpenFile(FileName, FWFT_Log,, True, True);
    Writer.Logf("--- KillLog Begin: " $ TimeStamp() $ " ---");
}

function LogIfTeamKill(Controller Killer, Controller KilledPlayer)
{
    local String KillerSteamId64Hex;
    local String KilledPlayerSteamId64Hex;

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

                Writer.Logf(LogRecord);
            }
        }
    }
}

event Destroyed()
{
    if (Writer != None)
    {
        Writer.Logf("--- KillLog End: " $ TimeStamp() $ " ---");
        Writer.CloseFile();
        Writer.Destroy();
    }
    super.Destroyed();
}
