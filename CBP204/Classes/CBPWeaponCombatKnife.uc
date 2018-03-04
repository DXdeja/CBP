class CBPWeaponCombatKnife extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_knife.pcx NAME=ui_knife FLAGS=2 MIPS=Off

defaultproperties
{
    weapShotTime=0.49
    LowAmmoWaterMark=0
    GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
    NoiseLevel=0.05
    EnemyEffective=1
    Concealability=1
    reloadTime=0.00
    HitDamage=20
    maxRange=96
    AccurateRange=96
    BaseAccuracy=1.00
    bHasMuzzleFlash=False
    bHandToHand=True
    bFallbackWeapon=True
    AmmoName=Class'DeusEx.AmmoNone'
    ReloadCount=0
    bInstantHit=True
    FireOffset=(X=-5.00,Y=8.00,Z=14.00),
    shakemag=20.00
    FireSound=Sound'DeusExSounds.Weapons.CombatKnifeFire'
    SelectSound=Sound'DeusExSounds.Weapons.CombatKnifeSelect'
    Misc1Sound=Sound'DeusExSounds.Weapons.CombatKnifeHitFlesh'
    Misc2Sound=Sound'DeusExSounds.Weapons.CombatKnifeHitHard'
    Misc3Sound=Sound'DeusExSounds.Weapons.CombatKnifeHitSoft'
    InventoryGroup=11
    ItemName="Combat Knife"
    PlayerViewOffset=(X=5.00,Y=-8.00,Z=-14.00),
    PlayerViewMesh=LodMesh'DeusExItems.CombatKnife'
    PickupViewMesh=LodMesh'DeusExItems.CombatKnifePickup'
    ThirdPersonMesh=LodMesh'DeusExItems.CombatKnife3rd'
    Icon=Texture'ui_knife'
    largeIcon=Texture'DeusExUI.Icons.LargeIconCombatKnife'
    largeIconWidth=49
    largeIconHeight=45
    Description="An ultra-high carbon stainless steel knife."
    beltDescription="KNIFE"
    Mesh=LodMesh'DeusExItems.CombatKnifePickup'
    CollisionRadius=12.65
    CollisionHeight=0.80
}
