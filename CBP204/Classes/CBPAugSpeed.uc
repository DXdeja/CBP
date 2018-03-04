class CBPAugSpeed extends CBPAugmentation
	abstract;

static function ActivateAction(DeusExPlayer dxp)
{
	dxp.GroundSpeed *= default.LevelValues[3];
	dxp.JumpZ *= default.LevelValues[3];
	if (CBPPlayer(dxp) != None)
		CBPPlayer(dxp).UpdateAnimRate(default.LevelValues[3]);
}

static function DeactivateAction(DeusExPlayer dxp)
{
	if (dxp.IsA('CBPPlayer'))
		dxp.GroundSpeed = CBPPlayer(dxp).PawnInfo.Default.GroundSpeed;
	else
		dxp.GroundSpeed = dxp.Default.GroundSpeed;

	dxp.JumpZ = dxp.Default.JumpZ;
	if (CBPPlayer(dxp) != None)
		CBPPlayer(dxp).UpdateAnimRate(-1.0);
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugSpeed'
    ManagerIndex=8
    EnergyRate=180.00
    Icon=Texture'DeusExUI.UserInterface.AugIconSpeedJump'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconSpeedJump_Small'
    AugmentationName="Speed Enhancement"
    Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the speed at which an agent can run and climb, the height they can jump, and reducing the damage they receive from falls.|n|nTECH ONE: Speed and jumping are increased slightly, while falling damage is reduced.|n|nTECH TWO: Speed and jumping are increased moderately, while falling damage is further reduced.|n|nTECH THREE: Speed and jumping are increased significantly, while falling damage is substantially reduced.|n|nTECH FOUR: An agent can run like the wind and leap from the tallest building."
    MPInfo="When active, you move twice as fast and jump twice as high.  Energy Drain: Very High"
    LevelValues(0)=1.20
    LevelValues(1)=1.40
    LevelValues(2)=1.60
    LevelValues(3)=2.00
    AugmentationLocation=2
    MPConflictSlot=7
}
