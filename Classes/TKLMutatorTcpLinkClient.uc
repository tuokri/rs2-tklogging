class TKLMutatorTcpLinkClient extends BufferedTcpLink
    config(Mutator_TKLMutator_Server);

// See: https://github.com/tuokri/tklserver
var config string TKLServerHost;
var config int TKLServerPort;
var config int MaxRetries;
var config string UniqueRS2ServerId;

var int Retries;
var bool bRetryOnClosed;

// Must store reference to parent in order to start
// Open() cancellation timer in case the Open() call fails.
// When Open() call fails, it will block and spam log
// with errors. Timers in this class will also not work
// while the call to Open() is blocking.
var TKLMutator Parent;

static final function StaticFirstTimeConfig()
{
    if ((Len(default.TKLServerHost) == 0)
        && (default.TKLServerPort == 0)
        && (default.MaxRetries == 0)
        && (Len(default.UniqueRS2ServerId) == 0))
    {
        `log("[TKLMutatorTcpLinkClient]: setting config values to first time defaults");
        default.TKLServerHost = "localhost";
        default.TKLServerPort = 8586;
        default.MaxRetries = 5;
        default.UniqueRS2ServerId = "0000";
        StaticSaveConfig();
    }
}

final function FirstTimeConfig()
{
    if ((Len(TKLServerHost) == 0)
        && (TKLServerPort == 0)
        && (MaxRetries == 0)
        && (Len(UniqueRS2ServerId) == 0))
    {
        `log("[TKLMutatorTcpLinkClient]: setting config values to first time defaults");
        TKLServerHost = "localhost";
        TKLServerPort = 8586;
        MaxRetries = 5;
        UniqueRS2ServerId = "0000";
    }
}

event PreBeginPlay()
{
    FirstTimeConfig();
    SaveConfig();
}

final function ResolveServer()
{
    `log("[TKLMutatorTcpLinkClient]: resolving: " $ TKLServerHost);
    Resolve(TKLServerHost);
}

event PostBeginPlay()
{
    super.PostBeginPlay();

    bRetryOnClosed = True;

    if (MaxRetries < 0)
    {
        MaxRetries = `MAX_RESOLVE_RETRIES;
        `log("[TKLMutatorTcpLinkClient]: invalid MaxRetries, defaulting to: " $ `MAX_RESOLVE_RETRIES);
    }

    if (Len(UniqueRS2ServerId) != 4)
    {
        `log("[TKLMutatorTcpLinkClient]: invalid UniqueRS2ServerId, must be exactly 4 characters long");
        return;
    }

    ResolveServer();
}

event Resolved(IpAddr Addr)
{
    local int BoundPort;

    `log("[TKLMutatorTcpLinkClient]: " $ TKLServerHost $ " resolved to " $ IpAddrToString(Addr));
    Addr.Port = TKLServerPort;

    BoundPort = BindPort();
    if (BoundPort == 0)
    {
        `log("[TKLMutatorTcpLinkClient]: failed to bind port");
        Retry();
        return;
    }

    `log("[TKLMutatorTcpLinkClient]: bound to port: " $ BoundPort);

    if (!Open(Addr))
    {
        `log("[TKLMutatorTcpLinkClient]: failed to open connection, retrying in 5 seconds");
        Retry();
    }
}

event ResolveFailed()
{
    `log("[TKLMutatorTcpLinkClient]: unable to resolve, retrying in 5 seconds " $ TKLServerHost);
    Retry();
}

event Opened()
{
    `log("[TKLMutatorTcpLinkClient]: connection opened");
}

event Closed()
{
    if (bRetryOnClosed)
    {
        `log("[TKLMutatorTcpLinkClient]: connection closed unexpectedly, retrying in 5 seconds");
        Retry();
    }
    else
    {
        `log("[TKLMutatorTcpLinkClient]: connection closed");
    }
}

function bool Close()
{
    bRetryOnClosed = False;
    return super.Close();
}

function bool SendBufferedData(string Text)
{
    // if (!IsConnected())
    // {
    //     `log("[TKLMutatorTcpLinkClient]: attempting to queue data but connection is not open");
    // }
    Text = UniqueRS2ServerId $ Text;
    return super.SendBufferedData(Text);
}

function Tick(float DeltaTime)
{
    DoBufferQueueIO();
    super.Tick(DeltaTime);
}

final function Retry()
{
    if (Retries > MaxRetries)
    {
        `log("[TKLMutatorTcpLinkClient]: max retries exceeded (" $ MaxRetries $ ")");
        Close();
        return;
    }
    Retries++;
    SetTimer(5.0, False, 'ResolveServer');
    Parent.SetCancelOpenLinkTimer(7.0);
}

defaultproperties
{
    TickGroup=TG_DuringAsyncWork
}
