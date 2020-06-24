class TKLMutatorTcpLinkClient extends BufferedTcpLink
    config(Game_TKLMutator);

var config string TKLServerHost;
var config int TKLServerPort;

var int ResolveRetries;

final function ResolveServer()
{
    `log("[TKLMutatorTcpLinkClient]: resolving: " $ TKLServerHost);
    ResolveRetries++;
    if (ResolveRetries > `MAX_RESOLVE_RETRIES)
    {
        `log("[TKLMutatorTcpLinkClient]: max retries exceeded (" $ `MAX_RESOLVE_RETRIES $ ")");
        return;
    }
    Resolve(TKLServerHost);
}

event PostBeginPlay()
{
    super.PostBeginPlay();
    ResolveServer();
}

event Resolved(IpAddr Addr)
{
    `log("[TKLMutatorTcpLinkClient]: " $ TKLServerHost $ " resolved to " $ IpAddrToString(Addr));
    Addr.Port = TKLServerPort;

    `log("[TKLMutatorTcpLinkClient]: bound to port: " $ BindPort());
    if (!Open(Addr))
    {
        `log("[TKLMutatorTcpLinkClient]: failed to open connection, retrying in 5 seconds");
        SetTimer(5, False, 'ResolveServer');
    }
}

event ResolveFailed()
{
    `log("[TKLMutatorTcpLinkClient]: unable to resolve, retrying after 5 seconds " $ TKLServerHost);
    SetTimer(5, False, 'ResolveServer');
}

event Opened()
{
    `log("[TKLMutatorTcpLinkClient]: connection opened");
}

event Closed()
{
    `log("[TKLMutatorTcpLinkClient]: connection closed");
}

function bool SendBufferedData(string Text)
{
    if (!IsConnected())
    {
        `log("[TKLMutatorTcpLinkClient]: attempting to queue buffered data but connection is not open");
    }
    return super.SendBufferedData(Text);
}

function Tick(float DeltaTime)
{
    DoBufferQueueIO();
}

defaultproperties
{
    TickGroup=TG_DuringAsyncWork
}
