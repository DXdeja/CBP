class CBPWeaponMiniCrossbow extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_xbow.pcx NAME=ui_xbow FLAGS=2 MIPS=Off

state NormalFire
{
	function BeginState()
	{
		if (ClipCount >= ReloadCount)
			MultiSkins[3] = Texture'PinkMaskTex';

		if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
			MultiSkins[3] = Texture'PinkMaskTex';

		Super.BeginState();
	}
}

function Tick(float deltaTime)
{
	if (MultiSkins[3] != None)
		if ((AmmoType != None) && (AmmoType.AmmoAmount > 0) && (ClipCount < ReloadCount))
			MultiSkins[3] = None;

	Super.Tick(deltaTime);
}

defaultproperties
{
    weapShotTime=1.00
    LowAmmoWaterMark=4
    GoverningSkill=Class'DeusEx.SkillWeaponPistol'
    NoiseLevel=0.05
    EnemyEffective=1
    Concealability=3
    ShotTime=0.80
    reloadTime=0.50
    HitDamage=30
    maxRange=2000
    AccurateRange=2000
    BaseAccuracy=0.10
    bCanHaveScope=True
    ScopeFOV=15
    bCanHaveLaser=True
    bHasSilencer=True
    AmmoNames(0)=Class'DeusEx.AmmoDartPoison'
    AmmoNames(1)=Class'DeusEx.AmmoDart'
    AmmoNames(2)=Class'DeusEx.AmmoDartFlare'
    ProjectileNames(0)=Class'DeusEx.DartPoison'
    ProjectileNames(1)=Class'DeusEx.Dart'
    ProjectileNames(2)=Class'DeusEx.DartFlare'
    StunDuration=10.00
    bHasMuzzleFlash=False
    bCanHaveModBaseAccuracy=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    AmmoName=Class'DeusEx.AmmoDartPoison'
    ReloadCount=6
    PickupAmmoCount=6
    FireOffset=(X=-25.00,Y=8.00,Z=14.00),
    ProjectileClass=Class'DeusEx.DartPoison'
    shakemag=30.00
    FireSound=Sound'DeusExSounds.Weapons.MiniCrossbowFire'
    AltFireSound=Sound'DeusExSounds.Weapons.MiniCrossbowReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.MiniCrossbowReload'
    SelectSound=Sound'DeusExSounds.Weapons.MiniCrossbowSelect'
    InventoryGroup=9
    ItemName="Mini-Crossbow"
    PlayerViewOffset=(X=25.00,Y=-8.00,Z=-14.00),
    PlayerViewMesh=LodMesh'DeusExItems.MiniCrossbow'
    PickupViewMesh=LodMesh'DeusExItems.MiniCrossbowPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.MiniCrossbow3rd'
    Icon=Texture'ui_xbow'
    largeIcon=Texture'DeusExUI.Icons.LargeIconCrossbow'
    largeIconWidth=47
    largeIconHeight=46
    Description="The mini-crossbow was specifically developed for espionage work, and accepts a range of dart types (normal, tranquilizer, or flare) that can be changed depending upon the mission requirements."
    beltDescription="CROSSBOW"
    Mesh=LodMesh'DeusExItems.MiniCrossbowPickup'
    CollisionRadius=8.00
    CollisionHeight=1.00
    Mass=15.00
}
