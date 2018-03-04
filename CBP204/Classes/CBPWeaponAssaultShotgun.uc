class CBPWeaponAssaultShotgun extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_assaultshotgun.pcx NAME=ui_assaultshotgun FLAGS=2 MIPS=Off

defaultproperties
{
    weapShotTime=0.39
    LowAmmoWaterMark=12
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    EnviroEffective=1
    bAutomatic=True
    ShotTime=0.70
    reloadTime=0.50
    HitDamage=5
    maxRange=1800
    AccurateRange=1800
    BaseAccuracy=0.20
    AreaOfEffect=1
    recoilStrength=0.70
    bCanHaveModReloadCount=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'CBPAmmoShell'
    ReloadCount=12
    PickupAmmoCount=12
    bInstantHit=True
    FireOffset=(X=-30.00,Y=10.00,Z=12.00),
    shakemag=50.00
    FireSound=Sound'DeusExSounds.Weapons.AssaultShotgunFire'
    AltFireSound=Sound'DeusExSounds.Weapons.AssaultShotgunReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.AssaultShotgunReload'
    SelectSound=Sound'DeusExSounds.Weapons.AssaultShotgunSelect'
    InventoryGroup=7
    ItemName="Assault Shotgun"
    ItemArticle="an"
    PlayerViewOffset=(X=30.00,Y=-10.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.AssaultShotgun'
    PickupViewMesh=LodMesh'DeusExItems.AssaultShotgunPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.AssaultShotgun3rd'
    LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
    Icon=Texture'ui_assaultshotgun'
    largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultShotgun'
    largeIconWidth=99
    largeIconHeight=55
    invSlotsX=2
    invSlotsY=2
    Description="The assault shotgun (sometimes referred to as a 'street sweeper') combines the best traits of a normal shotgun with a fully automatic feed that can clear an area of hostiles in a matter of seconds. Particularly effective in urban combat, the assault shotgun accepts either buckshot or sabot shells."
    beltDescription="SHOTGUN"
    Mesh=LodMesh'DeusExItems.AssaultShotgunPickup'
    CollisionRadius=15.00
    CollisionHeight=8.00
    Mass=30.00
}
