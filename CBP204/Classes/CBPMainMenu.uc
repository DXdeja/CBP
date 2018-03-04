// this is client-side spawnable actor that does all menu handling
class CBPMainMenu extends Info;

var CBPPlayer PlayerOwner;
var DeusExRootWindow RootWindow;
var class<DeusExBaseWindow> MenuClass;

function PostBeginPlay()
{
	super.PostBeginPlay();
	PlayerOwner = CBPPlayer(Owner);
	RootWindow = DeusExRootWindow(PlayerOwner.rootWindow);

    // CBP204
	FixNetSpeed();
	//
}

// CBP204
function FixNetSpeed()
{
	local NetSpeedMsgBox msgBox;

	if (PlayerOwner.Player.CurrentNetSpeed == 20000) return; // already maxed

	msgBox = NetSpeedMsgBox(RootWindow.PushWindow(Class'NetSpeedMsgBox', false));
	msgBox.SetTitle("Netspeed");
	msgBox.SetMessageText("Your current Netspeed is not configured optimally. Optimize now?");
	msgBox.SetMode(0);
	msgBox.SetNotifyWindow(RootWindow);

    //RootWindow.MessageBox("Netspeed", "Increase?", 0, False, RootWindow);
}
//

// called from PlayerPawn to show up menu, override this with your custom menu windows
function ShowMenu(byte forceteam)
{
	PlayerOwner.ConsoleCommand("FLUSH");
	RootWindow.InvokeMenu(MenuClass);
}

defaultproperties
{
    MenuClass=Class'DeusEx.MenuMain'
}
