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
        Logger.Initialize(TKLFileName, Writer);
    }
    super.PreBeginPlay();
}

function ScoreKill(Controller Killer, Controller KilledPlayer)
{
    if (bLogTeamKills)
    {
        if (Logger != None)
        {
            Logger.LogIfTeamKill(Killer, KilledPlayer);
        }
        else
        {
            `log("TKLMutator_ERROR: Attempted logging on NULL TKLLogger!");
        }
    }
    super.ScoreKill(Killer, KilledPlayer);
}

event Destroyed()
{
    Logger.Destroy();
    if (Writer != None)
    {
        Writer.CloseFile();
        Writer.Destroy();
    }
    super.Destroyed();
}
