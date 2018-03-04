class CBPBioelectricCell extends CBPPickup;

#exec TEXTURE IMPORT FILE=Textures\ui_biocell.pcx NAME=ui_biocell FLAGS=2 MIPS=Off

var int rechargeAmount;

var localized String msgRecharged;
var localized String RechargesLabel;

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
			player.ClientMessage(Sprintf(msgRecharged, rechargeAmount));

			player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

			player.Energy += rechargeAmount;
			if (player.Energy > player.EnergyMax)
				player.Energy = player.EnergyMax;
		}

		UseOnce();
	}
Begin:
}

function bool UpdateInfo(Object winObject)
{
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 0);
}

defaultproperties
{
    rechargeAmount=50
    msgRecharged="Recharged %d points"
    RechargesLabel="Recharges %d Energy Units"
    maxCopies=5
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Bioelectric Cell"
    PlayerViewOffset=(X=30.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.BioCell'
    PickupViewMesh=LodMesh'DeusExItems.BioCell'
    ThirdPersonMesh=LodMesh'DeusExItems.BioCell'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'ui_biocell'
    largeIcon=Texture'DeusExUI.Icons.LargeIconBioCell'
    largeIconWidth=44
    largeIconHeight=43
    Description="A bioelectric cell provides efficient storage of energy in a form that can be utilized by a number of different devices.|n|n<UNATCO OPS FILE NOTE JR289-VIOLET> Augmented agents have been equipped with an interface that allows them to transparently absorb energy from bioelectric cells. -- Jaime Reyes <END NOTE>"
    beltDescription="BIOCELL"
    Mesh=LodMesh'DeusExItems.BioCell'
    CollisionRadius=4.70
    CollisionHeight=0.93
    Mass=5.00
    Buoyancy=4.00
}
