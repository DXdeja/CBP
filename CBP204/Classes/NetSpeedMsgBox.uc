//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NetSpeedMsgBox extends MenuUIMessageBoxWindow;

function PostResult( int buttonNumber )
{
    if (buttonNumber == 0)
        Player.ConsoleCommand("Netspeed 20000");

    root.PopWindow();
}

DefaultProperties
{
}
