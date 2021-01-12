class TKLMutator extends ROMutator
    config(Mutator_TKLMutator_Server);

var config bool bLogTeamKills;
var config bool bLogKills;
var config bool bSendLogToServer;
var config string TKLFileName;

var bool bEnabled;
var bool bLinkEnabled;
var string Cause;
var string TeamKillAction;
var string KillAction;
var FileWriter Writer;
var TKLMutatorTcpLinkClient TKLMTLC;

var string FileRecord; // Written to file on disk.
// var string NetRecord; // Compressed log record sent over network.

struct KillLogRecord
{
    var string TimeStamp;
    var string KillerName;
    var string VictimName;
    var string KillerID;
    var string VictimID;
    var string Action;
    var string Cause;
};

var KillLogRecord LogRecord;
var array<KillLogRecord> RecordQueue;

final function FirstTimeConfig()
{
    if ((!bLogTeamKills)
        && (!bLogKills)
        && (!bSendLogToServer)
        && (Len(TKLFileName) == 0))
    {
        `log("[TKLMutator]: setting config values to first time defaults");
        bLogTeamKills = True;
        bLogKills = False;
        bSendLogToServer = False;
        TKLFileName = "KillLog";
        class'TKLMutatorTcpLinkClient'.static.StaticFirstTimeConfig();
    }
}

function PreBeginPlay()
{
    FirstTimeConfig();
    SaveConfig();

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
            `log("[TKLMutator]: log sending to TKLServer is enabled, "
                $ "attempting to spawn TKLMutatorTcpLinkClient");
            TKLMTLC = Spawn(class'TKLMutatorTcpLinkClient');
            if (TKLMTLC == None)
            {
                bLinkEnabled = False;
                `log("[TKLMutator]: error spawning TKLMutatorTcpLinkClient");
                return;
            }
            TKLMTLC.Parent = self;
            bLinkEnabled = True;
            `log("[TKLMutator]: TKLMutatorTcpLinkClient initialized");
        }

        SetTimer(0.1, True, 'ProcessQueue');
    }

    super.PreBeginPlay();
}

function PostBeginPlay()
{
    SetCancelOpenLinkTimer(2.0);
    super.PostBeginPlay();
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
        FileName = "KillLog";
    }

    Writer.OpenFile(FileName, FWFT_Log,, True, True);
    Writer.Logf("--- KillLog Begin: " $ TimeStamp() $ " ---");
}

final function string LastHitDamageType(Controller C)
{
    if (C.Pawn == None)
    {
        return "UNKNOWN_CAUSE";
    }
    return string(ROPawn(C.Pawn).LastTakeHitInfo.DamageType);
}

final function LogKill(Controller Killer, Controller Victim)
{
    local string LastHitDamageTypeStr;
    local string Action;

    if (Killer != None && Victim != None)
    {
        if (Killer.PlayerReplicationInfo != None && Victim.PlayerReplicationInfo != None)
        {
            if (Killer.GetTeamNum() == Victim.GetTeamNum())
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

            LastHitDamageTypeStr = LastHitDamageType(Victim);

            if (Victim == Killer)
            {
                Cause = "SUICIDE_" $ LastHitDamageTypeStr;
            }
            else
            {
                Cause = LastHitDamageTypeStr;
            }

            LogRecord.TimeStamp = TimeStamp();
            LogRecord.KillerName = Killer.PlayerReplicationInfo.PlayerName;
            LogRecord.VictimName = Victim.PlayerReplicationInfo.PlayerName;
            LogRecord.KillerID = class'OnlineSubsystem'.static.UniqueNetIdToString(Killer.PlayerReplicationInfo.UniqueId);
            LogRecord.VictimID = class'OnlineSubsystem'.static.UniqueNetIdToString(Victim.PlayerReplicationInfo.UniqueId);
            LogRecord.Action = Action;
            LogRecord.Cause = Cause;

            RecordQueue.AddItem(LogRecord);
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
    }
}

final function CloseLink()
{
    if (TKLMTLC != None)
    {
        bLinkEnabled = False;
        TKLMTLC.Close();
        TKLMTLC.Destroy();
    }
}

// Stupid hack to avoid TKLMTLC.Open() from spamming logs if it fails.
final function SetCancelOpenLinkTimer(float Time)
{
    SetTimer(Time, False, 'CancelOpenLink');
}

final function CancelOpenLink()
{
    if (TKLMTLC != None && !TKLMTLC.IsConnected())
    {
        `log("[TKLMutator]: cancelling link connection attempt");
        TKLMTLC.Close();
    }
}

final function CleanUp()
{
    bEnabled = False;
    CloseWriter();
    CloseLink();
}

// function ModifyMatchWon(out byte out_WinningTeam, out byte out_WinCondition, optional out byte out_RoundWinningTeam)
// {
//     `log("[TKLMutator]: ModifyMatchWon()");
//     CleanUp();
//     super.ModifyMatchWon(out_WinningTeam, out_WinCondition, out_RoundWinningTeam);
// }

// Simple "compression" for network log records.
/*
final function string Compress(String Str)
{
    local string NetRecord;

    NetRecord = "(" $ Record.TimeStamp $ ")";
    NetRecord $= " '" $ Record.KillerName;
    NetRecord $= "' [" $ Record.KillerID $ "]";
    NetRecord $= " " $ Left(Record.Action, 1) $ " '" $ Record.VictimName;
    NetRecord $= "' [" $ Record.VictimID $ "]";
    NetRecord $= " with " $ "<" $ Record.Cause $ ">";

    return NetRecord;
}
*/

final function ProcessQueue()
{
    local int NumProcessed;
    local KillLogRecord Record;

    if (RecordQueue.Length == 0)
    {
        return;
    }

    foreach RecordQueue(Record)
    {
        FileRecord = "(" $ Record.TimeStamp $ ")";
        FileRecord $= " '" $ Record.KillerName;
        FileRecord $= "' [" $ Record.KillerID $ "]";
        FileRecord $= " " $ Record.Action $ " '" $ Record.VictimName;
        FileRecord $= "' [" $ Record.VictimID $ "]";
        FileRecord $= " with " $ "<" $ Record.Cause $ ">";

        Writer.Logf(FileRecord);

        if (bLinkEnabled && TKLMTLC != None)
        {
            // NetRecord = Compress(Record);
            TKLMTLC.SendBufferedData(FileRecord);
        }

        NumProcessed++;
    }

    RecordQueue.Remove(0, NumProcessed);
}

event Destroyed()
{
    `log("[TKLMutator]: Destroyed()");
    CleanUp();
    super.Destroyed();
}

defaultproperties
{
    TickGroup=TG_DuringAsyncWork
}
