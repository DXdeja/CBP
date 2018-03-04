class CBPWeaponEMP extends CBPGrenade;

#exec TEXTURE IMPORT FILE=Textures\ui_emp.pcx NAME=ui_emp FLAGS=2 MIPS=Off

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Projectile proj;

	proj = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);

	if (proj != None)
		proj.PlayAnim('Open');
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 4);
}

defaultproperties
{
    LowAmmoWaterMark=2
    GoverningSkill=Class'DeusEx.SkillDemolition'
    EnemyEffective=2
    Concealability=1
    ShotTime=0.30
    reloadTime=0.10
    HitDamage=0
    maxRange=4800
    AccurateRange=2400
    BaseAccuracy=1.00
    bPenetrating=False
    StunDuration=60.00
    bHasMuzzleFlash=False
    bHandToHand=True
    bUseAsDrawnWeapon=False
    AITimeLimit=3.50
    AIFireDelay=5.00
    bNeedToSetMPPickupAmmo=False
    mpReloadTime=0.10
    mpBaseAccuracy=1.00
    mpAccurateRange=2400
    mpMaxRange=2400
    AmmoName=Class'DeusEx.AmmoEMPGrenade'
    ReloadCount=1
    PickupAmmoCount=1
    FireOffset=(X=0.00,Y=10.00,Z=20.00),
    ProjectileClass=Class'CBPEMP'
    shakemag=50.00
    SelectSound=Sound'DeusExSounds.Weapons.EMPGrenadeSelect'
    InventoryGroup=22
    ItemName="Electromagnetic Pulse (EMP) Grenade"
    ItemArticle="an"
    PlayerViewOffset=(X=24.00,Y=-15.00,Z=-19.00),
    PlayerViewMesh=LodMesh'DeusExItems.EMPGrenade'
    PickupViewMesh=LodMesh'DeusExItems.EMPGrenadePickup'
    ThirdPersonMesh=LodMesh'DeusExItems.EMPGrenade3rd'
    Icon=Texture'ui_emp'
    largeIcon=Texture'DeusExUI.Icons.LargeIconEMPGrenade'
    largeIconWidth=31
    largeIconHeight=49
    Description="The EMP grenade creates a localized pulse that will temporarily disable all electronics within its area of effect, including cameras and security grids.|n|n<UNATCO OPS FILE NOTE JR134-VIOLET> While nanotech augmentations are largely unaffected by EMP, experiments have shown that it WILL cause the spontaneous dissipation of stored bioelectric energy. -- Jaime Reyes <END NOTE>"
    beltDescription="EMP GREN"
    Mesh=LodMesh'DeusExItems.EMPGrenadePickup'
    CollisionRadius=3.00
    CollisionHeight=2.43
    Mass=5.00
    Buoyancy=2.00
}
