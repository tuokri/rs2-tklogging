class TKLMutator extends ROMutator
    config(Game_TKLMutator);

var config Bool bLogTeamKills;
var config String TKLFileName;

var TKLLogger Logger;
var FileWriter Writer;

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
        if (Logger != None)
        {
            Logger.LogIfTeamKill(Killer, KilledPlayer, Writer, TimeStamp());
        }
        else
        {
            `log("TKLMutator_ERROR: Attempted logging on NULL TKLLogger!");
        }
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
