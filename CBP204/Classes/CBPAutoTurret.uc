class CBPAutoTurret extends AutoTurret;

function PostPostBeginPlay()
{
	// get rid of Log: DeusExLevelInfo object missing!  Unable to bind Conversations!
}


function bool HasRadarTransAug(Pawn dxp)
{
	if (DeusExPlayer(dxp) == none) return false;
	if (DeusExPlayer(dxp).AugmentationSystem == none) return false;
	if (DeusExPlayer(dxp).AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0) return false;
	else return true;
}

function Actor AcquireMultiplayerTarget()
{
   local Pawn apawn;
	local DeusExPlayer aplayer;
	local Vector dist;
	local Actor noActor;

	if ( bSwitching )
	{
		noActor = None;
		return noActor;
	}

   //DEUS_EX AMSD See if our old target is still valid.
   if ((prevtarget != None) && (prevtarget != safetarget) && (Pawn(prevtarget) != None))
   {
      if (Pawn(prevtarget).AICanSee(self, 1.0, false, false, false, true) > 0)
      {
         if ((DeusExPlayer(prevtarget) == None) && !DeusExPlayer(prevtarget).bHidden )
         {
				dist = DeusExPlayer(prevtarget).Location - gun.Location;
				if (VSize(dist) < maxRange )
				{
					curtarget = prevtarget;
					return curtarget;
				}
         }
         else
         {
            if (!HasRadarTransAug(Pawn(prevtarget)) && !DeusExPlayer(prevtarget).bHidden )
            {
					dist = DeusExPlayer(prevtarget).Location - gun.Location;
					if (VSize(dist) < maxRange )
					{
						curtarget = prevtarget;
						return curtarget;
					}
            }
         }
      }
   }
	// MB Optimized to use pawn list, previous way used foreach VisibleActors
	apawn = gun.Level.PawnList;
	while ( apawn != None )
	{
      if (apawn.bDetectable && !apawn.bIgnore && apawn.IsA('DeusExPlayer'))
      {
			aplayer = DeusExPlayer(apawn);

			dist = aplayer.Location - gun.Location;

			if ( VSize(dist) < maxRange )
			{
				// Only players we can see
				if ( aplayer.FastTrace( aplayer.Location, gun.Location ))
				{
					//only shoot at players who aren't the safetarget.
					//we alreayd know prevtarget not valid.
					if ((aplayer != safeTarget) && (aplayer != prevTarget))
					{
						if (! ( Level.Game.bTeamGame &&	(safeTarget != None) &&	(class'CBPGame'.static.ArePlayersAllied( DeusExPlayer(safeTarget),aplayer)) ) )
						{
							// If the player's RadarTrans aug is off, the turret can see him
							if (!HasRadarTransAug(aplayer) && !aplayer.bHidden )
							{
								curTarget = apawn;
								PlaySound(Sound'TurretLocked', SLOT_Interact, 1.0,, maxRange );
								break;
							}
						}
					}
				}
			}
      }
		apawn = apawn.nextPawn;
	}
   return curtarget;
}

function Tick(float deltaTime)
{
	local Pawn pawn;
	local ScriptedPawn sp;
	local DeusExDecoration deco;
	local float near;
	local Rotator destRot;
	local bool bSwitched;

	Super.Tick(deltaTime);

	bSwitched = False;

	if ( bSwitching )
	{
		UpdateSwitch();
		return;
	}

	// Make sure everything is valid and account for when players leave or switch teams
	if ( !bDisabled && (Level.NetMode != NM_Standalone) )
	{
		if ( safeTarget == None )
		{
			bDisabled = True;
			bComputerReset = False;
		}
		else
		{
			if ( DeusExPlayer(safeTarget) != None )
			{
				if ((Level.Game.bTeamGame) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.team != team))
					bSwitched = True;
				else if ((!Level.Game.bTeamGame) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.PlayerID != team))
					bSwitched = True;
				
				if ( bSwitched )
				{
					bDisabled = True;
					safeTarget = None;
					bComputerReset = False;
				}
			}
		}
	}
	if ( bDisabled && (Level.NetMode != NM_Standalone) )
	{
		team = -1;
		safeTarget = None;
		if ( !bComputerReset )
		{
			gun.ResetComputerAlignment();
			bComputerReset = True;
		}
	}

	if (bConfused)
	{
		confusionTimer += deltaTime;

		// pick a random facing
		if (confusionTimer % 0.25 > 0.2)
		{
			gun.DesiredRotation.Pitch = origRot.Pitch + (pitchLimit / 2 - Rand(pitchLimit));
			gun.DesiredRotation.Yaw = Rand(65535);
		}
		if (confusionTimer > confusionDuration)
		{
			bConfused = False;
			confusionTimer = 0;
			confusionDuration = Default.confusionDuration;
		}
	}

	if (bActive && !bDisabled)
	{
		curTarget = None;

		if ( !bConfused )
		{
			// if we've been EMP'ed, act confused
			if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
			{
				// DEUS_EX AMSD If in multiplayer, get the multiplayer target.

				if (TargetRefreshTime < 0)
					TargetRefreshTime = 0;
         
				TargetRefreshTime = TargetRefreshTime + deltaTime;

				if (TargetRefreshTime >= 0.3)
				{
					TargetRefreshTime = 0;
					curTarget = AcquireMultiplayerTarget();
					if (( curTarget != prevTarget ) && ( curTarget == None ))
							PlaySound(Sound'TurretUnlocked', SLOT_Interact, 1.0,, maxRange );
					prevtarget = curtarget;
				}
				else
				{
					curTarget = prevtarget;
				}
			}
			else
			{
				//
				// Logic table for turrets
				//
				// bTrackPlayersOnly		bTrackPawnsOnly		Should Attack
				// 			T						X				Allies
				//			F						T				Enemies
				//			F						F				Everything
				//
         
				// Attack allies and neutrals
				if (bTrackPlayersOnly || (!bTrackPlayersOnly && !bTrackPawnsOnly))
				{
					foreach gun.VisibleActors(class'Pawn', pawn, maxRange, gun.Location)
					{
						if (pawn.bDetectable && !pawn.bIgnore)
						{
							if (pawn.IsA('DeusExPlayer'))
							{
								// If the player's RadarTrans aug is off, the turret can see him
								if (!HasRadarTransAug(pawn))
								{
									curTarget = pawn;
									break;
								}
							}
							else if (pawn.IsA('ScriptedPawn') && (ScriptedPawn(pawn).GetPawnAllianceType(GetPlayerPawn()) != ALLIANCE_Hostile))
							{
								curTarget = pawn;
								break;
							}
						}
					}
				}
         
				if (!bTrackPlayersOnly)
				{
					// Attack everything
					if (!bTrackPawnsOnly)
					{
						foreach gun.VisibleActors(class'DeusExDecoration', deco, maxRange, gun.Location)
						{
							if (!deco.IsA('ElectronicDevices') && !deco.IsA('AutoTurret') &&
								!deco.bInvincible && deco.bDetectable && !deco.bIgnore)
							{
								curTarget = deco;
								break;
							}
						}
					}
            
					// Attack enemies
					foreach gun.VisibleActors(class'ScriptedPawn', sp, maxRange, gun.Location)
					{
						if (sp.bDetectable && !sp.bIgnore && (sp.GetPawnAllianceType(GetPlayerPawn()) == ALLIANCE_Hostile))
						{
							curTarget = sp;
							break;
						}
					}
				}
			}

			// if we have a target, rotate to face it
			if (curTarget != None)
			{
				destRot = Rotator(curTarget.Location - gun.Location);
				gun.DesiredRotation = destRot;
				near = pitchLimit / 2;
				gun.DesiredRotation.Pitch = FClamp(gun.DesiredRotation.Pitch, origRot.Pitch - near, origRot.Pitch + near);
			}
			else
				gun.DesiredRotation = origRot;
		}
	}
	else
	{
		if ( !bConfused )
			gun.DesiredRotation = origRot;
	}

	near = (Abs(gun.Rotation.Pitch - gun.DesiredRotation.Pitch)) % 65536;
	near += (Abs(gun.Rotation.Yaw - gun.DesiredRotation.Yaw)) % 65536;

	if (bActive && !bDisabled)
	{
		// play an alert sound and light up
		if ((curTarget != None) && (curTarget != LastTarget))
			PlaySound(Sound'Beep6',,,, 1280);

		// if we're aiming close enough to our target
		if (curTarget != None)
		{
			gun.MultiSkins[1] = Texture'RedLightTex';
			if ((near < 4096) && (((Abs(gun.Rotation.Pitch - destRot.Pitch)) % 65536) < 8192))
			{
				if (fireTimer > fireRate)
				{
					Fire();
					fireTimer = 0;
				}
			}
		}
		else
		{
			if (gun.IsAnimating())
				gun.PlayAnim('Still', 10.0, 0.001);

			if (bConfused)
				gun.MultiSkins[1] = Texture'YellowLightTex';
			else
				gun.MultiSkins[1] = Texture'GreenLightTex';
		}

		fireTimer += deltaTime;
		LastTarget = curTarget;
	}
	else
	{
		if (gun.IsAnimating())
			gun.PlayAnim('Still', 10.0, 0.001);
		gun.MultiSkins[1] = None;
	}

	// make noise if we're still moving
	if (near > 64)
	{
		gun.AmbientSound = Sound'AutoTurretMove';
		if (bConfused)
			gun.SoundPitch = 128;
		else
			gun.SoundPitch = 64;
	}
	else
		gun.AmbientSound = None;
}

function SpawnBlood2(Vector HitLocation, Vector HitNormal, Actor hit)
{
	local rotator rot;
	local CBPPlayer hitplayer;

	rot = Rotator(Location - HitLocation);
	rot.Pitch = 0;
	rot.Roll = 0;

	hitplayer = CBPPlayer(hit);
	if (hitplayer == none) return;
	if (!hitplayer.bCanBleed) return;

	class'CBPGame'.static.SEF_SpawnBloodFromWeapon(hitplayer, HitLocation, HitNormal, rot);
}

function Fire()
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Rotator rot;
	local Actor hit;
	//local ShellCasing shell;
	//local Spark spark;
	local Pawn attacker;

	if (!gun.IsAnimating())
		gun.LoopAnim('Fire');

	// CNN - give turrets infinite ammo
//	if (ammoAmount > 0)
//	{
//		ammoAmount--;
		GetAxes(gun.Rotation, X, Y, Z);
		StartTrace = gun.Location;
		EndTrace = StartTrace + gunAccuracy * (FRand()-0.5)*Y*1000 + gunAccuracy * (FRand()-0.5)*Z*1000 ;
		EndTrace += 10000 * X;
		hit = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);

		// spawn some effects
      //if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      //{
      //   //shell = None;
      //}
      //else
      //{
         //shell = Spawn(class'ShellCasing',,, gun.Location);
		class'CBPGame'.static.SEF_SpawnShellCasing(self, gun.Location, gun.Rotation - rot(0,16384,0));
      //}
		//if (shell != None)
		//	shell.Velocity = Vector(gun.Rotation - rot(0,16384,0)) * 100 + VRand() * 30;

		MakeNoise(1.0);
		PlaySound(sound'PistolFire', SLOT_None);
		AISendEvent('LoudNoise', EAITYPE_Audio);

		// muzzle flash
		gun.LightType = LT_Steady;
		gun.MultiSkins[2] = Texture'FlatFXTex34';
		SetTimer(0.1, False);

		// randomly draw a tracer
		if (FRand() < 0.5)
		{
			if (VSize(HitLocation - StartTrace) > 250)
			{
				rot = Rotator(EndTrace - StartTrace);
				//Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);
				//SpawnTracerFromWeapon(StartTrace + 96 * Vector(rot), rot);
				class'CBPGame'.static.SEF_SpawnTracerFromWeapon(self, StartTrace + 96 * Vector(rot), rot);
			}
		}

		if (hit != None)
		{
         //if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
         //{
         //   //spark = None;
         //}
         //else
         //{
			// spawn a little spark and make a ricochet sound if we hit something
			class'CBPGame'.static.SEF_SpawnSpark(self, HitLocation, HitNormal, hit);
         //}

			attacker = None;
			if ((curTarget == hit) && !curTarget.IsA('PlayerPawn'))
				attacker = GetPlayerPawn();
         if (Level.NetMode != NM_Standalone)
            attacker = safetarget;
			if ( hit.IsA('DeusExPlayer') && ( Level.NetMode != NM_Standalone ))
				DeusExPlayer(hit).myTurretKiller = Self;
			hit.TakeDamage(gunDamage, attacker, HitLocation, 1000.0*X, 'AutoShot');

			if (hit.IsA('Pawn') && !hit.IsA('Robot'))
				SpawnBlood2(HitLocation, HitNormal, hit);
			else if ((hit == Level) || hit.IsA('Mover'))
				class'CBPGame'.static.SEF_SpawnTurretEffects(self, HitLocation, HitNormal, hit);
		}
//	}
//	else
//	{
//		PlaySound(sound'DryFire', SLOT_None);
//	}
}

function PreBeginPlay()
{
	local Vector v1, v2;
	local class<AutoTurretGun> gunClass;
	local Rotator rot;

	Super(DeusExDecoration).PreBeginPlay();

	if (gun == none)
	{
		if (IsA('AutoTurretSmall'))
			gunClass = class'AutoTurretGunSmall';
		else
			gunClass = class'AutoTurretGun';

		rot = Rotation;
		rot.Pitch = 0;
		rot.Roll = 0;
		origRot = rot;
		gun = Spawn(gunClass, Self,, Location, rot);
		if (gun != None)
		{
			v1.X = 0;
			v1.Y = 0;
			v1.Z = CollisionHeight + gun.Default.CollisionHeight;
			v2 = v1 >> Rotation;
			v2 += Location;
			gun.SetLocation(v2);
			gun.SetBase(Self);
		}
	}

	// set up the alarm listeners
	AISetEventCallback('Alarm', 'AlarmHeard');

	bInvincible = True;
	bDisabled = !bActive;
}

defaultproperties
{
    maxRange=1024
    gunDamage=20
}
