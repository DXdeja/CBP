class CBPWeapon extends DeusExWeapon
	abstract;

var bool bCanDrop;

var float lastShotTime;
var float ffrtolerance;
var float weapShotTime;

function Fire(float Value)
{
	local float diff;
	diff = Level.TimeSeconds - lastShotTime;
	diff -= weapShotTime - ffrtolerance;
	if (diff < 0.0)
	{
		//log("too fast fire: " $ self);
		return;
	}
	lastShotTime = Level.TimeSeconds;
	
	super.Fire(value);
}

function SpawnBlood(Vector HitLocation, Vector HitNormal);

simulated function PlayFiringSound()
{
	if (bHasSilencer)
		PlaySimSound( Sound'StealthPistolFire', SLOT_None, TransientSoundVolume, 2048 );
	else
	{
		// The sniper rifle sound is heard to it's range in multiplayer
		if ( ( Level.NetMode != NM_Standalone ) &&  Self.IsA('CBPWeaponRifle') )	
			PlaySimSound( FireSound, SLOT_None, TransientSoundVolume, class'CBPWeaponRifle'.Default.MaxRange );
		else
			PlaySimSound( FireSound, SLOT_None, TransientSoundVolume, 2048 );
	}
}

function bool HandlePickupQuery(Inventory Item)
{
	local DeusExPlayer player;
	local bool bResult;
	local class<Ammo> defAmmoClass;
	local Ammo defAmmo;
	
	player = DeusExPlayer(Owner);

	if (Item.Class == Class)
	{
		if (!( (Weapon(item).bWeaponStay) && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut)))
		{
			if (AmmoType != None)
			{
				// Add to default ammo only
				if (AmmoNames[0] == None)
					defAmmoClass = AmmoName;
				else
					defAmmoClass = AmmoNames[0];

				defAmmo = Ammo(player.FindInventoryType(defAmmoClass));
				defAmmo.AddAmmo(Weapon(Item).PickupAmmoCount);

				if (Level.NetMode != NM_Standalone)
				{
					if ((player != None ) && ( player.InHand != None))
					{
						if ( DeusExWeapon(item).class == DeusExWeapon(player.InHand).class )
							ReadyToFire();
					}
				}
			}
		}
	}

	bResult = Super(Weapon).HandlePickupQuery(Item);

	return bResult;
}

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local float        mult;
	local name         damageType;
	local DeusExPlayer dxPlayer;

	if (Other != None)
	{
		// AugCombat increases our damage if hand to hand
		mult = 1.0;
		if (bHandToHand && (DeusExPlayer(Owner) != None))
		{
			if (DeusExPlayer(Owner).AugmentationSystem != none)
				mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			if (mult == -1.0)
				mult = 1.0;
		}

		// skill also affects our damage
		// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
		mult += -2.0 * GetWeaponSkill();

		// Determine damage type
		damageType = WeaponDamageType();

		if ((Other == Level) || (Other.IsA('Mover')))
		{
			if ( Role == ROLE_Authority )
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, damageType);

			SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);
		}
		else if ((Other != self) && (Other != Owner))
		{
			if ( Role == ROLE_Authority )
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, damageType);
			if (bHandToHand)
				SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);

			if (Role == ROLE_Authority && CBPPlayer(Other) != none)
			{
				if (bPenetrating && CBPPlayer(Other).bCanBleed)
					class'CBPGame'.static.SEF_SpawnBloodFromWeapon(Other, HitLocation, HitNormal);
			}
		}
	}
}

simulated function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Rotator rot;
	local actor Other;
	local float dist, alpha, degrade;
	local int i, numSlugs;

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = ComputeProjectileStart(X, Y, Z);
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);

	// check to see if we are a shotgun-type weapon
	if (AreaOfEffect == AOE_Cone)
		numSlugs = 5;
	else
		numSlugs = 1;

	// if there is a scope, but the player isn't using it, decrease the accuracy
	// so there is an advantage to using the scope
	if (bHasScope && !bZoomed)
		Accuracy += 0.2;
	// if the laser sight is on, make this shot dead on
	// also, if the scope is on, zero the accuracy so the shake makes the shot inaccurate
	else if (bLasing || bZoomed)
		Accuracy = 0.0;


	for (i=0; i<numSlugs; i++)
	{
      // If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
      if ((i > 0) && (Level.NetMode != NM_Standalone) && !(bHandToHand))
         if (Accuracy < MinSpreadAcc)
            Accuracy = MinSpreadAcc;

      // Let handtohand weapons have a better swing
      if ((bHandToHand) && (NumSlugs > 1) && (Level.NetMode != NM_Standalone))
      {
         StartTrace = ComputeProjectileStart(X,Y,Z);
         StartTrace = StartTrace + (numSlugs/2 - i) * SwingOffset;
      }

      EndTrace = StartTrace + Accuracy * (FRand()-0.5)*Y*1000 + Accuracy * (FRand()-0.5)*Z*1000 ;
      EndTrace += (FMax(1024.0, MaxRange) * vector(AdjustedAim));
      
      Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

		// randomly draw a tracer for relevant ammo types
		// don't draw tracers if we're zoomed in with a scope - looks stupid
      // DEUS_EX AMSD In multiplayer, draw tracers all the time.
		if ( ((Level.NetMode == NM_Standalone) && (!bZoomed && (numSlugs == 1) && (FRand() < 0.5))) ||
           ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority) && (numSlugs == 1)) )
		{
			if ((AmmoName == Class'CBPAmmo10mm') || (AmmoName == Class'Ammo3006') ||
				(AmmoName == Class'CBPAmmo762mm'))
			{
				if (VSize(HitLocation - StartTrace) > 250)
				{
					rot = Rotator(EndTrace - StartTrace);
               if ((Level.NetMode != NM_Standalone) && (Self.IsA('CBPWeaponRifle')))
                  Spawn(class'SniperTracer',,, StartTrace + 96 * Vector(rot), rot);
               else
                  	if (Role == ROLE_Authority && CBPPlayer(Owner) != none)
						class'CBPGame'.static.SEF_SpawnTracerFromWeapon(Owner, StartTrace + 96 * Vector(rot), rot);
				}
			}
		}

		// check our range
		dist = Abs(VSize(HitLocation - Owner.Location));

		if (dist <= AccurateRange)		// we hit just fine
			ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
		else if (dist <= MaxRange)
		{
			// simulate gravity by lowering the bullet's hit point
			// based on the owner's distance from the ground
			alpha = (dist - AccurateRange) / (MaxRange - AccurateRange);
			degrade = 0.5 * Square(alpha);
			HitLocation.Z += degrade * (Owner.Location.Z - Owner.CollisionHeight);
			ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
		}
	}

	// otherwise we don't hit the target at all
}

//
// ClientFire - Attempts to play the firing anim, sounds, and trace fire hits for instant weapons immediately
//				on the client.  The server may have a different interpretation of what actually happen, but this at least
//				cuts down on preceived lag.
//
simulated function bool ClientFire( float value )
{
	local bool bWaitOnAnim;
	local vector shake;

	// fix bug related to firing when having no weapon in hand
	if (DeusExPlayer(Owner) != none && DeusExPlayer(Owner).inHand != self) return false;

	// check for surrounding environment
	if ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum))
	{
		if (Region.Zone.bWaterZone)
		{
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNotWorking);
				if (!bHandToHand)
					PlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );
			}
			return false;
		}
	}

	if ( !bLooping ) // Wait on animations when not looping
	{
		bWaitOnAnim = ( IsAnimating() && ((AnimSequence == 'Select') || (AnimSequence == 'Shoot') || (AnimSequence == 'ReloadBegin') || (AnimSequence == 'Reload') || (AnimSequence == 'ReloadEnd') || (AnimSequence == 'Down')));
	}
	else
	{
		bWaitOnAnim = False;
		bLooping = False;
	}

	if ( (Owner.IsA('DeusExPlayer') && (DeusExPlayer(Owner).NintendoImmunityTimeLeft > 0.01)) ||
		  (!bClientReadyToFire) || bInProcess || bWaitOnAnim )
	{
		DeusExPlayer(Owner).bJustFired = False;
		bPointing = False;
		bFiring = False;
		return false;
	}

	if ( !Self.IsA('WeaponFlamethrower') )
		ServerForceFire();

	if (bHandToHand)
	{
		SimAmmoAmount = AmmoType.AmmoAmount - 1;

		bClientReadyToFire = False;
		bInProcess = True;
		GotoState('ClientFiring');
		bPointing = True;
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).PlayFiring();
		PlaySelectiveFiring();
		PlayFiringSound();
	}
	else if ((ClipCount < ReloadCount) || (ReloadCount == 0))
	{
		if ((ReloadCount == 0) || (AmmoType.AmmoAmount > 0))
		{
			SimClipCount = ClipCount + 1;

			if ( AmmoType != None )
				AmmoType.SimUseAmmo();

			bFiring = True;
			bPointing = True;
			bClientReadyToFire = False;
			bInProcess = True;
			GotoState('ClientFiring');
			if ( PlayerPawn(Owner) != None )
			{
				shake.X = 0.0;
				shake.Y = 100.0 * (ShakeTime*0.5);
				shake.Z = 100.0 * -(currentAccuracy * ShakeVert);
				PlayerPawn(Owner).ClientShake( shake );
				PlayerPawn(Owner).PlayFiring();
			}
			// Don't play firing anim for 20mm
			if ( Ammo20mm(AmmoType) == None )
				PlaySelectiveFiring();
			PlayFiringSound();

			if ( bInstantHit &&  ( Ammo20mm(AmmoType) == None ))
				TraceFire(currentAccuracy);
			else
			{
				if ( !bFlameOn && Self.IsA('WeaponFlamethrower'))
				{
					bFlameOn = True;
					StartFlame();
				}
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
			}
		}
		else
		{
			if ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).bAutoReload )
			{
				if ( MustReload() && CanReload() )
				{
					bClientReadyToFire = False;
					bInProcess = False;
					if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();

					ReloadAmmo();
				}
			}
			PlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );		// play dry fire sound
		}
	}
	else
	{
		if ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).bAutoReload )
		{
			if ( MustReload() && CanReload() )
			{
				bClientReadyToFire = False;
				bInProcess = False;
				if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
					CycleAmmo();
				ReloadAmmo();
			}
		}
		PlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );		// play dry fire sound
	}
	return true;
}

state NormalFire
{
	function float GetShotTime()
	{
		local float mult, sTime, am;

		// AugCombat decreases shot time
		mult = 1.0;
		if (bHandToHand && DeusExPlayer(Owner) != None)
		{
			am = -1.0;
			if (DeusExPlayer(Owner).AugmentationSystem != none)
				am = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			mult = 1.0 / am;
			if (mult == -1.0)
				mult = 1.0;
		}
		sTime = ShotTime * mult;
		return (sTime);
	}
}

simulated state ClientFiring
{
	simulated function float GetSimShotTime()
	{
		local float mult, sTime, am;

		// AugCombat decreases shot time
		mult = 1.0;
		if (bHandToHand && DeusExPlayer(Owner) != None)
		{
			am = -1.0;
			if (DeusExPlayer(Owner).AugmentationSystem != none)
				am = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			mult = 1.0 / am;
			if (mult == -1.0)
				mult = 1.0;
		}
		sTime = ShotTime * mult;
		return (sTime);
	}
}

static simulated function V0A (DeusExWeapon Z47, out float Z7F, out float Z80, float S0D)
{
	if ( Z47.MustReload() && Z47.CanReload() )
	{
		Z80=FClamp(Z7F * 0.43 / FMax(S0D + Z47.GetWeaponSkill() * S0D,0.10),0.00,1.00);
		Z7F=0.00;
		if ( Z80 == 1.00 )
		{
			Z47.ClipCount=0;
			Z47.ServerDoneReloading();
			Z80=0.00;
		}
	} else {
		Z80=0.00;
	}
	Z7F=0.00;
}

static function V0C (DeusExWeapon Z47)
{
	Z47.ScopeOff();
	Z47.LaserOff();
	if ( (Z47.Level.NetMode == 1) || (Z47.Level.NetMode == 2) && (DeusExPlayer(Z47.Owner) != None) &&  !DeusExPlayer(Z47.Owner).PlayerIsListenClient() )
	{
		Z47.ClientDownWeapon();
	}
	Z47.TweenDown();
}

static function V0B (DeusExWeapon Z47)
{
	if ( Z47.ReloadCount == 0 )
	{
		if ( Pawn(Z47.Owner) != None )
		{
			Pawn(Z47.Owner).ClientMessage(Z47.msgCannotBeReloaded);
		}
	} else {
		if (  !Z47.IsInState('Reload') )
		{
			Z47.ClipCount=Z47.ReloadCount;
			Z47.TweenAnim('Still',0.10);
			Z47.GotoState('Reload');
		}
	}
}

defaultproperties
{
    bCanDrop=True
    ffrtolerance=0.01
    weapShotTime=0.10
}
