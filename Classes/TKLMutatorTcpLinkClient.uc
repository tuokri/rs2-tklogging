class TKLMutatorTcpLinkClient extends BufferedTcpLink
    config(Game_TKLMutator);

var config string TKLServerHost;
var config int TKLServerPort;

event PostBeginPlay()
{
    super.PostBeginPlay();
    `log("[TKLMutatorTcpLinkClient] resolving: " $ TKLServerHost);
    Resolve(TKLServerHost);
}

event Resolved(IpAddr Addr)
{
    `log("[TKLMutatorTcpLinkClient] " $ TKLServerHost $ " resolved to " $ IpAddrToString(Addr));
    Addr.Port = TKLServerPort;

    `log("[TKLMutatorTcpLinkClient] bound to port: " $ BindPort());
    if (!Open(Addr))
    {
        `log("[TKLMutatorTcpLinkClient] open failed");
        return;
    }
}

event ResolveFailed()
{
    `log("[TKLMutatorTcpLinkClient] unable to resolve " $ TKLServerHost);
}

event Opened()
{
    `log("[TKLMutatorTcpLinkClient] connection opened");  
}

event Closed()
{
    `log("[TKLMutatorTcpLinkClient] connection closed");
}

function bool SendBufferedData(string Text)
{
    if (!IsConnected())
    {
        `log("[TKLMutatorTcpLinkClient] attempting to queue buffered data but connection is not open");
    }
    return super.SendBufferedData(Text);
}

function Tick(float DeltaTime)
{
    DoBufferQueueIO();
}
