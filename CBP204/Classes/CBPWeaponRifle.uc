class CBPWeaponRifle extends CBPWeapon;

#exec TEXTURE IMPORT FILE=Textures\ui_sniper.pcx NAME=ui_sniper FLAGS=2 MIPS=Off

var float	mpNoScopeMult;

var float Z7F;
var float Z80;

final simulated function V04 ()
{
	V0A(self,Z7F,Z80,reloadTime);
}

final simulated function float V5E (float Z81)
{
	return Z81 * (1.00 - Z80);
}

simulated function Tick (float VC5)
{
	if ( IsInState('DownWeapon') || IsInState('SimDownweapon') )
	{
		Z7F += VC5;
	}
	Super.Tick(VC5);
}

simulated function MuzzleFlashLight ()
{
	if ( Pawn(Owner) != None )
	{
		Super.MuzzleFlashLight();
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

function ScopeOn ()
{
	if ( bHasScope &&  !bZoomed && (Owner != None) && Owner.IsA('DeusExPlayer') )
	{
		bZoomed=True;
		if ( IsInState('Reload') )
		{
			ClipCount=0;
		}
		RefreshScopeDisplay(DeusExPlayer(Owner),False,bZoomed);
		if (  !IsInState('V01') )
		{
			GotoState('V01');
		}
	}
}

simulated function RefreshScopeDisplay (DeusExPlayer Z5F, bool Z82, bool Z84)
{
	if ( (Z5F == None) || (Z5F.RootWindow == None) )
	{
		return;
	}
	if ( Z84 )
	{
		DeusExRootWindow(Z5F.RootWindow).scopeView.ActivateView(ScopeFOV,False,Z82);
		if (  !IsInState('V01') )
		{
			GotoState('V01');
		}
	} else {
		DeusExRootWindow(Z5F.RootWindow).scopeView.DeactivateView();
	}
}

simulated state V01
{
	ignores  ClientReFire, ClientFire, AltFire, Fire;

Begin:
	Sleep(0.04);
	if ( Level.NetMode == 3 )
	{
		GotoState('SimIdle');
	} else {
		GotoState('Idle');
	}
}

simulated state V05
{
	ignores  ClientReFire, ClientFire, AltFire, Fire;

Begin:
	ScopeOn();
}

state Reload
{
	function float GetReloadTime ()
	{
		return V5E(Super.GetReloadTime());
	}

	function EndState ()
	{
		Z80=0.00;
		Super.EndState();
	}

}

simulated state SimReload
{
	simulated function float GetSimReloadTime ()
	{
		return V5E(Super.GetSimReloadTime());
	}

	simulated function EndState ()
	{
		Z80=0.00;
		Super.EndState();
	}

Begin:
	if ( bWasInFiring )
	{
		if ( bHasMuzzleFlash )
		{
			EraseMuzzleFlashTexture();
		}
		FinishAnim();
	}
	bInProcess=False;
	bFiring=False;
	bWasZoomed=bZoomed;
	if ( bWasZoomed )
	{
		ScopeOff();
	}
	Owner.PlaySound(CockingSound,SLOT_None,,,1024.00);
	PlayAnim('ReloadBegin');
	FinishAnim();
	LoopAnim('Reload');
	Sleep(GetSimReloadTime());
	Owner.PlaySound(AltFireSound,SLOT_None,,,1024.00);
	ServerDoneReloading();
	PlayAnim('ReloadEnd');
	FinishAnim();
	if ( bWasZoomed )
	{
		GotoState('V05');
	}
	GotoState('SimIdle');
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
    mpNoScopeMult=0.35
    LowAmmoWaterMark=6
    GoverningSkill=Class'DeusEx.SkillWeaponRifle'
    NoiseLevel=2.00
    EnviroEffective=1
    ShotTime=1.50
    reloadTime=1.50
    HitDamage=25
    maxRange=28800
    AccurateRange=28800
    BaseAccuracy=0.00
    bCanHaveScope=True
    bHasScope=True
    bCanHaveLaser=True
    bCanHaveSilencer=True
    recoilStrength=0.40
    bUseWhileCrouched=False
    bCanHaveModBaseAccuracy=True
    bCanHaveModReloadCount=True
    bCanHaveModAccurateRange=True
    bCanHaveModReloadTime=True
    bCanHaveModRecoilStrength=True
    AmmoName=Class'DeusEx.Ammo3006'
    ReloadCount=1
    PickupAmmoCount=6
    bInstantHit=True
    FireOffset=(X=-20.00,Y=2.00,Z=30.00),
    shakemag=50.00
    FireSound=Sound'DeusExSounds.Weapons.RifleFire'
    AltFireSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
    CockingSound=Sound'DeusExSounds.Weapons.RifleReload'
    SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
    InventoryGroup=5
    ItemName="Sniper Rifle"
    PlayerViewOffset=(X=20.00,Y=-2.00,Z=-30.00),
    PlayerViewMesh=LodMesh'DeusExItems.SniperRifle'
    PickupViewMesh=LodMesh'DeusExItems.SniperRiflePickup'
    ThirdPersonMesh=LodMesh'DeusExItems.SniperRifle3rd'
    LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
    Icon=Texture'ui_sniper'
    largeIcon=Texture'DeusExUI.Icons.LargeIconRifle'
    largeIconWidth=159
    largeIconHeight=47
    invSlotsX=4
    Description="The military sniper rifle is the superior tool for the interdiction of long-range targets. When coupled with the proven 30.06 round, a marksman can achieve tight groupings at better than 1 MOA (minute of angle) depending on environmental conditions."
    beltDescription="SNIPER"
    Mesh=LodMesh'DeusExItems.SniperRiflePickup'
    CollisionRadius=26.00
    CollisionHeight=2.00
    Mass=30.00
}
