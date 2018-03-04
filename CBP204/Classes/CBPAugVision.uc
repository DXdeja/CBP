class CBPAugVision extends CBPAugmentation
	abstract;

static function ActivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	local float augval;
	manager = GetManager(dxp);
	augval = manager.GetAugLevelValue(default.Class);
	manager.SetVisionAugStatus(augval, true);
	dxp.RelevantRadius = augval;
}

static function DeactivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	manager.SetVisionAugStatus(0, false);
	dxp.RelevantRadius = 0;
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugVision'
    ManagerIndex=10
    Icon=Texture'DeusExUI.UserInterface.AugIconVision'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconVision_Small'
    AugmentationName="Vision Enhancement"
    Description="By bleaching selected rod photoreceptors and saturating them with metarhodopsin XII, the 'nightvision' present in most nocturnal animals can be duplicated. Subsequent upgrades and modifications add infravision and sonar-resonance imaging that effectively allows an agent to see through walls.|n|nTECH ONE: Nightvision.|n|nTECH TWO: Infravision.|n|nTECH THREE: Close range sonar imaging.|n|nTECH FOUR: Long range sonar imaging."
    MPInfo="When active, you can see enemy players in the dark from any distance, and for short distances you can see through walls and see cloaked enemies.  Energy Drain: Moderate"
    LevelValues(2)=320.00
    LevelValues(3)=800.00
    AugmentationLocation=1
    MPConflictSlot=8
}
