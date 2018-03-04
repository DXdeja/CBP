class CBPWeaponStealthPistol extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_stealthpistol.pcx NAME=ui_stealthpistol FLAGS=2 MIPS=Off

defaultproperties
{
    weapShotTime=0.33
    GoverningSkill=Class'DeusEx.SkillWeaponPistol'
    NoiseLevel=0.01
    EnviroEffective=1
    Concealability=3
    ShotTime=0.15
    reloadTime=1.50
    HitDamage=12
    maxRange=1200
    AccurateRange=1200
    BaseAccuracy=0.20
    bCanHaveScope=True
    ScopeFOV=25
    bCanHaveLaser=True
    recoilStrength=0.10
    bCanHaveModBaseAccuracy=True
    bCanHaveModReloadCount=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    AmmoName=Class'CBPAmmo10mm'
    ReloadCount=12
    PickupAmmoCount=10
    bInstantHit=True
    FireOffset=(X=-24.00,Y=10.00,Z=14.00),
    shakemag=50.00
    FireSound=Sound'DeusExSounds.Weapons.StealthPistolFire'
    AltFireSound=Sound'DeusExSounds.Weapons.StealthPistolReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.StealthPistolReload'
    SelectSound=Sound'DeusExSounds.Weapons.StealthPistolSelect'
    InventoryGroup=3
    ItemName="Stealth Pistol"
    PlayerViewOffset=(X=24.00,Y=-10.00,Z=-14.00),
    PlayerViewMesh=LodMesh'DeusExItems.StealthPistol'
    PickupViewMesh=LodMesh'DeusExItems.StealthPistolPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.StealthPistol3rd'
    Icon=Texture'ui_stealthpistol'
    largeIcon=Texture'DeusExUI.Icons.LargeIconStealthPistol'
    largeIconWidth=47
    largeIconHeight=37
    Description="The stealth pistol is a variant of the standard 10mm pistol with a larger clip and integrated silencer designed for wet work at very close ranges."
    beltDescription="STEALTH"
    Mesh=LodMesh'DeusExItems.StealthPistolPickup'
    CollisionRadius=8.00
    CollisionHeight=0.80
}
