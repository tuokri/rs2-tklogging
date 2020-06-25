class TKLMutator extends ROMutator
    config(Game_TKLMutator);

var config bool bLogTeamKills;
var config bool bLogKills;
var config bool bSendLogToServer;
var config string TKLFileName;

var bool bEnabled;
var bool bLinkEnabled;
var string LogRecord;
var string Cause;
var string TeamKillAction;
var string KillAction;
var FileWriter Writer;
var TKLMutatorTcpLinkClient TKLMTLC;

function PreBeginPlay()
{
    `log("[TKLMutator]: initializing TKLMutator");

    if (bLogTeamKills)
    {
        `log("[TKLMutator]: team kill logging enabled");
        bEnabled = True;
    }

    if (bLogKills)
    {
        `log("[TKLMutator]: kill logging enabled");
        bEnabled = True;
    }

    if (bEnabled)
    {
        TeamKillAction = "teamkilled";
        KillAction = "killed";

        Writer = Spawn(class'FileWriter');
        if (Writer == None)
        {
            bEnabled = False;
            `log("[TKLMutator]: error spawning FileWriter");
            return;
        }
        OpenLogFile(TKLFileName);

        if (bSendLogToServer)
        {
            TKLMTLC = Spawn(class'TKLMutatorTcpLinkClient');
            if (TKLMTLC == None)
            {
                bLinkEnabled = False;
                `log("[TKLMutator]: error spawning TKLMutatorTcpLinkClient");
                return;
            }

            bLinkEnabled = True;
        }
    }

    super.PreBeginPlay();
}

function ScoreKill(Controller Killer, Controller KilledPlayer)
{
    if (bEnabled)
    {
        LogKill(Killer, KilledPlayer);
    }
    super.ScoreKill(Killer, KilledPlayer);
}

final function OpenLogFile(string FileName)
{
    if(FileName == "")
    {
        FileName = "KillLog.log";
    }

    Writer.OpenFile(FileName, FWFT_Log,, True, True);
    Writer.Logf("--- KillLog Begin: " $ TimeStamp() $ " ---");
}

final function string LastHitDamageType(Controller KilledPlayer)
{
    if (KilledPlayer.Pawn == None)
    {
        return "UNKNOWN_CAUSE";
    }
    return string(ROPawn(KilledPlayer.Pawn).LastTakeHitInfo.DamageType);
}

final function LogKill(Controller Killer, Controller KilledPlayer)
{
    local string KillerSteamId64Hex;
    local string KilledPlayerSteamId64Hex;
    local string LastHitDamageTypeStr;
    local string Action;

    if (Killer != None && KilledPlayer != None)
    {
        if (Killer.PlayerReplicationInfo != None && KilledPlayer.PlayerReplicationInfo != None)
        {
            if (Killer.GetTeamNum() == KilledPlayer.GetTeamNum())
            {
                if (!bLogTeamKills)
                {
                    return;
                }
                Action = TeamKillAction;
            }
            else
            {
                if (!bLogKills)
                {
                    return;
                }
                Action = KillAction;
            }

            LastHitDamageTypeStr = LastHitDamageType(KilledPlayer);

            if (KilledPlayer == Killer)
            {
                Cause = "SUICIDE_" $ LastHitDamageTypeStr;
            }
            else
            {
                Cause = LastHitDamageTypeStr;
            }

            KillerSteamId64Hex = class'OnlineSubsystem'.static.UniqueNetIdToString(
                Killer.PlayerReplicationInfo.UniqueId);
            KilledPlayerSteamId64Hex = class'OnlineSubsystem'.static.UniqueNetIdToString(
                KilledPlayer.PlayerReplicationInfo.UniqueId);

            LogRecord = "(" $ TimeStamp() $ ")";
            LogRecord $= " '" $ Killer.PlayerReplicationInfo.PlayerName;
            LogRecord $= "' [" $ KillerSteamId64Hex $ "]";
            LogRecord $= " " $ Action $ " '" $ KilledPlayer.PlayerReplicationInfo.PlayerName;
            LogRecord $= "' [" $ KilledPlayerSteamId64Hex $ "]";
            LogRecord $= " with " $ "<" $ Cause $ ">";

            Writer.Logf(LogRecord);

            if (bLinkEnabled)
            {
                TKLMTLC.SendBufferedData(LogRecord);
            }
        }
    }
}

final function CloseWriter()
{
    if (Writer != None)
    {
        Writer.Logf("--- KillLog End: " $ TimeStamp() $ " ---");
        Writer.CloseFile();
        Writer.Destroy();
        Writer = None;
    }
}

final function CloseLink()
{
    if (TKLMTLC != None)
    {
        bLinkEnabled = False;
        TKLMTLC.Close();
        TKLMTLC.Destroy();
        TKLMTLC = None;
    }
}

function ModifyMatchWon(out byte out_WinningTeam, out byte out_WinCondition, optional out byte out_RoundWinningTeam)
{
    `log("[TKLMutator]: ModifyMatchWon()");
    CloseWriter();
    CloseLink();
    super.ModifyMatchWon(out_WinningTeam, out_WinCondition, out_RoundWinningTeam);
}

event Destroyed()
{
    `log("[TKLMutator]: Destroyed()");
    bEnabled = False;
    CloseWriter();
    CloseLink();
    super.Destroyed();
}
