class CBPAugCloak extends CBPAugmentation
	abstract;

static function ActivateAction(DeusExPlayer dxp)
{
	if ((dxp.inHand != None) && (dxp.inHand.IsA('DeusExWeapon')))
		dxp.ServerConditionalNotifyMsg(dxp.MPMSG_NoCloakWeapon);
	dxp.PlaySound(Sound'CloakUp', SLOT_Interact, 0.85, ,768,1.0);
}

static function DeactivateAction(DeusExPlayer dxp)
{
	dxp.PlaySound(Sound'CloakDown', SLOT_Interact, 0.85, ,768,1.0);
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugCloak'
    ManagerIndex=11
    EnergyRate=40.00
    Icon=Texture'DeusExUI.UserInterface.AugIconCloak'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconCloak_Small'
    AugmentationName="Cloak"
    LevelValues(0)=1.00
    LevelValues(1)=0.83
    LevelValues(2)=0.66
    LevelValues(3)=1.00
    AugmentationLocation=1
    MPConflictSlot=8
}
