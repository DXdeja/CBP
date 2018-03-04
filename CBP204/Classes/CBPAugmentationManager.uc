class CBPAugmentationManager extends AugmentationManager;

var const class<CBPAugmentation> mpAugs[18]; // 17 + 1 light
var byte mpStatus[18]; // 0 - do not have it, 1 = have it, 2 = active
var DeusExRootWindow root;
var CBPAugDummy DummyAug;

// aug variables
var float LastHealTime;
var bool bDefenseActive;
var float defenseSoundTime;
var float LastDefenseTime;
var float LastDroneTime;
var CBPBeam LightBeam1, LightBeam2;
//

var Color colAugActive;
var Color colAugInactive;
var Font AugFont;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		mpStatus;

	reliable if (Role == Role_Authority)
		SetDefenseAugStatus, SetTargetingAugStatus, SetVisionAugStatus;
}

simulated function SetVisionAugStatus(int LevelValue, bool IsActive)
{
   if (player == None)
      return;
   if (root == None)
   {
		SetRootWindow();
		if (root == none) return;
   }

   if (IsActive)
   {
      if (++root.hud.augDisplay.activeCount == 1)      
         root.hud.augDisplay.bVisionActive = True;
   }
   else
   {
      if (--root.hud.augDisplay.activeCount == 0)
         root.hud.augDisplay.bVisionActive = False;
      root.hud.augDisplay.visionBlinder = None;
   }
   root.hud.augDisplay.visionLevel = 3;
   root.hud.augDisplay.visionLevelValue = LevelValue;
}

simulated function SetTargetingAugStatus(bool IsActive)
{
   if (player == None)
      return;
   if (root == None)
   {
		SetRootWindow();
		if (root == none) return;
   }

	root.hud.augDisplay.bTargetActive = IsActive;
	root.hud.augDisplay.targetLevel = 3;
}

simulated function SetDefenseAugStatus(DeusExProjectile defenseTarget)
{
	local bool bActive;

   if (player == None)
      return;
   if (root == None)
   {
		SetRootWindow();
		if (root == none) return;
   }

   if (defenseTarget != none) bActive = true;
   root.hud.augDisplay.bDefenseActive = bActive;
   root.hud.augDisplay.defenseLevel = 3;
   root.hud.augDisplay.defenseTarget = defenseTarget;
}

function PostBeginPlay()
{
	// spawn dummy aug to handle Deactivate calls
	DummyAug = Spawn(class'CBPAugDummy', self);
	super.PostBeginPlay();
}

event Destroyed()
{
	if (DummyAug != none) DummyAug.Destroy();
	super.Destroyed();
}

function Tick(float DeltaTime)
{
	local int i;

	if (owner == none)
	{
		Destroy();
		return;
	}

	super.Tick(DeltaTime);

	for (i = 0; i < 18; i++)
	{
		mpAugs[i].static.StaticTick(player, DeltaTime);
	}
}

simulated function SetRootWindow()
{
	if (player != none) root = DeusExRootWindow(player.rootWindow);
}

function CBPPlayer getPlayer()
{
   return CBPPlayer(player);
}

function CreateAugmentations(DeusExPlayer newPlayer)
{
	player = newPlayer;
}

function AddDefaultAugmentations()
{
	mpStatus[17] = 1; // add light
}

simulated function RefreshAugDisplay()
{
	// do nothing
}

simulated function int NumAugsActive()
{
	local int i;
	local int count;

	if (player == None)
		return 0;

	for (i = 0; i < 18; i++)
	{
		if (mpStatus[i] == 2)
		{
			count++;
		}
	}

	return count;
}

function SetPlayer(DeusExPlayer newPlayer)
{
	player = newPlayer;
}

function BoostAugs(bool bBoostEnabled, Augmentation augBoosting)
{
}

simulated function int GetClassLevel(class<Augmentation> augClass)
{
	local int i;

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i].default.OldAugClass == augClass)
		{
			if (mpStatus[i] == 2) return 3;
			break;
		}
	}

	return -1;
}

simulated function float GetAugLevelValue(class<Augmentation> AugClass)
{
	local int i;

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i].default.OldAugClass == AugClass || mpAugs[i] == AugClass)
		{
			if (mpStatus[i] == 2)
			{
				return mpAugs[i].default.LevelValues[3];
			}
			else return -1.0;
		}
	}

	return -1.0;
}

simulated function float GetAugLevelValueWithIgnoredState(class<Augmentation> AugClass)
{
	local int i;

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i].default.OldAugClass == AugClass || mpAugs[i] == AugClass)
		{
			return mpAugs[i].default.LevelValues[3];
		}
	}

	return -1.0;
}

function ActivateAll()
{
	local int i;
	local bool bAugsWithFlag;

	if (!CBPPlayer(player).bIsAlive) return;

	bAugsWithFlag = AugsWithFlag();

	if ((player != None) && (player.Energy > 0))
	{
		for (i = 0; i < 17; i++) // without light aug
		{
			if (mpStatus[i] == 1 && (bAugsWithFlag || IsAllowedFlagAug(mpAugs[i])))
				mpAugs[i].static.AugActivate(player);
		}
	}
}

function DeactivateAll()
{
	local int i;

	for (i = 0; i < 18; i++)
	{
		if (mpStatus[i] == 2)
			mpAugs[i].static.AugDeactivate(player);
	}
}

// deprecated!
simulated function Augmentation FindAugmentation(Class<Augmentation> findClass)
{
	local int i;

	if (DummyAug == none) 
	{
		Log("WARNING: DummyAug is none!");
		return none;
	}

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i].default.OldAugClass == findClass)
		{
			if (mpStatus[i] > 0)
			{
				DummyAug.AugAffected = mpAugs[i];
				return DummyAug;
			}
			break;
		}
	}

	return none;
}

// deprecated! do not call it!
function Augmentation GivePlayerAugmentation(Class<Augmentation> giveClass)
{
	return none;
}

function bool NewGivePlayerAugmentation(class<CBPAugmentation> giveClass)
{
	local int i;

	if (giveClass == none) return false;

	// check if we already have aug @ that slot
	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i] != none && mpAugs[i].default.MPConflictSlot == giveClass.default.MPConflictSlot)
		{
			if (mpStatus[i] > 0) // already have it
				return false;
		}
	}

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i] == giveClass)
		{
			mpStatus[i] = 1;
			return true;
		}
	}

	return false;
}

function bool AugsWithFlag()
{
	return true;
}

simulated function bool IsAllowedFlagAug(class<CBPAugmentation> aug)
{
	return true;
}

function bool ActivateAugByKey(int keyNum)
{
	local int i;
	local class<CBPAugmentation> faug;

	if (!CBPPlayer(player).bIsAlive) return false;

	if ((keyNum < 0) || (keyNum > 9))
		return False;

	keyNum += 3;

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i].default.MPConflictSlot == keyNum)
		{
			if (mpStatus[i] > 0)
			{
				faug = mpAugs[i];
				break;
			}
		}
	}

	if (faug == none)
	{
		player.ClientMessage(NoAugInSlot);
		return false;
	}

	//if (!AugsWithFlag() && !IsAllowedFlagAug(faug))
	//{
	//	Player.ClientMessage("Cannot use this augmentation while carrying the flag!");
	//	return false;
	//}

	return faug.static.AugToggle(player);
}

simulated function Float CalcEnergyUse(float deltaTime)
{
	local float energyUse, energyMult;
	local int i;
	local bool bHasPowerAug;
	local bool bPowerAugOn;

	energyUse = 0;
	energyMult = 1.0;

	for (i = 0; i < 18; i++)
	{
		if (mpAugs[i] == class'CBPAugPower')
		{
			if (mpStatus[i] > 0) bHasPowerAug = true;
			if (mpStatus[i] == 2) bPowerAugOn = true;
		}

		if (mpStatus[i] == 2)
		{
			energyUse += ((mpAugs[i].static.NewGetEnergyRate() / 60) * deltaTime);
		}
	}

	if (bHasPowerAug)
	{
		if (energyUse > 0 && !bPowerAugOn)
			ActivateAugByKey(4);

		if (energyUse == 0 && bPowerAugOn)
			ActivateAugByKey(4);

		if (bPowerAugOn)
			energyMult = GetAugLevelValue(class'CBPAugPower');
	}

	energyUse *= energyMult;

	return energyUse;
}

function ResetAugmentations()
{
	local int i;

	for (i = 0; i < 18; i++)
	{
		mpAugs[i].static.AugDeactivate(player);
		mpStatus[i] = 0;
	}

	LastDroneTime = default.LastDroneTime;
	AddDefaultAugmentations();
}

simulated function Draw(Canvas canvas)
{
	local int X, Y, i;

	X = canvas.SizeX - 16 - 32 - 2;
	Y = 16;
	canvas.Font = AugFont;

	for (i = 0; i < 18; i++)
	{
		if (mpStatus[i] == 1 && player.bHUDShowAllAugs ||
			mpStatus[i] == 2)
		{
			if (mpStatus[i] == 2) canvas.DrawColor = colAugActive;
			else canvas.DrawColor = colAugInactive;

			// draw box
			canvas.SetPos(X, Y);
			canvas.DrawRect(Texture'Solid', 34, 1);
			canvas.SetPos(X, Y);
			canvas.DrawRect(Texture'Solid', 1, 34);
			canvas.SetPos(X + 33, Y);
			canvas.DrawRect(Texture'Solid', 1, 34);
			canvas.SetPos(X, Y + 33);
			canvas.DrawRect(Texture'Solid', 34, 1);

			// draw icon
			canvas.SetPos(X + 1, Y + 1);
			canvas.DrawTile(mpAugs[i].default.smallIcon, 32, 32, 0, 0, 32, 32);

			// draw text
			canvas.SetPos(X + 22, Y + 23);
			canvas.DrawText("F" $ mpAugs[i].default.MPConflictSlot);

			Y += 34;
		}
	}
}

defaultproperties
{
    mpAugs(0)=Class'CBPAugCombat'
    mpAugs(1)=Class'CBPAugShield'
    mpAugs(2)=Class'CBPAugHealing'
    mpAugs(3)=Class'CBPAugRadarTrans'
    mpAugs(4)=Class'CBPAugEnviro'
    mpAugs(5)=Class'CBPAugEMP'
    mpAugs(6)=Class'CBPAugBallistic'
    mpAugs(7)=Class'CBPAugTarget'
    mpAugs(8)=Class'CBPAugSpeed'
    mpAugs(9)=Class'CBPAugPower'
    mpAugs(10)=Class'CBPAugVision'
    mpAugs(11)=Class'CBPAugCloak'
    mpAugs(12)=Class'CBPAugDefense'
    mpAugs(13)=Class'CBPAugDrone'
    mpAugs(14)=Class'CBPAugStealth'
    mpAugs(15)=Class'CBPAugMuscle'
    mpAugs(16)=Class'CBPAugAqualung'
    mpAugs(17)=Class'CBPAugLight'
    lastDroneTime=-30.00
    colAugActive=(R=255,G=255,B=0,A=0),
    colAugInactive=(R=100,G=100,B=100,A=0),
    AugFont=Font'DeusExUI.FontTiny'
    bTravel=False
    NetPriority=1.40
}
