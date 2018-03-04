class CBPWeaponFlamethrower extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_flamethrower.pcx NAME=ui_flamethrower FLAGS=2 MIPS=Off

var int BurnTime, BurnDamage;

defaultproperties
{
    burnTime=15
    BurnDamage=2
    LowAmmoWaterMark=50
    GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
    EnviroEffective=1
    bAutomatic=True
    ShotTime=0.10
    reloadTime=0.50
    HitDamage=5
    maxRange=320
    AccurateRange=320
    BaseAccuracy=0.90
    bHasMuzzleFlash=False
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    AmmoName=Class'DeusEx.AmmoNapalm'
    ReloadCount=100
    PickupAmmoCount=100
    FireOffset=(X=0.00,Y=10.00,Z=10.00),
    ProjectileClass=Class'DeusEx.Fireball'
    shakemag=10.00
    FireSound=Sound'DeusExSounds.Weapons.FlamethrowerFire'
    AltFireSound=Sound'DeusExSounds.Weapons.FlamethrowerReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.FlamethrowerReload'
    SelectSound=Sound'DeusExSounds.Weapons.FlamethrowerSelect'
    InventoryGroup=15
    ItemName="Flamethrower"
    PlayerViewOffset=(X=20.00,Y=-14.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.Flamethrower'
    PickupViewMesh=LodMesh'DeusExItems.FlamethrowerPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.Flamethrower3rd'
    LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
    Icon=Texture'ui_flamethrower'
    largeIcon=Texture'DeusExUI.Icons.LargeIconFlamethrower'
    largeIconWidth=203
    largeIconHeight=69
    invSlotsX=4
    invSlotsY=2
    Description="A portable flamethrower that discards the old and highly dangerous backpack fuel delivery system in favor of pressurized canisters of napalm. Inexperienced agents will find that a flamethrower can be difficult to maneuver, however."
    beltDescription="FLAMETHWR"
    Mesh=LodMesh'DeusExItems.FlamethrowerPickup'
    CollisionRadius=20.50
    CollisionHeight=4.40
    Mass=40.00
}
