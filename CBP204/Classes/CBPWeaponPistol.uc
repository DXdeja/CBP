class CBPWeaponPistol extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_pistol.pcx NAME=ui_pistol FLAGS=2 MIPS=Off

simulated function MuzzleFlashLight ()
{
	if ( Pawn(Owner) != None )
	{
		Super.MuzzleFlashLight();
	}
}

defaultproperties
{
    weapShotTime=0.58
    LowAmmoWaterMark=6
    GoverningSkill=Class'DeusEx.SkillWeaponPistol'
    EnviroEffective=1
    Concealability=1
    ShotTime=0.60
    reloadTime=2.00
    HitDamage=20
    maxRange=1200
    AccurateRange=1200
    BaseAccuracy=0.20
    bCanHaveScope=True
    ScopeFOV=25
    bCanHaveLaser=True
    recoilStrength=0.30
    mpPickupAmmoCount=9
    bCanHaveModBaseAccuracy=True
    bCanHaveModReloadCount=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'CBPAmmo10mm'
    ReloadCount=9
    PickupAmmoCount=9
    bInstantHit=True
    FireOffset=(X=-22.00,Y=10.00,Z=14.00),
    shakemag=50.00
    FireSound=Sound'DeusExSounds.Weapons.PistolFire'
    CockingSound=Sound'DeusExSounds.Weapons.PistolReload'
    SelectSound=Sound'DeusExSounds.Weapons.PistolSelect'
    InventoryGroup=2
    ItemName="Pistol"
    PlayerViewOffset=(X=22.00,Y=-10.00,Z=-14.00),
    PlayerViewMesh=LodMesh'DeusExItems.Glock'
    PickupViewMesh=LodMesh'DeusExItems.GlockPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.Glock3rd'
    Icon=Texture'ui_pistol'
    largeIcon=Texture'DeusExUI.Icons.LargeIconPistol'
    largeIconWidth=46
    largeIconHeight=28
    Description="A standard 10mm pistol."
    beltDescription="PISTOL"
    Mesh=LodMesh'DeusExItems.GlockPickup'
    CollisionRadius=7.00
    CollisionHeight=1.00
}
