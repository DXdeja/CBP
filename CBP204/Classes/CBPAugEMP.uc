class CBPAugEMP extends CBPAugmentation
	abstract;

defaultproperties
{
    OldAugClass=Class'DeusEx.AugEMP'
    ManagerIndex=5
    EnergyRate=5.00
    Icon=Texture'DeusExUI.UserInterface.AugIconEMP'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconEMP_Small'
    AugmentationName="EMP Shield"
    Description="Nanoscale EMP generators partially protect individual nanites and reduce bioelectrical drain by canceling incoming pulses.|n|nTECH ONE: Damage from EMP attacks is reduced slightly.|n|nTECH TWO: Damage from EMP attacks is reduced moderately.|n|nTECH THREE: Damage from EMP attacks is reduced significantly.|n|nTECH FOUR: An agent is nearly invulnerable to damage from EMP attacks."
    MPInfo="When active, you only take 5% damage from EMP attacks.  Energy Drain: Very Low"
    LevelValues(0)=0.75
    LevelValues(1)=0.50
    LevelValues(2)=0.25
    LevelValues(3)=0.05
    AugmentationLocation=5
    MPConflictSlot=5
}
