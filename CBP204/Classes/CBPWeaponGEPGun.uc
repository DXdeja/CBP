class CBPWeaponGEPGun extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_gep.pcx NAME=ui_gep FLAGS=2 MIPS=Off

var localized String shortName;

var float Z7F;
var float Z80;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// don't let NPC geps lock on to targets
	if ((Owner != None) && !Owner.IsA('DeusExPlayer'))
		bCanTrack = False;
}

final simulated function V04 ()
{
	V0A(self,Z7F,Z80,1.60);
}

simulated function Tick (float VC5)
{
	if ( IsInState('DownWeapon') || IsInState('SimDownweapon') )
	{
		Z7F += VC5;
	}
	Super.Tick(VC5);
}

function CycleAmmo ()
{
	if (  !IsInState('Reload') )
	{
		Super.CycleAmmo();
	}
}

simulated function ClientReload ()
{
	if (  !IsInState('SimReload') )
	{
		Super.ClientReload();
	}
}

function ReloadAmmo ()
{
	V0B(self);
}

simulated state SimDownweapon
{
	simulated function BeginState ()
	{
		RefreshScopeDisplay(DeusExPlayer(Owner),False,False);
		Super.BeginState();
	}

}

state DownWeapon
{
	ignores  AltFire, Fire;

Begin:
	V0C(self);
	FinishAnim();
	bOnlyOwnerSee=False;
	if ( Pawn(Owner) != None )
	{
		Pawn(Owner).ChangedWeapon();
	}
}

state Active
{
	function BeginState ()
	{
		V04();
		Super.BeginState();
	}

}

simulated state SimActive
{
	simulated function BeginState ()
	{
		V04();
		SimClipCount=ClipCount;
	}

}

defaultproperties
{
    ShortName="GEP Gun"
    LowAmmoWaterMark=4
    GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
    NoiseLevel=2.00
    EnviroEffective=1
    ShotTime=2.00
    reloadTime=2.00
    HitDamage=40
    maxRange=14400
    AccurateRange=14400
    BaseAccuracy=0.00
    bCanHaveScope=True
    bHasScope=True
    bCanTrack=True
    LockTime=2.00
    LockedSound=Sound'DeusExSounds.Weapons.GEPGunLock'
    TrackingSound=Sound'DeusExSounds.Weapons.GEPGunTrack'
    AmmoNames(0)=Class'DeusEx.AmmoRocket'
    AmmoNames(1)=Class'DeusEx.AmmoRocketWP'
    ProjectileNames(0)=Class'CBPRocket'
    ProjectileNames(1)=Class'DeusEx.RocketWP'
    bHasMuzzleFlash=False
    recoilStrength=1.00
    bUseWhileCrouched=False
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    AmmoName=Class'DeusEx.AmmoRocket'
    ReloadCount=1
    PickupAmmoCount=4
    FireOffset=(X=-46.00,Y=22.00,Z=10.00),
    ProjectileClass=Class'CBPRocket'
    shakemag=500.00
    FireSound=Sound'DeusExSounds.Weapons.GEPGunFire'
    CockingSound=Sound'DeusExSounds.Weapons.GEPGunReload'
    SelectSound=Sound'DeusExSounds.Weapons.GEPGunSelect'
    InventoryGroup=17
    ItemName="Guided Explosive Projectile (GEP) Gun"
    PlayerViewOffset=(X=46.00,Y=-22.00,Z=-10.00),
    PlayerViewMesh=LodMesh'DeusExItems.GEPGun'
    PickupViewMesh=LodMesh'DeusExItems.GEPGunPickup'
    ThirdPersonMesh=LodMesh'DeusExItems.GEPGun3rd'
    LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
    Icon=Texture'ui_gep'
    largeIcon=Texture'DeusExUI.Icons.LargeIconGEPGun'
    largeIconWidth=203
    largeIconHeight=77
    invSlotsX=4
    invSlotsY=2
    Description="The GEP gun is a relatively recent invention in the field of armaments: a portable, shoulder-mounted launcher that can fire rockets and laser guide them to their target with pinpoint accuracy. While suitable for high-threat combat situations, it can be bulky for those agents who have not grown familiar with it."
    beltDescription="GEP GUN"
    Mesh=LodMesh'DeusExItems.GEPGunPickup'
    CollisionRadius=27.00
    CollisionHeight=6.60
    Mass=50.00
}
