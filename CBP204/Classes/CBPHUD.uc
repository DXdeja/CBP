class CBPHUD extends HUD;

var Font TestFont;
var Color WhiteCol;
var Color RedCol;

const LagoMeterX = 0.75;
const LagoMeterY = 0.7;

struct PastLMVars
{
	var int Ping;
	var byte Loss;
	var byte SLoad;
};

var PastLMVars LMVars[100];
var float LastLagometerUpdateTime;
var float LagometerUpdateInterval;

var Texture LagTexture;
var Texture LagometerBack;

simulated function ClearLagometer()
{
	local int i;

	for (i = 0; i < 100; i++)
	{
		LMVars[i].Loss = 0;
		LMVars[i].Ping = 0;
		LMVars[i].SLoad = 0;
	}
	LastLagometerUpdateTime = -999;
}

simulated function AddLagometerValue(int Ping, byte Loss, byte SLoad)
{
	local int i;

	for (i = 0; i < 99; i++)
	{
		LMVars[i].Loss = LMVars[i + 1].Loss;
		LMVars[i].Ping = LMVars[i + 1].Ping;
		LMVars[i].SLoad = LMVars[i + 1].SLoad;
	}
	LMVars[99].Loss = Loss;
	LMVars[99].Ping = Ping;
	LMVars[99].SLoad = SLoad;
}

simulated function DrawLagometer(Canvas canvas, Lagometer LMActor)
{
	local int i, x, y, d;

	if ((Level.TimeSeconds - LagometerUpdateInterval) > LastLagometerUpdateTime)
	{
		LastLagometerUpdateTime = Level.TimeSeconds;
		AddLagometerValue(LMActor.Ping, LMActor.PacketLoss, LMActor.ServerLoad);
	}

	x = canvas.SizeX * LagoMeterX;
	y = canvas.SizeY * LagoMeterY;

	canvas.SetPos(x, y - 50);
	canvas.DrawColor = canvas.Default.DrawColor;
	canvas.DrawRect(LagometerBack, 100, 101);

	for (i = 0; i < 100; i++)
	{
		canvas.CurX = x;
		d = LMVars[i].Ping / 5;
		canvas.CurY = y - d;
		canvas.DrawColor.R = 0;
		canvas.DrawColor.G = 255;
		canvas.DrawColor.B = 0;
		canvas.DrawRect(LagTexture, 1, d);

		canvas.CurX = x;
		d = LMVars[i].Loss / 2;
		canvas.CurY = y - d;
		canvas.DrawColor.R = 255;
		canvas.DrawColor.G = 0;
		canvas.DrawColor.B = 0;
		canvas.DrawRect(LagTexture, 1, d);

		canvas.CurX = x;
		d = LMVars[i].SLoad / 5;
		canvas.CurY = y + 51 - d;
		canvas.DrawColor.R = 0;
		canvas.DrawColor.G = 0;
		canvas.DrawColor.B = 255;
		canvas.DrawRect(LagTexture, 1, d);

		x++;
	}
}

simulated function bool IsHUDVisible()
{
	local DeusExRootWindow root;
	//if (MenuUIWindow(root.) == none) return true;
	//else return false;
	root = DeusExRootWindow(CBPPlayer(Owner).rootWindow);
	return root.hud.bIsVisible;
}

simulated function DrawDebugShit(canvas Canvas, CBPPlayer player)
{
	Canvas.SetPos(20, 100);
	Canvas.Font = TestFont;
	Canvas.DrawText("This is TESTING ONLY!");
	Canvas.SetPos(100, 120);
	//Canvas.DrawText("You are playing as: " $ player.PawnInfo $ ", healthtorso: " $ player.HealthTorso);
}

simulated function DrawDeadHUD(Canvas canvas, CBPPlayer player)
{
	local float h, w;
	local int Y;
	local string str;

	Y = canvas.SizeY - 120;
	canvas.Font = TestFont;

	if (player.MyLastKiller != none)
	{
		if (player.MyLastKiller == player)
		{
			str = class'MultiplayerMessageWin'.default.KilledYourselfString;
		}
		else
		{
			str = class'MultiplayerMessageWin'.default.KilledByString $ player.MyLastKiller.PlayerReplicationInfo.PlayerName;
		}

		canvas.DrawColor = RedCol;
		canvas.TextSize(str, w, h);
		canvas.SetPos((canvas.SizeX - w) / 2, Y);
		canvas.DrawText(str);
	}

	Y += 20;

	canvas.DrawColor = WhiteCol;
	if (player.bCanRestart)
	{
		
		str = class'MultiplayerMessageWin'.default.FireToContinueMsg;
		canvas.TextSize(str, w, h);
		canvas.SetPos((canvas.SizeX - w) / 2, Y);
		canvas.DrawText(str);
	}
	else
	{
		str = "Wait " $ int(player.AfterDeathPause - player.TimerCounter + 1.0) $ " seconds.";
		canvas.TextSize(str, w, h);
		canvas.SetPos((canvas.SizeX - w) / 2, Y);
		canvas.DrawText(str);
	}
}

simulated event PostRender(Canvas canvas)
{
	local CBPPlayer PlayerOwner;

	super.PostRender(canvas);

	PlayerOwner = CBPPlayer(Owner);
	if (PlayerOwner == none) return;

	//DrawDebugShit(canvas, PlayerOwner);

	if (IsHUDVisible() && PlayerOwner.bIsAlive)
	{
		if (PlayerOwner.BeltInventory != none)
			PlayerOwner.BeltInventory.Draw(canvas);

		if (CBPAugmentationManager(PlayerOwner.AugmentationSystem) != none)
			CBPAugmentationManager(PlayerOwner.AugmentationSystem).Draw(canvas);

		if (PlayerOwner.PawnInfo != none)
			PlayerOwner.PawnInfo.static.Event_HUDDraw(PlayerOwner, canvas);

		if (PlayerOwner.Scoring != none && PlayerOwner.bShowScores)
			PlayerOwner.Scoring.ShowScores(canvas);
	}
	else if (PlayerOwner.IsInState('Dying') && PlayerOwner.bShowDeadHUD)
	{
		DrawDeadHUD(canvas, PlayerOwner);
	}

	if (PlayerOwner.bShowDeadHUD && PlayerOwner.Scoring != none && PlayerOwner.bShowScores)
			PlayerOwner.Scoring.ShowScores(canvas);

	if (PlayerOwner.LMActor != none)
		DrawLagometer(canvas, PlayerOwner.LMActor);
}

defaultproperties
{
    TestFont=Font'DeusExUI.FontMenuSmall_DS'
    WhiteCol=(R=255,G=255,B=255,A=0),
    RedCol=(R=255,G=0,B=0,A=0),
    LastLagometerUpdateTime=-999.00
    LagometerUpdateInterval=0.05
    LagTexture=Texture'Extension.Solid'
    LagometerBack=Texture'DeusExItems.Skins.BlackMaskTex'
}
