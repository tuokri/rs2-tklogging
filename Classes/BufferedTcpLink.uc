//=============================================================================
// BufferedTcpLink: buffered outbound communication over TCP socket.
// Adapted from Unreal Engine 2 source code by fluudah (tuokri on GitHub).
// Copyright Epic Games, Inc. All Rights Reserved.
//=============================================================================
class BufferedTcpLink extends TcpLink;

// var byte            InputBuffer[`TCP_BUFFER_SIZE];
var byte            OutputBuffer[`TCP_BUFFER_SIZE];

// var int             InputBufferHead;
// var int             InputBufferTail;

var int             OutputBufferHead;
var int             OutputBufferTail;

var string          OutputQueue;
var int             OutputQueueLen;

// var string          InputQueue;
// var int             InputQueueLen;

var bool            bEOF;
var bool            bAcceptNewData;

// var string          CRLF;
// var string          CR;
// var string          LF;

function PreBeginPlay()
{
    ResetBuffer();
    super.PreBeginPlay();
}

final function ResetBuffer()
{
    OutputQueueLen = 0;
    // InputQueueLen = 0;
    // InputBufferHead = 0;
    // InputBufferTail = 0;
    OutputBufferHead = 0;
    OutputBufferTail = 0;
    // CRLF = Chr(10) $ Chr(13);
    // CR = Chr(13);
    // LF = Chr(10);
    bEOF = False;
    bAcceptNewData = True;
    LinkMode = MODE_Line;
    ReceiveMode = RMODE_Manual;
}

// final function string ParseDelimited(string Text, string Delimiter, int Count, optional bool bToEndOfLine)
// {
//     local string Result;
//     local int Found, i;
//     local string s;

//     Result = "";
//     Found = 1;

//     for (i = 0; i < Len(Text); i++)
//     {
//         s = Mid(Text, i, 1);
//         if (InStr(Delimiter, s) != -1)
//         {
//             if (Found == Count)
//             {
//                 if (bToEndOfLine)
//                     return Result $ Mid(Text, i);
//                 else
//                     return Result;
//             }

//             Found++;
//         }
//         else
//         {
//             if (Found >= Count)
//                 Result = Result $ s;
//         }
//     }

//     return Result;
// }

final function bool SendEOF()
{
    local int NewTail;

    NewTail = OutputBufferTail;
    NewTail = (NewTail + 1) % `TCP_BUFFER_SIZE;
    if (NewTail == OutputBufferHead)
    {
        // `log("[BufferedTcpLink]: output buffer overrun");
        return False;
    }
    OutputBuffer[OutputBufferTail] = 0;
    OutputBufferTail = NewTail;

    return True;
}

// Read an individual character, returns 0 if no characters waiting.
// final function int ReadChar()
// {
//     local int c;
//     if (InputBufferHead == InputBufferTail) return 0;

//     c = InputBuffer[InputBufferHead];
//     InputBufferHead = (InputBufferHead + 1) % `TCP_BUFFER_SIZE;

//     return c;
// }


// Take a look at the next waiting character, return 0 if no characters waiting.
// final function int PeekChar()
// {
//     if (InputBufferHead == InputBufferTail) return 0;
//     return InputBuffer[InputBufferHead];
// }

// We're not intending to receive any data.
// final function bool ReadBufferedLine(out string Text)
// {
    // local int NewHead;

    // Text = "";

    // NewHead = InputBufferHead;
    // while (NewHead != InputBufferTail)
    // {
    //     if (InputBuffer[NewHead] == 13)
    //     {
    //         // it's an Enter
    //         NewHead = (NewHead + 1) % `TCP_BUFFER_SIZE;
    //         if (NewHead != InputBufferTail)
    //         {
    //             if (InputBuffer[NewHead] == 10)
    //             {
    //                 // Eat a linefeed
    //                 NewHead = (NewHead + 1) % `TCP_BUFFER_SIZE;
    //             }
    //         }
    //         InputBufferHead = NewHead;
    //         return True;
    //     }

    //     Text = Text $ Chr(InputBuffer[NewHead]);
    //     NewHead = (NewHead + 1) % `TCP_BUFFER_SIZE;
    // }

    // return False;
// }

function bool SendBufferedData(string Text)
{
    local int TextLen;
    local int i;
    local int NewTail;

    // `log("Sending: " $ Text $ ".");

    if (!bAcceptNewData)
    {
        return False;
    }

    TextLen = Len(Text);
    for (i = 0; i < TextLen; i++)
    {
        NewTail = OutputBufferTail;
        NewTail = (NewTail + 1) % `TCP_BUFFER_SIZE;
        if (NewTail == OutputBufferHead)
        {
            // `log("[BufferedTcpLink]: output buffer overrun");
            return False;
        }
        OutputBuffer[OutputBufferTail] = Asc(Mid(Text, i, 1));
        OutputBufferTail = NewTail;
    }

    return True;
}

// DoQueueIO is intended to be called from Tick().
final function DoBufferQueueIO()
{
    // local int i;
    // local int NewTail;
    local int NewHead;
    // local int BytesSent;
    // local byte ch;

    if (IsConnected())
    {
        // Output data
        OutputQueueLen = 0;
        OutputQueue = "";
        NewHead = OutputBufferHead;
        while ((OutputQueueLen < 255) && (NewHead != OutputBufferTail))
        {
            // Put some more stuff in the output queue.
            if (OutputBuffer[NewHead] != 0)
            {
                OutputQueue = OutputQueue $ Chr(OutputBuffer[NewHead]);
                OutputQueueLen++;
            }
            else
            {
                bEOF = True;
            }

            NewHead = (NewHead + 1) % `TCP_BUFFER_SIZE;
        }

        if (OutputQueueLen > 0)
        {
            // BytesSent = SendText(OutputQueue $ "");
            SendText(OutputQueue $ "");
            OutputBufferHead = NewHead; // (OutputBufferHead + BytesSent) % `TCP_BUFFER_SIZE;
            // `log("Sent " $ BytesSent $ " bytes >>" $ OutputQueue $ "<<");
        }
    }

    // Now process any received data
    // while ((IsDataPending() && IsConnected()) || InputQueueLen>0)
    // {
    //     // if there's no data waiting since the last buffer-full
    //     if (InputQueueLen == 0)
    //     {
    //         if (ReadText(InputQueue) > 0)
    //         {
    //             InputQueueLen=Len(InputQueue);
    //             //`log("ReadText: " $ InputQueue);
    //         }
    //     }

    //     if (InputQueueLen > 0)
    //     {
    //         for (i=0; i<Len(InputQueue); i++)
    //         {
    //             NewTail = InputBufferTail;
    //             NewTail = (NewTail + 1) % `TCP_BUFFER_SIZE;
    //             if (NewTail == InputBufferHead)
    //             {
    //                 InputQueueLen = InputQueueLen - i;
    //                 InputQueue = Mid(InputQueue, i, InputQueueLen);
    //                 return;
    //             }

    //             InputBuffer[InputBufferTail] = Asc(Mid(InputQueue, i, 1));
    //             InputBufferTail = NewTail;
    //         }

    //         InputQueueLen = 0;
    //     }
    //     else
    //     {
    //         break;
    //     }
    // }
}

function bool Close()
{
    bAcceptNewData = False;
    while (!SendEOF()) {}
    return super.Close();
}

defaultproperties
{
    TickGroup=TG_DuringAsyncWork
}
