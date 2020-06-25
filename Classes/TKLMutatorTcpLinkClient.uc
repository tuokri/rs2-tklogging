class TKLMutatorTcpLinkClient extends BufferedTcpLink
    config(Game_TKLMutator);

var config string TKLServerHost;
var config int TKLServerPort;
var config int MaxRetries;
var config string UniqueRS2ServerId;

var int Retries;
var bool bRetryOnClosed;

final function ResolveServer()
{
    `log("[TKLMutatorTcpLinkClient]: resolving: " $ TKLServerHost);
    Resolve(TKLServerHost);
}

event PostBeginPlay()
{
    Disable('Tick');
    super.PostBeginPlay();

    bRetryOnClosed = True;

    if (MaxRetries < 0)
    {
        MaxRetries = `MAX_RESOLVE_RETRIES;
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
        return;
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
    Enable('Tick');
}

event Closed()
{
    Disable('Tick');
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
}

final function Retry()
{
    if (Retries > MaxRetries)
    {
        `log("[TKLMutatorTcpLinkClient]: max retries exceeded (" $ MaxRetries $ ")");
        return;
    }
    Retries++;
    SetTimer(5, False, 'ResolveServer');
}

defaultproperties
{
    TickGroup=TG_DuringAsyncWork
}
