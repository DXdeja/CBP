class CBPAugMuscle extends CBPAugmentation
	abstract;

static function DeactivateAction(DeusExPlayer dxp)
{
	if (dxp.CarriedDecoration != None)
		if (!dxp.CanBeLifted(dxp.CarriedDecoration))
			dxp.DropDecoration();
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugMuscle'
    ManagerIndex=15
    EnergyRate=20.00
    Icon=Texture'DeusExUI.UserInterface.AugIconMuscle'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconMuscle_Small'
    AugmentationName="Microfibral Muscle"
    Description="Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects.|n|nTECH ONE: Strength is increased slightly.|n|nTECH TWO: Strength is increased moderately.|n|nTECH THREE: Strength is increased significantly.|n|nTECH FOUR: An agent is inhumanly strong."
    MPInfo="When active, you can pick up large crates.  Energy Drain: Low"
    LevelValues(0)=1.25
    LevelValues(1)=1.50
    LevelValues(2)=1.75
    LevelValues(3)=2.00
    AugmentationLocation=4
    MPConflictSlot=10
}
