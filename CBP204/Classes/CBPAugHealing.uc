class CBPAugHealing extends CBPAugmentation
	abstract;

static function ActivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	manager.LastHealTime = dxp.Level.TimeSeconds;
}

static function TickAction(DeusExPlayer dxp, float deltaTime)
{
	local CBPAugmentationManager manager;

	manager = GetManager(dxp);

	if ((manager.LastHealTime + 1.0) < dxp.Level.TimeSeconds)
	{  
		manager.LastHealTime = dxp.Level.TimeSeconds;
		if (dxp.Health < 100)
		{
			dxp.HealPlayer(int(default.LevelValues[3]), False);
			dxp.ClientFlash(0.5, vect(0, 0, 500));
		}
		else
			AugDeactivate(dxp);
	}
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugHealing'
    ManagerIndex=2
    EnergyRate=100.00
    Icon=Texture'DeusExUI.UserInterface.AugIconHealing'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconHealing_Small'
    AugmentationName="Regeneration"
    Description="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time.|n|nTECH ONE: Healing occurs at a normal rate.|n|nTECH TWO: Healing occurs at a slightly faster rate.|n|nTECH THREE: Healing occurs at a moderately faster rate.|n|nTECH FOUR: Healing occurs at a significantly faster rate."
    MPInfo="When active, you heal, but at a rate insufficient for healing in combat.  Energy Drain: High"
    LevelValues(0)=5.00
    LevelValues(1)=15.00
    LevelValues(2)=25.00
    LevelValues(3)=10.00
    AugmentationLocation=2
    MPConflictSlot=4
}
