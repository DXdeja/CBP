class CBPAugDummy extends Augmentation;

var class<CBPAugmentation> AugAffected;

function Deactivate()
{
	AugAffected.static.AugDeactivate(CBPAugmentationManager(Owner).player);
}

defaultproperties
{
    RemoteRole=ROLE_None
}
