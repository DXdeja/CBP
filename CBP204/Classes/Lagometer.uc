class Lagometer extends Info;

var byte Ping;
var byte PacketLoss;
var byte ServerLoad;
var byte RepRespTime;

var bool bCleared;

var float PingSendTime;
var bool bPingComplete;

replication
{
	unreliable if (Role == ROLE_Authority)
		ClientPingFunc;

	unreliable if (Role < ROLE_Authority)
		ServerPingFunc;
}

function ServerPingFunc()
{
	ClientPingFunc();
}

simulated function ClientPingFunc()
{
	local int tmpping;

	bPingComplete = true;
	tmpping = int((Level.TimeSeconds - PingSendTime) * 1000.0);
	if (tmpping > 500) tmpping = 500;
	Ping = byte(tmpping / 2);
	PacketLoss = 0;
}

simulated function Tick(float DeltaTime)
{
	if (Role < ROLE_Authority && bNetOwner)
	{
		if (!bCleared && CBPPlayer(Owner) != none && CBPHUD(CBPPlayer(Owner).myHUD) != none)
		{
			CBPHUD(CBPPlayer(Owner).myHUD).ClearLagometer();
			PlayerPawn(Owner).ConsoleCommand("inject userflag 1");
			bCleared = true;
			bPingComplete = true;
		}

		if (!bPingComplete && ((PingSendTime + 1.0) < Level.TimeSeconds))
		{
			bPingComplete = true;
			PacketLoss = 100;
		}

		if (bPingComplete)
		{
			bPingComplete = false;
			PingSendTime = Level.TimeSeconds;
			ServerPingFunc();
		}
	}

	super.Tick(DeltaTime);
}

simulated function SetServerLoad(string str)
{
	local int tickrate;
	local float act, net;

	str = Right(str, Len(str) - 2);
	tickrate = int(Left(str, InStr(str, " ")));
	str = Right(str, Len(str) - InStr(str, "act="));
	str = Right(str, Len(str) - 4);
	act = float(Left(str, InStr(str, " ")));
	str = Right(str, Len(str) - InStr(str, "net="));
	str = Right(str, Len(str) - 4);
	net = float(Left(str, InStr(str, " ")));

	ServerLoad = byte(((act + net) * 250.0) / (1000.0 / float(tickrate)));
	if (ServerLoad > 250) ServerLoad = 250;
}

simulated event Destroyed()
{
	if (Role < ROLE_Authority && bNetOwner)
		PlayerPawn(Owner).ConsoleCommand("inject userflag 0");
	super.Destroyed();
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bOnlyOwnerSee=True
    NetPriority=3.00
}
