class CBPAugEnviro extends CBPAugmentation
	abstract;

defaultproperties
{
    OldAugClass=Class'DeusEx.AugEnviro'
    ManagerIndex=4
    EnergyRate=20.00
    Icon=Texture'DeusExUI.UserInterface.AugIconEnviro'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconEnviro_Small'
    AugmentationName="Environmental Resistance"
    Description="Induced keratin production strengthens all epithelial tissues and reduces the agent's vulnerability to radiation and other toxins.|n|nTECH ONE: Toxic resistance is increased slightly.|n|nTECH TWO: Toxic resistance is increased moderately.|n|nTECH THREE: Toxic resistance is increased significantly.|n|nTECH FOUR: An agent is nearly invulnerable to damage from toxins."
    MPInfo="When active, you only take 10% damage from poison and gas, and poison and gas will not affect your vision.  Energy Drain: Low"
    LevelValues(0)=0.75
    LevelValues(1)=0.50
    LevelValues(2)=0.25
    LevelValues(3)=0.10
    AugmentationLocation=5
    MPConflictSlot=5
}
