class CBPAugRadarTrans extends CBPAugmentation
	abstract;

static function float NewGetEnergyRate()
{
	return default.EnergyRate * default.LevelValues[3];
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugRadarTrans'
    ManagerIndex=3
    EnergyRate=30.00
    Icon=Texture'DeusExUI.UserInterface.AugIconRadarTrans'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconRadarTrans_Small'
    AugmentationName="Radar Transparency"
    Description="Radar-absorbent resin augments epithelial proteins; microprojection units distort agent's visual signature. Provides highly effective concealment from automated detection systems -- bots, cameras, turrets.|n|nTECH ONE: Power drain is normal.|n|nTECH TWO: Power drain is reduced slightly.|n|nTECH THREE: Power drain is reduced moderately.|n|nTECH FOUR: Power drain is reduced significantly."
    MPInfo="When active, you are invisible to electronic devices such as cameras, turrets, and proximity mines.  Energy Drain: Very Low"
    LevelValues(0)=1.00
    LevelValues(1)=0.83
    LevelValues(2)=0.66
    LevelValues(3)=0.50
    AugmentationLocation=2
    MPConflictSlot=4
}
