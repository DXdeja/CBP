class CBPWeaponAssaultGun extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_assaultgun.pcx NAME=ui_assaultgun FLAGS=2 MIPS=Off

defaultproperties
{
    weapShotTime=0.42
    LowAmmoWaterMark=30
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    EnviroEffective=1
    Concealability=1
    bAutomatic=True
    ShotTime=0.10
    reloadTime=0.50
    HitDamage=9
    maxRange=2400
    AccurateRange=2400
    BaseAccuracy=1.00
    bCanHaveLaser=True
    bCanHaveSilencer=True
    AmmoNames(0)=Class'CBPAmmo762mm'
    AmmoNames(1)=Class'DeusEx.Ammo20mm'
    ProjectileNames(1)=Class'DeusEx.HECannister20mm'
    recoilStrength=0.75
    MinWeaponAcc=0.20
    bCanHaveModBaseAccuracy=True
    bCanHaveModReloadCount=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'CBPAmmo762mm'
    ReloadCount=30
    PickupAmmoCount=30
    bInstantHit=True
    FireOffset=(X=-16.00,Y=5.00,Z=11.50),
    shakemag=200.00
    FireSound=Sound'DeusExSounds.Weapons.AssaultGunFire'
    AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
    SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
    InventoryGroup=4
    ItemName="Assault Rifle"
    ItemArticle="an"
    PlayerViewOffset=(X=16.00,Y=-5.00,Z=-11.50),
    PlayerViewMesh=LodMesh'DeusExItems.AssaultGun'
    PickupViewMesh=LodMesh'DeusExItems.AssaultGunPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.AssaultGun3rd'
    LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
    Icon=Texture'ui_assaultgun'
    largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultGun'
    largeIconWidth=94
    largeIconHeight=65
    invSlotsX=2
    invSlotsY=2
    Description="The 7.62x51mm assault rifle is designed for close-quarters combat, utilizing a shortened barrel and 'bullpup' design for increased maneuverability. An additional underhand 20mm HE launcher increases the rifle's effectiveness against a variety of targets."
    beltDescription="ASSAULT"
    Mesh=LodMesh'DeusExItems.AssaultGunPickup'
    CollisionRadius=15.00
    CollisionHeight=1.10
    Mass=30.00
}
