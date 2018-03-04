class CBPWeaponLAM extends CBPGrenade;

#exec TEXTURE IMPORT FILE=Textures\ui_lam.pcx NAME=ui_lam FLAGS=2 MIPS=Off

var localized String shortName;

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 6);
}

defaultproperties
{
    ShortName="LAM"
    LowAmmoWaterMark=2
    GoverningSkill=Class'DeusEx.SkillDemolition'
    EnviroEffective=4
    Concealability=3
    ShotTime=0.30
    reloadTime=0.10
    HitDamage=50
    maxRange=2400
    AccurateRange=2400
    BaseAccuracy=1.00
    bHasMuzzleFlash=False
    bHandToHand=True
    bUseAsDrawnWeapon=False
    AITimeLimit=3.50
    AIFireDelay=5.00
    bNeedToSetMPPickupAmmo=False
    AmmoName=Class'DeusEx.AmmoLAM'
    ReloadCount=1
    PickupAmmoCount=1
    FireOffset=(X=0.00,Y=10.00,Z=20.00),
    ProjectileClass=Class'CBPLAM'
    shakemag=50.00
    SelectSound=Sound'DeusExSounds.Weapons.LAMSelect'
    InventoryGroup=20
    ItemName="Lightweight Attack Munitions (LAM)"
    PlayerViewOffset=(X=24.00,Y=-15.00,Z=-17.00),
    PlayerViewMesh=LodMesh'DeusExItems.LAM'
    PickupViewMesh=LodMesh'DeusExItems.LAMPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.LAM3rd'
    Icon=Texture'ui_lam'
    largeIcon=Texture'DeusExUI.Icons.LargeIconLAM'
    largeIconWidth=35
    largeIconHeight=45
    Description="A multi-functional explosive with electronic priming system that can either be thrown or attached to any surface with its polyhesive backing and used as a proximity mine.|n|n<UNATCO OPS FILE NOTE SC093-BLUE> Disarming a proximity device should only be attempted with the proper demolitions training. Trust me on this. -- Sam Carter <END NOTE>"
    beltDescription="LAM"
    Mesh=LodMesh'DeusExItems.LAMPickup'
    CollisionRadius=3.80
    CollisionHeight=3.50
    Mass=5.00
    Buoyancy=2.00
}
