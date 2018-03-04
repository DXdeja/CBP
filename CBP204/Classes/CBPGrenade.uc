class CBPGrenade extends DeusExWeapon
	abstract;

var bool bCanDrop;

function PlaceGrenade()
{
	if (AmmoType.AmmoAmount <= 0) 
	{
		Destroy();
		return;
	}
	super.PlaceGrenade();
	if (AmmoType.AmmoAmount <= 0) Destroy();
}

state NormalFire
{
	function AnimEnd()
	{
		if (bAutomatic)
		{
			if ((Pawn(Owner).bFire != 0) && (AmmoType.AmmoAmount > 0))
			{
				if (PlayerPawn(Owner) != None)
					Global.Fire(0);
				else 
					GotoState('FinishFire');
			}
			else 
				GotoState('FinishFire');
		}
		else
		{
			// if we are a thrown weapon and we run out of ammo, destroy the weapon
			if (bHandToHand && (ReloadCount > 0) && (AmmoType.AmmoAmount <= 0))
			{
				// fix disappear bug:
				//Destroy();
			}
		}
	}
}

function PostBeginPlay()
{
   Super.PostBeginPlay();
   bWeaponStay=False;
}

function Fire(float Value)
{
	local float sndVolume;
	local bool bListenClient;

	if (Pawn(Owner) != None)
	{
		if (bNearWall)
		{
			bReadyToFire = False;
			GotoState('NormalFire');
			bPointing = True;
			PlayAnim('Place',, 0.1);
			return;
		}
	}

	bListenClient = (Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient());

	sndVolume = TransientSoundVolume;

	if ( Level.NetMode != NM_Standalone )  // Turn up the sounds a bit in mulitplayer
	{
		sndVolume = TransientSoundVolume * 2.0;
		if ( Owner.IsA('DeusExPlayer') && (DeusExPlayer(Owner).NintendoImmunityTimeLeft > 0.01) || (!bClientReady && (!bListenClient)) )
		{
			DeusExPlayer(Owner).bJustFired = False;
			bReadyToFire = True;
			bPointing = False;
			bFiring = False;
			return;
		}
	}
	// check for surrounding environment
	if ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum))
	{
		if (Region.Zone.bWaterZone)
		{
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNotWorking);
				if (!bHandToHand)
					PlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
			}
			GotoState('Idle');
			return;
		}
	}

	if (bHandToHand)
	{
		if (( Level.NetMode != NM_Standalone ) && !bListenClient )
			bClientReady = False;
		bReadyToFire = False;
		GotoState('NormalFire');
		bPointing=True;
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).PlayFiring();
		PlaySelectiveFiring();
		PlayFiringSound();
	}
}

simulated function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X, Y, Z;
	local DeusExProjectile proj;
	local float mult;
	local float volume, radius;
	local int i, numProj;
	local Pawn aPawn;

	if (AmmoType.AmmoAmount <= 0)
	{
		bDestroyOnFinish = true;
		return none;
	}

	// AugCombat increases our speed (distance) if hand to hand
	mult = 1.0;
	if (bHandToHand && (DeusExPlayer(Owner) != None))
	{
		mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
		if (mult == -1.0)
			mult = 1.0;
		ProjSpeed *= mult;
	}

	// skill also affects our damage
	// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
	mult += -2.0 * GetWeaponSkill();

	// make noise if we are not silenced
	if (!bHasSilencer && !bHandToHand)
	{
		GetAIVolume(volume, radius);
		Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
		Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
		if (!Owner.IsA('PlayerPawn'))
			Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius);
	}

	// should we shoot multiple projectiles in a spread?
	if (AreaOfEffect == AOE_Cone)
		numProj = 3;
	else
		numProj = 1;

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = ComputeProjectileStart(X, Y, Z);

	for (i=0; i<numProj; i++)
	{
      // If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
      if ((i > 0) && (Level.NetMode != NM_Standalone))
         if (currentAccuracy < MinProjSpreadAcc)
            currentAccuracy = MinProjSpreadAcc;
         
		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		AdjustedAim.Yaw += currentAccuracy * (Rand(1024) - 512);
		AdjustedAim.Pitch += currentAccuracy * (Rand(1024) - 512);


		if (( Level.NetMode == NM_Standalone ) || ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient()) )
		{
			proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
			if (proj != None)
			{
				// AugCombat increases our damage as well
				proj.Damage *= mult;

				// send the targetting information to the projectile
				if (bCanTrack && (LockTarget != None) && (LockMode == LOCK_Locked))
				{
					proj.Target = LockTarget;
					proj.bTracking = True;
				}
			}
		}
		else
		{
			if (( Role == ROLE_Authority ) || (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )
			{
				// Do it the old fashioned way if it can track, or if we are a projectile that we could pick up again
				if ( bCanTrack || Self.IsA('WeaponShuriken') || Self.IsA('WeaponMiniCrossbow') || Self.IsA('CBPWeaponLAM') || Self.IsA('CBPWeaponEMP') || Self.IsA('CBPWeaponGasGrenade'))
				{
					if ( Role == ROLE_Authority )
					{
						proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
						if (proj != None)
						{
							// AugCombat increases our damage as well
								proj.Damage *= mult;
							// send the targetting information to the projectile
							if (bCanTrack && (LockTarget != None) && (LockMode == LOCK_Locked))
							{
								proj.Target = LockTarget;
								proj.bTracking = True;
							}
						}
					}
				}
				else
				{
					proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
					if (proj != None)
					{
						proj.RemoteRole = ROLE_None;
						// AugCombat increases our damage as well
						if ( Role == ROLE_Authority )
							proj.Damage *= mult;
						else
							proj.Damage = 0;
					}
					if ( Role == ROLE_Authority )
					{
						for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
						{
							if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(aPawn) != DeusExPlayer(Owner) ))
								DeusExPlayer(aPawn).ClientSpawnProjectile( ProjClass, Owner, Start, AdjustedAim );
						}
					}
				}
			}
		}
	}

	if (proj != none)
	{
		if (ReloadCount > 0) AmmoType.UseAmmo(1);

		if ( AmmoType.AmmoAmount <= 0 )
			bDestroyOnFinish = True;
	}
}

// Become a pickup
// Weapons that carry their ammo with them don't vanish when dropped
function BecomePickup()
{
	Super.BecomePickup();
   if (Level.NetMode != NM_Standalone)
      if (bTossedOut)
         Lifespan = 0.0;
}

defaultproperties
{
    bCanDrop=True
}
