class CBPAugPower extends CBPAugmentation
	abstract;

defaultproperties
{
    OldAugClass=Class'DeusEx.AugPower'
    ManagerIndex=9
    EnergyRate=0.00
    Icon=Texture'DeusExUI.UserInterface.AugIconPowerRecirc'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconPowerRecirc_Small'
    AugmentationName="Power Recirculator"
    Description="Power consumption for all augmentations is reduced by polyanilene circuits, plugged directly into cell membranes, that allow nanite particles to interconnect electronically without leaving their host cells.|n|nTECH ONE: Power drain of augmentations is reduced slightly.|n|nTECH TWO: Power drain of augmentations is reduced moderately.|n|nTECH THREE: Power drain of augmentations is reduced.|n|nTECH FOUR: Power drain of augmentations is reduced significantly."
    MPInfo="Reduces the cost of other augs.  Automatically used when needed.  Energy Drain: None"
    LevelValues(0)=0.90
    LevelValues(1)=0.80
    LevelValues(2)=0.60
    LevelValues(3)=0.65
    AugmentationLocation=2
    MPConflictSlot=7
}
