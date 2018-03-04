class CBPMedkit extends CBPPickup;

#exec TEXTURE IMPORT FILE=Textures\ui_medkit.pcx NAME=ui_medkit FLAGS=2 MIPS=Off

var int healAmount;
var bool bNoPrintMustBeUsed;

var localized string MustBeUsedOn;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player;

		Super.BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
		{
			player.HealPlayer(healAmount, True);

			// Medkits kill all status effects when used in multiplayer
			player.StopPoison();
			player.ExtinguishFire();
			player.drugEffectTimer = 0;
		}

		UseOnce();
	}
Begin:
}

function bool UpdateInfo(Object winObject)
{
}

function NoPrintMustBeUsed()
{
	bNoPrintMustBeUsed = True;
}

function float GetHealAmount(int bodyPart, optional float pointsToHeal)
{
	local float amt;

	if (pointsToHeal == 0)
		pointsToHeal = healAmount;

	return pointsToHeal;
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 9);
}

defaultproperties
{
    healAmount=30
    MustBeUsedOn="Use to heal critical body parts, or use on character screen to direct healing at a certain body part."
    maxCopies=5
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Medkit"
    PlayerViewOffset=(X=30.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.MedKit'
    PickupViewMesh=LodMesh'DeusExItems.MedKit'
    ThirdPersonMesh=LodMesh'DeusExItems.MedKit3rd'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'ui_medkit'
    largeIcon=Texture'DeusExUI.Icons.LargeIconMedKit'
    largeIconWidth=39
    largeIconHeight=46
    Description="A first-aid kit.|n|n<UNATCO OPS FILE NOTE JR095-VIOLET> The nanomachines of an augmented agent will automatically metabolize the contents of a medkit to efficiently heal damaged areas. An agent with medical training could greatly expedite this process. -- Jaime Reyes <END NOTE>"
    beltDescription="MEDKIT"
    Mesh=LodMesh'DeusExItems.MedKit'
    CollisionRadius=7.50
    CollisionHeight=1.00
    Mass=10.00
    Buoyancy=8.00
}
