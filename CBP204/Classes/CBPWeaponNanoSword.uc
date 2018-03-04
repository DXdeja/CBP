class CBPWeaponNanoSword extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_dts.pcx NAME=ui_dts FLAGS=2 MIPS=Off

state DownWeapon
{
	function BeginState()
	{
		Super.BeginState();
		LightType = LT_None;
	}
}

state Idle
{
	function BeginState()
	{
		Super.BeginState();
		LightType = LT_Steady;
	}
}

auto state Pickup
{
	function EndState()
	{
		Super.EndState();
		LightType = LT_None;
	}
}

defaultproperties
{
    weapShotTime=0.58
    LowAmmoWaterMark=0
    GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
    NoiseLevel=0.05
    reloadTime=0.00
    maxRange=150
    AccurateRange=150
    BaseAccuracy=1.00
    AreaOfEffect=1
    bHasMuzzleFlash=False
    bHandToHand=True
    SwingOffset=(X=24.00,Y=0.00,Z=2.00),
    AmmoName=Class'DeusEx.AmmoNone'
    ReloadCount=0
    bInstantHit=True
    FireOffset=(X=-21.00,Y=16.00,Z=27.00),
    shakemag=20.00
    FireSound=Sound'DeusExSounds.Weapons.NanoSwordFire'
    SelectSound=Sound'DeusExSounds.Weapons.NanoSwordSelect'
    Misc1Sound=Sound'DeusExSounds.Weapons.NanoSwordHitFlesh'
    Misc2Sound=Sound'DeusExSounds.Weapons.NanoSwordHitHard'
    Misc3Sound=Sound'DeusExSounds.Weapons.NanoSwordHitSoft'
    InventoryGroup=14
    ItemName="Dragon's Tooth Sword"
    ItemArticle="the"
    PlayerViewOffset=(X=21.00,Y=-16.00,Z=-27.00),
    PlayerViewMesh=LodMesh'DeusExItems.NanoSword'
    PickupViewMesh=LodMesh'DeusExItems.NanoSwordPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.NanoSword3rd'
    LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
    Icon=Texture'ui_dts'
    largeIcon=Texture'DeusExUI.Icons.LargeIconDragonTooth'
    largeIconWidth=205
    largeIconHeight=46
    invSlotsX=4
    Description="The true weapon of a modern warrior, the Dragon's Tooth is not a sword in the traditional sense, but a nanotechnologically constructed blade that is dynamically 'forged' on command into a non-eutactic solid. Nanoscale whetting devices insure that the blade is both unbreakable and lethally sharp."
    beltDescription="DRAGON"
    Mesh=LodMesh'DeusExItems.NanoSwordPickup'
    CollisionRadius=32.00
    CollisionHeight=2.40
    LightType=1
    LightEffect=3
    LightBrightness=224
    LightHue=160
    LightSaturation=64
    LightRadius=4
    Mass=20.00
}
