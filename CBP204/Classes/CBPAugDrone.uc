class CBPAugDrone extends CBPAugmentation
	abstract;

var float reconstructTime;

static function ActivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;

	manager = GetManager(dxp);
	if (dxp.Level.TimeSeconds - manager.LastDroneTime < default.reconstructTime)
	{
		dxp.ClientMessage("Reconstruction will be complete in" @ int(default.reconstructTime - (dxp.Level.TimeSeconds - manager.lastDroneTime)) @ "seconds");
		AugDeactivate(dxp);
	}
	else
	{
		dxp.bSpyDroneActive = True;
		dxp.spyDroneLevel = 3;
		dxp.spyDroneLevelValue = default.LevelValues[3];
		dxp.Acceleration = vect(0,0,0);
	}
}

static function DeactivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;

	if (dxp.bSpyDroneActive)
	{
		manager = GetManager(dxp);
		manager.LastDroneTime = dxp.Level.TimeSeconds;
	}

	dxp.bSpyDroneActive = False;
}

defaultproperties
{
    reconstructTime=30.00
    OldAugClass=Class'DeusEx.AugDrone'
    ManagerIndex=13
    EnergyRate=20.00
    Icon=Texture'DeusExUI.UserInterface.AugIconDrone'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconDrone_Small'
    AugmentationName="Spy Drone"
    LevelValues(0)=10.00
    LevelValues(1)=20.00
    LevelValues(2)=35.00
    LevelValues(3)=100.00
    MPConflictSlot=9
}
