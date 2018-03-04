class CBPAugLight extends CBPAugmentation
	abstract;

static simulated function V18(DeusExPlayer dxp, CBPBeam LightBeam)
{
	local Vector Z14;
	local Vector S30;
	local Vector Z12;
	local Vector Z15;

	Z12 = dxp.Location;
	Z12.Z += dxp.BaseEyeHeight;
	Z15=Z12 + default.LevelValues[0] * vector(dxp.ViewRotation);
	dxp.Trace(S30, Z14, Z15, Z12, True);
	if (S30 == vect(0.00,0.00,0.00))
	{
		S30 = Z15;
	}
	LightBeam.SetLocation(S30 - vector(dxp.ViewRotation * 64));
	LightBeam.LightRadius=FClamp(VSize(S30 - Z12) / default.LevelValues[0], 0.00, 1.00) * 5.12 + 4.00;
	LightBeam.LightType=LT_Steady;
}

static simulated function V17(DeusExPlayer dxp, CBPBeam LightBeam)
{
	LightBeam.SetLocation(dxp.Location + (vect(0.00,0.00,1.00) * dxp.BaseEyeHeight) + (vect(1.00,1.00,0.00) * vector(dxp.Rotation * dxp.CollisionRadius * 1.50)));
}

static function ActivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	
	if (manager.LightBeam1 != none) manager.LightBeam1.Destroy();
	if (manager.LightBeam2 != none) manager.LightBeam2.Destroy();
	manager.LightBeam1 = dxp.Spawn(class'CBPBeam', dxp, '', dxp.Location);
	if (manager.LightBeam1 != none) V18(dxp, manager.LightBeam1);
	manager.LightBeam2 = dxp.Spawn(class'CBPBeam', dxp, '', dxp.Location);
	if (manager.LightBeam2 != none)
	{
		manager.LightBeam2.LightBrightness = 220;
		V17(dxp, manager.LightBeam2);
	}
}

static function DeactivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	if (manager.LightBeam1 != none) manager.LightBeam1.Destroy();
	if (manager.LightBeam2 != none) manager.LightBeam2.Destroy();
}

static function TickAction(DeusExPlayer dxp, float deltaTime)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	if (manager.LightBeam1 != none) V18(dxp, manager.LightBeam1);
	if (manager.LightBeam2 != none) V17(dxp, manager.LightBeam2);
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugLight'
    ManagerIndex=17
    EnergyRate=10.00
    MaxLevel=0
    Icon=Texture'DeusExUI.UserInterface.AugIconLight'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconLight_Small'
    AugmentationName="Light"
    Description="Bioluminescent cells within the retina provide coherent illumination of the agent's field of view.|n|nNO UPGRADES"
    LevelValues=1024.00
    AugmentationLocation=6
    MPConflictSlot=12
}
