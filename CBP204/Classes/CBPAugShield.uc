class CBPAugShield extends CBPAugmentation
	abstract;

defaultproperties
{
    OldAugClass=Class'DeusEx.AugShield'
    ManagerIndex=1
    EnergyRate=25.00
    Icon=Texture'DeusExUI.UserInterface.AugIconShield'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconShield_Small'
    AugmentationName="Energy Shield"
    Description="Polyanilene capacitors below the skin absorb heat and electricity, reducing the damage received from flame, electrical, and plasma attacks.|n|nTECH ONE: Damage from energy attacks is reduced slightly.|n|nTECH TWO: Damage from energy attacks is reduced moderately.|n|nTECH THREE: Damage from energy attacks is reduced significantly.|n|nTECH FOUR: An agent is nearly invulnerable to damage from energy attacks."
    MPInfo="When active, you only take 50% damage from flame and plasma attacks.  Energy Drain: Low"
    LevelValues(0)=0.80
    LevelValues(1)=0.60
    LevelValues(2)=0.40
    LevelValues(3)=0.50
    AugmentationLocation=3
    MPConflictSlot=3
}
