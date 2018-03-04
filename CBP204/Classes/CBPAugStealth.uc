class CBPAugStealth extends CBPAugmentation
	abstract;

static function ActivateAction(DeusExPlayer dxp)
{
	dxp.RunSilentValue = 0.0;
}

static function DeactivateAction(DeusExPlayer dxp)
{
	dxp.RunSilentValue = 1.0;
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugStealth'
    ManagerIndex=14
    EnergyRate=20.00
    Icon=Texture'DeusExUI.UserInterface.AugIconRunSilent'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconRunSilent_Small'
    AugmentationName="Run Silent"
    Description="The necessary muscle movements for complete silence when walking or running are determined continuously with reactive kinematics equations produced by embedded nanocomputers.|n|nTECH ONE: Sound made while moving is reduced slightly.|n|nTECH TWO: Sound made while moving is reduced moderately.|n|nTECH THREE: Sound made while moving is reduced significantly.|n|nTECH FOUR: An agent is completely silent."
    MPInfo="When active, you do not make footstep sounds.  Energy Drain: Low"
    LevelValues(0)=0.75
    LevelValues(1)=0.50
    LevelValues(2)=0.25
    AugmentationLocation=4
    MPConflictSlot=10
}
