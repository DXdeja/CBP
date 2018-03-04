class CBPSpeedFix extends Info;

var config int CheckTicks;
var config float Tolerance;
var config bool bPlayerSideLogging;

var float cTime;
var int counter;

replication
{
	reliable if (Role == ROLE_Authority)
		SendServerTime, bPlayerSideLogging;
}

simulated function PostBeginPlay()
{
	log("CBP: Speed fix init.");
}

simulated function Tick(float DeltaTime)
{
	cTime += DeltaTime;
	
	if (Role == ROLE_Authority)
	{
		if (CheckTicks < 10) 
		{
			CheckTicks = 10;
			SaveConfig();
		}
		counter++;
		if (counter >= CheckTicks)
		{
			if (Tolerance > 0.500)
			{
				Tolerance = 0.500;
				SaveConfig();
			}
			else if (Tolerance < 0.001)
			{
				Tolerance = 0.001;
				SaveConfig();
			}
			SendServerTime(cTime, Tolerance);
			counter = 0;
			cTime = 0.0;
		}
	}
}

simulated function SendServerTime(float STime, float t)
{
	if (Role < ROLE_Authority)
	{
		if ((STime > (cTime + t)) || (STime < (cTime - t)))
			SpeedFix(STime / cTime);
		cTime = 0;
	}
}

simulated function SpeedFix(float ddil)
{
	ddil = FClamp(ddil, 0.1, 10.0);
	Level.TimeDilation *= ddil;
	if (bPlayerSideLogging)
		log("CBP: Time dilated to: " $ Level.TimeDilation);
}

DefaultProperties
{
	RemoteRole=ROLE_SimulatedProxy
	bOnlyOwnerSee=True
    NetPriority=10.000000

	CheckTicks=20
	Tolerance=0.02
	bPlayerSideLogging=false
}