class CBPWeaponGasGrenade extends CBPGrenade;

#exec TEXTURE IMPORT FILE=Textures\ui_gas.pcx NAME=ui_gas FLAGS=2 MIPS=Off

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 5);
}

defaultproperties
{
    LowAmmoWaterMark=2
    GoverningSkill=Class'DeusEx.SkillDemolition'
    EnemyEffective=1
    EnviroEffective=1
    Concealability=3
    ShotTime=0.30
    reloadTime=0.10
    HitDamage=2
    maxRange=2400
    AccurateRange=2400
    BaseAccuracy=1.00
    bPenetrating=False
    StunDuration=60.00
    bHasMuzzleFlash=False
    bHandToHand=True
    bUseAsDrawnWeapon=False
    AITimeLimit=4.00
    AIFireDelay=20.00
    bNeedToSetMPPickupAmmo=False
    AmmoName=Class'DeusEx.AmmoGasGrenade'
    ReloadCount=1
    PickupAmmoCount=1
    FireOffset=(X=0.00,Y=10.00,Z=20.00),
    ProjectileClass=Class'CBPGasGrenade'
    shakemag=50.00
    SelectSound=Sound'DeusExSounds.Weapons.GasGrenadeSelect'
    InventoryGroup=21
    ItemName="Gas Grenade"
    PlayerViewOffset=(X=30.00,Y=-13.00,Z=-19.00),
    PlayerViewMesh=LodMesh'DeusExItems.GasGrenade'
    PickupViewMesh=LodMesh'DeusExItems.GasGrenadePickup'
    ThirdPersonMesh=LodMesh'DeusExItems.GasGrenade3rd'
    Icon=Texture'ui_gas'
    largeIcon=Texture'DeusExUI.Icons.LargeIconGasGrenade'
    largeIconWidth=23
    largeIconHeight=46
    Description="Upon detonation, the gas grenade releases a large amount of CS (a military-grade 'tear gas' agent) over its area of effect. CS will cause irritation to all exposed mucous membranes leading to temporary blindness and uncontrolled coughing. Like a LAM, gas grenades can be attached to any surface."
    beltDescription="GAS GREN"
    Mesh=LodMesh'DeusExItems.GasGrenadePickup'
    CollisionRadius=2.30
    CollisionHeight=3.30
    Mass=5.00
    Buoyancy=2.00
}
