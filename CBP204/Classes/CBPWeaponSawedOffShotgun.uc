class CBPWeaponSawedOffShotgun extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_shotgun.pcx NAME=ui_shotgun FLAGS=2 MIPS=Off

defaultproperties
{
    LowAmmoWaterMark=4
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    EnviroEffective=1
    Concealability=1
    ShotTime=0.30
    reloadTime=0.50
    HitDamage=9
    maxRange=1200
    AccurateRange=1200
    BaseAccuracy=0.20
    AreaOfEffect=1
    recoilStrength=0.50
    bCanHaveModReloadCount=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'CBPAmmoShell'
    ReloadCount=6
    PickupAmmoCount=4
    bInstantHit=True
    FireOffset=(X=-11.00,Y=4.00,Z=13.00),
    shakemag=50.00
    FireSound=Sound'DeusExSounds.Weapons.SawedOffShotgunFire'
    AltFireSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReload'
    SelectSound=Sound'DeusExSounds.Weapons.SawedOffShotgunSelect'
    InventoryGroup=6
    ItemName="Sawed-off Shotgun"
    PlayerViewOffset=(X=11.00,Y=-4.00,Z=-13.00),
    PlayerViewMesh=LodMesh'DeusExItems.Shotgun'
    PickupViewMesh=LodMesh'DeusExItems.ShotgunPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.Shotgun3rd'
    LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
    Icon=Texture'ui_shotgun'
    largeIcon=Texture'DeusExUI.Icons.LargeIconShotgun'
    largeIconWidth=131
    largeIconHeight=45
    invSlotsX=3
    Description="The sawed-off, pump-action shotgun features a truncated barrel resulting in a wide spread at close range and will accept either buckshot or sabot shells."
    beltDescription="SAWED-OFF"
    Mesh=LodMesh'DeusExItems.ShotgunPickup'
    CollisionRadius=12.00
    CollisionHeight=0.90
    Mass=15.00
}
