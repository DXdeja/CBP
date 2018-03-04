class CBPThrownProjectile extends ThrownProjectile;

var class<Cloud> CloudClass;
var bool bSpawnClouds;

auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local ShockRing ring;
		local DeusExPlayer player;
		local float dist;

		// flash the screen white based on how far away the explosion is
		//		player = DeusExPlayer(GetPlayerPawn());
		//		MBCODE: Reference projectile owner to get player
		//		because sever fails to get it the old way
		player = DeusExPlayer(Owner);

		dist = Abs(VSize(player.Location - Location));

		// if you are at the same location, blind the player
		if (dist ~= 0)
			dist = 10.0;
		else
			dist = 2.0 * FClamp(blastRadius/dist, 0.0, 4.0);

		if (damageType == 'EMP')
			player.ClientFlash(dist, vect(0,200,1000));
		else if (damageType == 'TearGas')
			player.ClientFlash(dist, vect(0,1000,100));
		else
			player.ClientFlash(dist, vect(1000,1000,900));

      //DEUS_EX AMSD Only do visual effects if client or if destroyed via damage (since the client can't detect that)
      if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority) || bDamaged)
      {
         SpawnEffects(HitLocation, HitNormal, None);
         DrawExplosionEffects(HitLocation, HitNormal);
      }

		if (bSpawnClouds && (Role==ROLE_Authority))
			SpawnTearGas();

		PlayImpactSound();

		if ( AISoundLevel > 0.0 )
			AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, AISoundLevel*blastRadius*16);

		GotoState('Exploding');
	}
}

function SpawnTearGas()
{
	local Vector loc;
	local Cloud gas;
	local int i;

	if ( Role < ROLE_Authority )
		return;

	for (i=0; i<blastRadius/36; i++)
	{
		if (FRand() < 0.9)
		{
			loc = Location;
			loc.X += FRand() * blastRadius - blastRadius * 0.5;
			loc.Y += FRand() * blastRadius - blastRadius * 0.5;
			loc.Z += 32;
			gas = spawn(CloudClass, None,, loc);
			if (gas != None)
			{
				gas.Velocity = vect(0,0,0);
				gas.Acceleration = vect(0,0,0);
				gas.DrawScale = FRand() * 0.5 + 2.0;
				gas.LifeSpan = FRand() * 10 + 30;
				if ( Level.NetMode != NM_Standalone )
					gas.bFloating = False;
				else
					gas.bFloating = True;
				gas.Instigator = Instigator;
			}
		}
	}
}

simulated function BeginPlay()
{
	local DeusExPlayer aplayer;

	Super(DeusExProjectile).BeginPlay();

	Velocity = Speed * Vector(Rotation);
	RotationRate = RotRand(True);
	SetTimer(fuseLength, False);
	SetCollision(True, True, True);

	// What team is the owner if in team game
	if (( Level.NetMode != NM_Standalone ) && (Role == ROLE_Authority))
	{
		aplayer = DeusExPlayer(Owner);
		if (( aplayer != None ) && ( aplayer.GameReplicationInfo.bTeamGame ))
			team = aplayer.PlayerReplicationInfo.team;

		if (aplayer.SkillSystem != none)
			skillAtSet = aplayer.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
		else skillAtSet = 1.0;
	}

	// don't beep at the start of a level if we've been preplaced
	if (Owner == None)
	{
		time = fuseLength;
		bStuck = True;
	}
}


simulated function Tick(float deltaTime)
{
	local ScriptedPawn P;
	local DeusExPlayer Player;
	local Vector dist, HitLocation, HitNormal;
	local float blinkRate, mult, skillDiff;
	local float proxRelevance;
	local Pawn curPawn;
	local bool pass;
	local Actor HitActor;
	local float skillval;

	time += deltaTime;

	if ( Role == ROLE_Authority )
	{
		super(DeusExProjectile).Tick(deltaTime);

		if (bDisabled)
			return;

		if ( (Owner == None) && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
		{
			// Owner has logged out
			bDisabled = True;
			team = -1;
		}

		if (( Owner != None ) && (DeusExPlayer(Owner) != None ))
		{
			if ( DeusExPlayer(Owner).GameReplicationInfo.bTeamGame )
			{
				// If they switched sides disable the grenade
				if ( DeusExPlayer(Owner).PlayerReplicationInfo.team != team )
				{
					bDisabled = True;
					team = -1;
				}

				else if (DeusExPlayer(Owner).PlayerReplicationInfo.bIsSpectator)
				{
				    bDisabled = true;
				    team = -1;
				}
			}
		}

		// check for proximity
		if (bProximityTriggered)
		{
			if (bArmed)
			{
				proxCheckTime += deltaTime;

				// beep based on skill
				if (skillTime != 0)
				{
					if (time > fuseLength)
					{
						if (skillTime % 0.3 > 0.25)
							PlayBeepSound( 1280, 2.0, 3.0 );
					}
				}

				// if we have been triggered, count down based on skill
				if (skillTime > 0)
					skillTime -= deltaTime;

				// explode if time < 0
				if (skillTime < 0)
				{
					bDoExplode = True;
					bArmed = False;
				}
				// DC - new ugly way of doing it - old way was "if (proxCheckTime > 0.25)"
				// new way: weight the check frequency based on distance from player
				proxRelevance=DistanceFromPlayer/2000.0;  // at 500 units it behaves as it did before
				if (proxRelevance<0.25)
					proxRelevance=0.25;               // low bound 1/4
				else if (proxRelevance>10.0)
					proxRelevance=20.0;               // high bound 30
				else
					proxRelevance=proxRelevance*2;    // out past 1.0s, double the timing
				if (proxCheckTime>proxRelevance)
				{
					proxCheckTime = 0;

					// pre-placed explosives are only prox triggered by the player
					if (Owner == None)
					{
						foreach RadiusActors(class'DeusExPlayer', Player, proxRadius*4)
						{
							// the owner won't set it off, either
							if (Player != Owner)
							{
								dist = Player.Location - Location;
								if (VSize(dist) < proxRadius)
									if (skillTime == 0)
										skillTime = FClamp(-20.0 * Player.SkillSystem.GetSkillLevelValue(class'SkillDemolition'), 1.0, 10.0);
							}
						}
					}
					else
					{
						// If in multiplayer, check other players
						if (( Level.NetMode == NM_DedicatedServer) || ( Level.NetMode == NM_ListenServer))
						{
							curPawn = Level.PawnList;

							while ( curPawn != None )
							{
								pass = False;

								if ( curPawn.IsA('DeusExPlayer') )
								{
									Player = DeusExPlayer( curPawn );

									// Pass on owner
									if ( Player == Owner )
										pass = True;

									else if (Player.PlayerReplicationInfo.bIsSpectator)
									{
									    pass = True;
					                }

									// Pass on team member
									else if ( (DeusExPlayer(Owner).GameReplicationInfo.bTeamGame) && (team == Player.PlayerReplicationInfo.team) )
										pass = True;
									// Pass if radar transparency on
									else if ( Player.AugmentationSystem != none && 
										Player.AugmentationSystem.GetClassLevel( class'AugRadarTrans' ) == 3 )
										pass = True;

									// Finally, make sure we can see them (no exploding through thin walls)
									if ( !pass )
									{
										// Only players we can see : changed this to Trace from FastTrace so doors are included
										HitActor = Trace( HitLocation, HitNormal, Player.Location, Location, true );
										if (( HitActor == None ) || (DeusExPlayer(HitActor) == Player))
										{
										}
										else
											pass = True;
									}

									if ( !pass )
									{
										dist = Player.Location - Location;
										if ( VSize(dist) < proxRadius )
										{
											if (skillTime == 0)
											{
												skillval = 1.0;
												if (Player.SkillSystem != none) skillval = Player.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
												skillDiff = -skillAtSet + skillval;
												if ( skillDiff >= 0.0 ) // Scale goes 1.0, 1.6, 2.8, 4.0
													skillTime = FClamp( 1.0 + skillDiff * 6.0, 1.0, 2.5 );
												else
												{
													// Scale goes 1.0, 1.4, 2.2, 3.0
													skillTime = FClamp( 1.0	+ (-skillval * 4.0), 1.0, 3.0 );
												}
											}
										}
									}
								}
								curPawn = curPawn.nextPawn;
							}
						}
					}
				}
			}
		}

		// beep faster as the time expires
		beepTime += deltaTime;

		if (fuseLength - time <= 0.75)
			blinkRate = 0.1;
		else if (fuseLength - time <= fuseLength * 0.5)
			blinkRate = 0.3;
		else
			blinkRate = 0.5;

		if (time < fuseLength)
		{
			if (beepTime > blinkRate)
			{
				beepTime = 0;
				PlayBeepSound( 1280, 1.0, 0.5 );
			}
		}
	}
	if ( bDoExplode )	// Keep the simulated chain going
		Explode(Location, Vector(Rotation));
}

simulated function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
	local ParticleGenerator gen;

	if ((DamageType == 'TearGas') || (DamageType == 'PoisonGas') || (DamageType == 'Radiation'))
		return;

	if (DamageType == 'NanoVirus')
		return;

	if ( Role == ROLE_Authority )
	{
		// EMP damage disables explosives
		if (DamageType == 'EMP')
		{
			if (!bDisabled)
			{
				PlaySound(sound'EMPZap', SLOT_None,,, 1280);
				bDisabled = True;
				gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
				if (gen != None)
				{
					gen.checkTime = 0.25;
					gen.LifeSpan = 2;
					gen.particleDrawScale = 0.3;
					gen.bRandomEject = True;
					gen.ejectSpeed = 10.0;
					gen.bGravity = False;
					gen.bParticlesUnlit = True;
					gen.frequency = 0.5;
					gen.riseRate = 10.0;
					gen.spawnSound = Sound'Spark2';
					gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
					gen.SetBase(Self);
				}
			}
			return;
		}
		bDamaged = True;
	}
	if (instigatedBy != none)
	{
		SetOwner(instigatedBy);
		Instigator = instigatedBy;
	}
	Explode(Location, Vector(Rotation));
}

defaultproperties
{
    CloudClass=Class'DeusEx.TearGas'
}
