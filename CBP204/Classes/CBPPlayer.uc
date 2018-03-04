class CBPPlayer extends DeusExPlayer;

var class<KillerProfile> KillProfileClass;

var class<PawnType> NextPawnInfo;
var class<PawnType> PawnInfo;

var Lagometer LMActor;
var class<Lagometer> LagometerClass;
var float humanAnimRate;
var bool bCanDuck, bCanJumpX;
var Rotator RotationRateX;
var bool bCanRun;
var sound WalkSound;
var float AfterDeathPause;
var bool bCanBleed;
var CBPMainMenu MainMenu;
var bool bIsPlaying;
var bool bIsAlive;
var CBPPlayer MyLastKiller;
var DeusExWeapon KilledWeapon;
var DeusExProjectile KilledProjectile;
var string KilledMethod;
var bool bShowDeadHUD;
var bool bCanRestart;
var float SecondsToNewMap;
var float GameEndedTime;
var float DroneSpeedMulti;
var float LastBurnTime;
var class<CBPWeaponFlamethrower> WFlameThrowerClass;

var CBPBeltInventory BeltInventory;

var class<DeusExHUD> DeusExHUDClass;
var class<CBPPlayerTrack> PlayerTrackClass;

// antispam vars
var float LastNameChangeTime;
var string AS_LastMsg;
var float AS_LastMsgTime;
var int AS_LetterCount;
var float AS_LetterCountResetTime;

var string keyMainMenu;

var localized string l_nametaken;

// CBP204
var string NextMap;
var CBPSpeedFix SFActor;
//

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		humanAnimRate, bCanDuck, bCanJumpX, bCanRun, NextPawnInfo, bIsPlaying,
		LMActor, BeltInventory, MyLastKiller, bCanRestart, SFActor;

	reliable if (Role == ROLE_Authority && !bNetOwner)
		RotationRateX, PawnInfo;

	reliable if (Role == ROLE_Authority)
		ClientSetPhysVariables, ClientPlayerReady, WalkSound, bCanBleed, bIsAlive,
		ClientSetPawnInfo;

	unreliable if (Role == ROLE_Authority)
		SEF_ChunkUp, SEF_SpewBlood, SEF_SpawnBloodFromWeapon,
		SEF_SpawnTracerFromWeapon, SEF_SpawnShellCasing,
		SEF_SpawnSpark, SEF_SpawnTurretEffects, SEF_SpawnBloodFromProjectile,
		PlayLogSound, ClientPlayDying;

	reliable if (Role < ROLE_Authority)
		ServerPlayerReady, ServerToggleWalking, ServerSetPawnType,
		SpectatorPlay, PlayerSpectate, ServerLagoMeter, ServerSetName;

	// CBP204
	unreliable if (Role == ROLE_Authority && bNetOwner)
        NextMap;
	//
}


function InitSpeedFix()
{
	if (SFActor == none)
		SFActor = Spawn(class'CBPSpeedFix', self);
}


function RefreshMultiplayerKeys()
{
	local String Alias, keyName;
	local int i;

	for ( i = 0; i < 255; i++ )
	{
		keyName = ConsoleCommand ( "KEYNAME "$i );
		if ( keyName != "" )
		{
			Alias = ConsoleCommand( "KEYBINDING "$keyName );
            if (Alias ~= "ShowMainMenu")
                keyMainMenu = keyName;
		}
	}
	if ( keyMainMenu ~= "" )
		keyMainMenu = class'CBPAugmentationDisplayWindow'.default.KeyNotBoundString;
}

function ClientGameEnded()
{
	GotoState('CBPGameEnded');
}

exec function ShowScores()
{
	bShowScores = !bShowScores;
}

function RestoreAllHealth()
{
	super.RestoreAllHealth();
	HealthTorso = PawnInfo.default.HealthTorso;
	Health = PawnInfo.default.HealthTorso;
}

function PlayLogSound(sound s)
{
	//if ((DeusExRootWindow(rootWindow) != None) &&
	//    (DeusExRootWindow(rootWindow).hud != None) &&
	//	(DeusExRootWindow(rootWindow).hud.msgLog != None))
	//{
	//	DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(s);
	//}

	PlayOwnedSound(s, SLOT_None, transientSoundVolume, , 2048);
}

// override this
exec function PlayerSetPawnType(string ptclassname)
{
	local class<PawnType> pt;

	pt = class<PawnType>(DynamicLoadObject(ptclassname, class'Class'));
	if (pt != none)
	{
		ServerSetPawnType(pt);
	}
}

// override this
function ServerSetPawnType(class<PawnType> ptclass)
{
	CBPGame(Level.Game).AdjustTeamBalancer();
}

exec function SpectatorPlay();
exec function PlayerSpectate()
{
	GotoState('PlayerSpectating');
}

function ChangeTeam( int N );

auto state PlayerSpectating
{
	ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange, PlayerSpectate;

	exec function SpectatorPlay()
	{
		if (PawnInfo != NextPawnInfo) SetPawnInfo(NextPawnInfo);
		InstallPawnInfo();
		StartWalk();
		//ResetPlayerToDefaults();
		Level.Game.RestartPlayer(self);
	}

	function MultiplayerTick(float DeltaTime)
	{

	}

	exec function BehindView(bool B)
	{
	}

	exec function Suicide()
	{
	}

	function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
	{
	}

	function ChangeTeam( int N )
	{
		//Level.Game.ChangeTeam(self, N);
	}

	exec function AltFire( optional float F )
	{
		//ViewTarget = None;
	}

	exec function Fire( optional float F )
	{
		//if ( Role == ROLE_Authority )
		//{
		//	ViewPlayerNum(-1);
		//}
	}

	exec function ParseRightClick()
	{
	}

	exec function ParseLeftClick()
	{
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		Acceleration = NewAccel * 1.0;
		MoveSmooth(Acceleration * DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;
		bHidden = false;
		DrawType = DT_Mesh;
		bIsPlaying = true;
		bCollideWorld = true;
	}

	function BeginState()
	{
		local inventory anItem;
		local inventory nextItem;

		bIsAlive = false;

		if (GetPlayerPawn() == self)
		{
			// do on client side
			FrobTarget = none;
			return;
		}

		// do on server side

		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bWaitingPlayer = true;
		SetCollision(false, false, false);
		bCollideWorld = false;
		//SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
		EyeHeight = Default.BaseEyeHeight;
		SetPhysics(PHYS_Flying);
		bHidden = true;
		DrawType = DT_None;
		bBehindView = false;
		bIsPlaying = false;

		// clear inventory
		while(Inventory != None)
		{
			anItem = Inventory;
			DeleteInventory(anItem);
			anItem.Destroy();
		}

		SetInHandPending(None);
		SetInHand(None);

		bInHandTransition = False;

		if (Weapon != none) Weapon.Destroy();
		Weapon = none;

		if (Role == ROLE_Authority)
		{
			if (BeltInventory != none) BeltInventory.Reset();
			if (AugmentationSystem != none)
			{
				AugmentationSystem.ResetAugmentations();
				AugmentationSystem.Destroy();
			}
			if (SkillSystem != none)
			{
				SkillSystem.ResetSkills();
				SkillSystem.Destroy();
			}
			CBPPlayerReplicationInfo(PlayerReplicationInfo).bIsDead = true;
			CBPGame(Level.Game).AdjustTeamBalancer();
		}

		LightType = default.LightType;
		LightBrightness = default.LightBrightness;
		LightHue = default.LightHue;
		LightSaturation = default.LightSaturation;
		LightRadius = default.LightRadius;
		ScaleGlow = default.ScaleGlow;
		AmbientSound = none;

		ExtinguishFire();
	}
}

function ServerPlayerReady()
{
	ClientPlayerReady(CBPGame(Level.Game).MainMenuClass, Level.Game.ScoreboardType, CBPGameReplicationInfo(GameReplicationInfo).ForceTeam);
}

function ClientPlayerReady(class<CBPMainMenu> mmclass, class<ScoreBoard> ScoreType, byte forceteam)
{
	if (mmclass != none)
	{
		if (MainMenu != none) MainMenu.Destroy();
		MainMenu = Spawn(mmclass, self);
		MainMenu.ShowMenu(forceteam);
	}
	if (ScoreType != none)
	{
		if (Scoring != none) Scoring.Destroy();
		Scoring = Spawn(ScoreType, self);
	}

	RefreshMultiplayerKeys();
}

static function SetMultiSkin (Actor V91, string V92, string V93, byte V94)
{
}

function ClientReplicateSkins (Texture V95, optional Texture V96, optional Texture V97, optional Texture V98)
{
}

function ServerTaunt(name VCB)
{
}

exec function Speech(int Type, int VCC, int Callsign)
{
}

exec function Taunt(name VCB)
{
}

exec function CallForHelp ()
{
}

exec function DebugCommand (string VCD)
{
}

exec function SetDebug (name VCE, name VCF)
{
}

exec function GetDebug (name VCE)
{
}

exec function BehindView (bool B)
{
	bBehindView = B;
}

function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	bool bFired,
	bool bAltFired,
	bool bForceFire,
	bool bForceAltFire,
	eDodgeDir DodgeMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;
	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDodgeDir OldDodgeMove;

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;

			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;

			switch (OldAccel & 7)
			{
				case 0:
					OldDodgeMove = DODGE_None;
					break;
				case 1:
					OldDodgeMove = DODGE_Left;
					break;
				case 2:
					OldDodgeMove = DODGE_Right;
					break;
				case 3:
					OldDodgeMove = DODGE_Forward;
					break;
				case 4:
					OldDodgeMove = DODGE_Back;
					break;
			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDodgeMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// handle firing and alt-firing
	if ( bFired )
	{
		if ( bForceFire && (Weapon != None) )
			Weapon.ForceFire();
		else if ( bFire == 0 )
			Fire(0);
		bFire = 1;
	}
	else
		bFire = 0;


	if ( bAltFired )
	{
		if ( bForceAltFire && (Weapon != None) )
			Weapon.ForceAltFire();
		else if ( bAltFire == 0 )
			AltFire(0);
		bAltFire = 1;
	}
	else
		bAltFire = 0;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewPitch < 32768)
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;

	Rot.Pitch = 0;

	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	OldBase = Base;

	// Perform actual movement.
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 500.0/Player.CurrentNetSpeed )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		if ( Mover(Base) != None )
			ClientLoc = Location - Base.Location;
		else
			ClientLoc = Location;
		//log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Physics);
		LastUpdateTime = Level.TimeSeconds;
		ClientAdjustPosition
		(
			TimeStamp,
			GetStateName(),
			Physics,
			ClientLoc.X,
			ClientLoc.Y,
			ClientLoc.Z,
			Velocity.X,
			Velocity.Y,
			Velocity.Z,
			Base
		);
	}
	//log("Server "$Role$" moved "$self$" stamp "$TimeStamp$" location "$Location$" Acceleration "$Acceleration$" Velocity "$Velocity);

	MultiplayerTick(DeltaTime);
}

function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local int i;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm, prevloc, prevvelocity;

	local float AdjPCol, SavedRadius;
	local pawn SavedPawn, P;
	local vector Dist;
   //local bool HighVelocityDelta;


   //HighVelocityDelta = false;
   // Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		//add this move to the pending move
		PendingMove.TimeStamp = Level.TimeSeconds;
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		// Set this move's data.
		if ( PendingMove.DodgeMove == DODGE_None )
			PendingMove.DodgeMove = DodgeMove;
		PendingMove.bRun = (bRun > 0);
		PendingMove.bDuck = (bDuck > 0);
		PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
		PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
		PendingMove.Delta = TotalTime;
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	// Set this move's data.
	NewMove.DodgeMove = DodgeMove;
	NewMove.TimeStamp = Level.TimeSeconds;
	NewMove.bRun = (bRun > 0);
	NewMove.bDuck = (bDuck > 0);
	NewMove.bPressedJump = bPressedJump;
	NewMove.bFire = (bJustFired || (bFire != 0));
	NewMove.bForceFire = bJustFired;
	NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
	NewMove.bForceAltFire = bJustAltFired;
	if ( Weapon != None ) // approximate pointing so don't have to replicate
		Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));
	bJustFired = false;
	bJustAltFired = false;

	// adjust radius of nearby players with uncertain location
   // XXXDEUS_EX AMSD Slow Pawn Iterator
//	ForEach AllActors(class'Pawn', P)
   for (p = Level.PawnList; p != None; p = p.NextPawn)
		if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dist = P.Location - Location;
			AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
			if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
			{
				SavedPawn = P;
				SavedRadius = P.CollisionRadius;
				Dist.Z = 0;
				P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
				break;
			}
		}

   // Simulate the movement locally.

   prevloc = Location;
   prevvelocity = Velocity;
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot * (NewMove.Delta / DeltaTime));
	AutonomousPhysics(NewMove.Delta);
   //HighVelocityDelta = VelocityChanged(prevvelocity,Velocity);

   if ( SavedPawn != None )
		SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}

	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011); //was 0.011

   // DEUS_EX AMSD If this move is not particularly important, then up the netmove delta
   // don't do this when falling either.
   //if (!PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump && !(Physics == PHYS_Falling))
   //{
   //   if ((VSize(Velocity)<5.0) && (!HighVelocityDelta))
   //   {
   //      NetMoveDelta = FMax(NetMoveDelta, Player.StaticUpdateInterval);
   //   }
   //   else if (!HighVelocityDelta)
   //   {
   //      NetMoveDelta = FMax(NetMoveDelta, Player.DynamicUpdateInterval);
   //   }
   //}

   // If the net move delta has shrunk enough that
   // client update time is bigger, then we haven't
   // sent a packet THAT recently, so make sure we do.
   //if (ClientUpdateTime < (-1 * NetMoveDelta))
   //   ClientUpdateTime = 0;


	if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( !PendingMove.bPressedJump && (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		return;
	}
	else
	{
      ClientUpdateTime = PendingMove.Delta - NetMoveDelta;

      if ( SavedMoves == None )
         SavedMoves = PendingMove;
      else
         LastMove.NextMove = PendingMove;
      PendingMove = None;
   }


	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23)
					+ (CompressAccel(BuildAccel.Y) << 15)
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DodgeMove;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);

	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
	ServerMove
	(
		NewMove.TimeStamp,
		NewMove.Acceleration * 10,
		Location,
		NewMove.bRun,
		NewMove.bDuck,
		bJumpStatus,
		NewMove.bFire,
		NewMove.bAltFire,
		NewMove.bForceFire,
		NewMove.bForceAltFire,
		NewMove.DodgeMove,
		ClientRoll,
		(32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)),
		OldTimeDelta,
		OldAccel
	);
	//log("Replicated "$self$" stamp "$NewMove.TimeStamp$" location "$Location$" dodge "$NewMove.DodgeMove$" to "$DodgeDir);
}

exec function ShowMainMenu()
{
	if (MainMenu != none) MainMenu.ShowMenu(CBPGameReplicationInfo(GameReplicationInfo).ForceTeam);
}

simulated function Tick(float DeltaTime)
{
	if (Role == ROLE_SimulatedProxy)
	{
		RotationRate = RotationRateX;
	}
}

function SetPawnInfo(class<PawnType> pinfo)
{
	PawnInfo = pinfo;
	ClientSetPawnInfo(pinfo);
}

function ClientSetPawnInfo(class<PawnType> pinfo)
{
	PawnInfo = pinfo;
}

function InstallPawnInfo()
{
	local int i;

	SetCollisionSize(PawnInfo.default.CollisionRadius, PawnInfo.default.CollisionHeight);
	BaseEyeHeight = PawnInfo.default.BaseEyeHeight;
	bCanJump = PawnInfo.default.bCanJump;
	bCanJumpX = PawnInfo.default.bCanJump;
	bCanDuck = PawnInfo.default.bCanDuck;
	bCanSwim = PawnInfo.default.bCanSwim;
	bCanRun = PawnInfo.default.bCanRun;
	RotationRate = PawnInfo.default.RotationRate;
	RotationRateX = PawnInfo.default.RotationRate;
	CarcassType = PawnInfo.default.CarcassType;
	WaterSpeed = PawnInfo.default.WaterSpeed;
	Mass = PawnInfo.default.Mass;
	Buoyancy = PawnInfo.default.Buoyancy;
	AirSpeed = PawnInfo.default.AirSpeed;
    AccelRate = PawnInfo.default.AccelRate;
    JumpZ = PawnInfo.default.JumpZ;
	AirControl = PawnInfo.default.AirControl;
	humanAnimRate = PawnInfo.default.MeshAnimRate;
	WalkSound = PawnInfo.default.WalkSound;
	bCanBleed = PawnInfo.default.bCanBleed;
	PrePivot = PawnInfo.default.PrePivot;
	UnderWaterTime = PawnInfo.default.UnderWaterTime;
	ClientSetPhysVariables(Mass, Buoyancy, bCanSwim, BaseEyeHeight, UnderWaterTime);

	// set visualities
	Mesh = PawnInfo.default.Mesh;
	Texture = PawnInfo.default.Texture;
	DrawScale = PawnInfo.default.DrawScale;
	for (i = 0; i < 8; i++)
		MultiSkins[i] = PawnInfo.default.MultiSkins[i];

	if (BeltInventory != none) BeltInventory.Destroy();
	BeltInventory = Spawn(PawnInfo.default.BeltInventoryClass, self);
}


function ClientSetPhysVariables(float m, float b, bool swim, float eyeh, float uwt)
{
	Mass = m;
	Buoyancy = b;
	bCanSwim = swim;
	BaseEyeHeight = eyeh;
	UnderWaterTime = uwt;
}

function StartWalk()
{
	SetCollision(True, True, True);
	SetPhysics(PHYS_Walking);
	bCollideWorld = True;
	Velocity = vect(0.00,0.00,0.00);
	Acceleration = vect(0.00,0.00,0.00);
	EyeHeight = BaseEyeHeight;
	ClientReStart();
	PlayWaiting();
	if (Region.Zone.bWaterZone && (PlayerReStartState == 'PlayerWalking'))
	{
		if (HeadRegion.Zone.bWaterZone)
		{
			PainTime = UnderWaterTime;
		}
		SetPhysics(PHYS_Swimming);
		GotoState('PlayerSwimming');
	}
	else
	{
		GotoState(PlayerReStartState);
	}
}

function ServerToggleWalking()
{
	bToggleWalk = !bToggleWalk;
}

exec function ToggleWalk()
{
	if (RestrictInput())
		return;

	bToggleWalk = !bToggleWalk;
	ServerToggleWalking();
}

function DoJump( optional float F )
{
	local DeusExWeapon w;
	local float scaleFactor, augLevel;

	if (!bCanJumpX) return;

	if ((CarriedDecoration != None) && (CarriedDecoration.Mass > 20))
		return;
	else if (bForceDuck)
		return;

	if (Physics == PHYS_Walking)
	{
		if ( Role == ROLE_Authority )
			PawnInfo.static.PlaySound_Jump(self);
		PawnInfo.static.PlayAnimation_InAir(self);

		Velocity.Z = JumpZ;

		if (AugmentationSystem == None)
			augLevel = -1.0;
		else
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
		w = DeusExWeapon(InHand);
		if ((augLevel != -1.0) && ( w != None ) && ( w.Mass > 30.0))
		{
			scaleFactor = 1.0 - FClamp( ((w.Mass - 30.0)/55.0), 0.0, 0.5 );
			Velocity.Z *= scaleFactor;
		}

		if ( Base != Level )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
		if ( bCountJumps && (Role == ROLE_Authority) )
			Inventory.OwnerJumped();
	}
}

exec function bool DropItem (optional Inventory Inv, optional bool bDrop)
{
	local byte VB7;
	local Inventory Item;
	local Inventory previousItemInHand;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Vector dropVect;
	local float size;
	local float Mult;
	local DeusExCarcass carc;
	local Class<DeusExCarcass> carcClass;
	local bool bDropped;
	local bool bRemovedFromSlots;
	local int itemPosX;
	local int itemPosY;

	bDropped=True;
	if ( RestrictInput() )
	{
		return False;
	}
	if ( Inv == None )
	{
		previousItemInHand=inHand;
		Item=inHand;
	} else {
		Item=Inv;
	}
	if ( Item != None )
	{
		GetAxes(Rotation,X,Y,Z);
		dropVect=Location + (CollisionRadius + 2 * Item.CollisionRadius) * X;
		dropVect.Z += BaseEyeHeight;
		if (  !FastTrace(dropVect) )
		{
			ClientMessage(CannotDropHere);
			return False;
		}
		if ( Item.IsA('DeusExWeapon') )
		{
			if (CBPWeapon(Item) != none && !CBPWeapon(Item).bCanDrop) return false;
			if (CBPGrenade(Item) != none && !CBPWeapon(Item).bCanDrop) return false;
			if (  !DeusExWeapon(Item).IsInState('Idle') &&  !DeusExWeapon(Item).IsInState('Idle2') &&  !DeusExWeapon(Item).IsInState('DownWeapon') &&  !DeusExWeapon(Item).IsInState('Reload') )
			{
				return False;
			} else {
				DeusExWeapon(Item).ScopeOff();
				DeusExWeapon(Item).LaserOff();
			}
		}
		if ( Item.IsA('ChargedPickup') && ChargedPickup(Item).IsActive() )
		{
			return False;
		}
		if ( Item.IsA('NanoKeyRing') )
		{
			return False;
		}
		if ( Item == inHand )
		{
			PutInHand(None);
		}
		if ( Item.IsA('DeusExPickup') )
		{
			if (CBPPickup(Item) != none && !CBPPickup(Item).bCanDrop) return false;
			if ( DeusExPickup(Item).bActive )
			{
				DeusExPickup(Item).Activate();
			}
			DeusExPickup(Item).NumCopies--;
			UpdateBeltText(Item);
			if ( DeusExPickup(Item).NumCopies > 0 )
			{
				if ( previousItemInHand == Item )
				{
					PutInHand(previousItemInHand);
				}
				Item=Spawn(Item.Class,Owner);
			} else {
				bRemovedFromSlots=True;
				itemPosX=Item.invPosX;
				itemPosY=Item.invPosY;
				RemoveItemFromSlot(Item);
				DeusExPickup(Item).NumCopies=1;
			}
		} else {
			bRemovedFromSlots=True;
			itemPosX=Item.invPosX;
			itemPosY=Item.invPosY;
			RemoveItemFromSlot(Item);
		}
		if ( (Level.NetMode == 0) && (FrobTarget != None) &&  !Item.IsA('POVCorpse') )
		{
			Item.Velocity=vect(0.00,0.00,0.00);
			PlayPickupAnim(FrobTarget.Location);
			size=FrobTarget.CollisionRadius - Item.CollisionRadius * 2;
			dropVect.X=size / 2 - FRand() * size;
			dropVect.Y=size / 2 - FRand() * size;
			dropVect.Z=FrobTarget.CollisionHeight + Item.CollisionHeight + 16;
			if ( FastTrace(dropVect) )
			{
				Item.DropFrom(FrobTarget.Location + dropVect);
			} else {
				ClientMessage(CannotDropHere);
				bDropped=False;
			}
		} else {
			if ( AugmentationSystem != None )
			{
				Mult=AugmentationSystem.GetAugLevelValue(Class'AugMuscle');
				if ( Mult == -1.00 )
				{
					Mult=1.00;
				}
			}
			if ( bDrop )
			{
				Item.Velocity=VRand() * 30;
				PlayPickupAnim(Item.Location);
			} else {
				Item.Velocity=vector(ViewRotation * (Mult * 300)) + vect(0.00,0.00,220.00) + (40 * VRand());
				PlayAnim('Attack',,0.10);
			}
			GetAxes(ViewRotation,X,Y,Z);
			dropVect=Location + 0.80 * CollisionRadius * X;
			dropVect.Z += BaseEyeHeight;
			if ( Item.IsA('POVCorpse') )
			{
				if ( POVCorpse(Item).carcClassString != "" )
				{
					carcClass=Class<DeusExCarcass>(DynamicLoadObject(POVCorpse(Item).carcClassString,Class'Class'));
					if ( carcClass != None )
					{
						carc=Spawn(carcClass);
						if ( carc != None )
						{
							carc.Mesh=carc.Mesh2;
							carc.KillerAlliance=POVCorpse(Item).KillerAlliance;
							carc.KillerBindName=POVCorpse(Item).KillerBindName;
							carc.Alliance=POVCorpse(Item).Alliance;
							carc.bNotDead=POVCorpse(Item).bNotDead;
							carc.bEmitCarcass=POVCorpse(Item).bEmitCarcass;
							carc.CumulativeDamage=POVCorpse(Item).CumulativeDamage;
							carc.MaxDamage=POVCorpse(Item).MaxDamage;
							carc.ItemName=POVCorpse(Item).CorpseItemName;
							carc.CarcassName=POVCorpse(Item).CarcassName;
							carc.Velocity=Item.Velocity * 0.50;
							Item.Velocity=vect(0.00,0.00,0.00);
							carc.bHidden=False;
							carc.SetPhysics(PHYS_Falling);
							carc.SetScaleGlow();
							if ( carc.SetLocation(dropVect) )
							{
								SetInHandPending(None);
								Item.Destroy();
								Item=None;
							} else {
								carc.bHidden=True;
							}
						}
					}
				}
			} else {
				if ( FastTrace(dropVect) )
				{
					Item.DropFrom(dropVect);
					Item.bFixedRotationDir=True;
					Item.RotationRate.Pitch=(32768 - Rand(65536)) * 4.00;
					Item.RotationRate.Yaw=(32768 - Rand(65536)) * 4.00;
				}
			}
		}
		if ( Item != None )
		{
			if ( ((inHand == None) || (inHandPending == None)) && (Item.Physics != 2) )
			{
				PutInHand(Item);
				ClientMessage(CannotDropHere);
				bDropped=False;
			} else {
				Item.Instigator=self;
			}
		}
	} else {
		if ( carriedDecoration != None )
		{
			DropDecoration();
			PlayAnim('Attack',,0.10);
		}
	}
	if ( bRemovedFromSlots && (Item != None) &&  !bDropped )
	{
		PlaceItemInSlot(Item,itemPosX,itemPosY);
	}
	return bDropped;
}

function HandleWalking()
{
	super.HandleWalking();
	if (!bCanDuck)
	{
		bDuck = 0;
		bCrouchOn = false;
	}
	if (!bCanRun) bIsWalking = true;
}

function bool ResetBasedPawnSize()
{
	if (PawnInfo != none)
		return SetBasedPawnSize(PawnInfo.Default.CollisionRadius, GetDefaultCollisionHeight());
	else
		return SetBasedPawnSize(default.CollisionRadius, GetDefaultCollisionHeight());
}

function float GetDefaultCollisionHeight()
{
	return (PawnInfo.Default.CollisionHeight-4.5);
}

function bool SetBasedPawnSize(float newRadius, float newHeight)
{
	local float  oldRadius, oldHeight;
	local bool   bSuccess;
	local vector centerDelta, lookDir, upDir;
	local float  deltaEyeHeight;
	local Decoration savedDeco;

	newRadius = PawnInfo.default.CollisionRadius;
	if (newHeight < 0)
		newHeight = 0;

	oldRadius = CollisionRadius;
	oldHeight = CollisionHeight;

	centerDelta    = vect(0, 0, 1)*(newHeight-oldHeight);
	deltaEyeHeight = GetDefaultCollisionHeight() - PawnInfo.Default.BaseEyeHeight;

	if ((oldRadius == newRadius) && (oldHeight == newHeight) && (BaseEyeHeight == newHeight - deltaEyeHeight))
		return true;

	if (CarriedDecoration != None)
		savedDeco = CarriedDecoration;

	bSuccess = false;
	if ((newHeight <= CollisionHeight) && (newRadius <= CollisionRadius))  // shrink
	{
		SetCollisionSize(newRadius, newHeight);
		if (Move(centerDelta))
			bSuccess = true;
		else
			SetCollisionSize(oldRadius, oldHeight);
	}
	else
	{
		if (Move(centerDelta))
		{
			SetCollisionSize(newRadius, newHeight);
			bSuccess = true;
		}
	}

	if (bSuccess)
	{
		// make sure we don't lose our carried decoration
		if (savedDeco != None)
		{
			savedDeco.SetPhysics(PHYS_None);
			savedDeco.SetBase(Self);
			savedDeco.SetCollision(False, False, False);

			// reset the decoration's location
			lookDir = Vector(Rotation);
			lookDir.Z = 0;
			upDir = vect(0,0,0);
			upDir.Z = CollisionHeight / 2;		// put it up near eye level
			savedDeco.SetLocation(Location + upDir + (0.5 * CollisionRadius + CarriedDecoration.CollisionRadius) * lookDir);
		}

//		PrePivotOffset  = vect(0, 0, 1)*(GetDefaultCollisionHeight()-newHeight);
		PrePivot        -= centerDelta;
//		DesiredPrePivot -= centerDelta;
		BaseEyeHeight   = newHeight - deltaEyeHeight;

		// Complaints that eye height doesn't seem like your crouching in multiplayer
		if (( Level.NetMode != NM_Standalone ) && (bIsCrouching || bForceDuck) )
			EyeHeight		-= (centerDelta.Z * 2.5);
		else
			EyeHeight		-= centerDelta.Z;
	}
	return (bSuccess);
}

function PostBeginPlay()
{
	Super(PlayerPawnExt).PostBeginPlay();

	ShieldStatus = SS_Off;
	ServerTimeLastRefresh = 0;

	bCheatsEnabled = False;

	if (Role == ROLE_Authority)
		InitSpeedFix();
}

simulated function PostNetBeginPlay()
{
	Super(PlayerPawnExt).PostNetBeginPlay();

	if (Role == ROLE_SimulatedProxy)
	{
		DrawShield();
		CreatePlayerTracker();
	}

	if (Role == ROLE_AutonomousProxy || Level.netMode == NM_ListenServer)
	{
		log("Setting theme manager");
		if (ThemeManager == NONE)
		{
			CreateColorThemeManager();
			ThemeManager.SetOwner(self);
			ThemeManager.SetCurrentHUDColorTheme(ThemeManager.GetFirstTheme(1));
			ThemeManager.SetCurrentMenuColorTheme(ThemeManager.GetFirstTheme(0));
			ThemeManager.SetMenuThemeByName(MenuThemeName);
			ThemeManager.SetHUDThemeByName(HUDThemeName);
			if (DeusExRootWindow(rootWindow) != None)
			   DeusExRootWindow(rootWindow).ChangeStyle();
		}
	}

	if (Role > ROLE_SimulatedProxy)
	{
		ReceiveFirstOptionSync(AugPrefs[0], AugPrefs[1], AugPrefs[2], AugPrefs[3], AugPrefs[4]);
		ReceiveSecondOptionSync(AugPrefs[5], AugPrefs[6], AugPrefs[7], AugPrefs[8]);
		ServerSetAutoReload(bAutoReload);
	}
}

function PostPostBeginPlay()
{
	Super(PlayerPawnExt).PostPostBeginPlay();

	// Restore colors that the user selected (as opposed to those
	// stored in the savegame)
	if (Level.NetMode == NM_Client || Level.netMode == NM_ListenServer)
	{
		ThemeManager.SetMenuThemeByName(MenuThemeName);
		ThemeManager.SetHUDThemeByName(HUDThemeName);
	}

	if (killProfile == None && Role == ROLE_Authority)
		killProfile = Spawn(KillProfileClass, Self);
}

function InitializeSubSystems()
{
	// Spawn the Color Manager
	if (Level.NetMode == NM_Client || Level.netMode == NM_ListenServer)
	{
		CreateColorThemeManager();
		ThemeManager.SetOwner(self);
	}

	if (AugmentationSystem != none && AugmentationSystem.class != PawnInfo.default.AugManagerClass)
	{
		AugmentationSystem.Destroy();
		AugmentationSystem = none;
	}

	if (AugmentationSystem == none && PawnInfo.default.AugManagerClass != none)
	{
		AugmentationSystem = Spawn(PawnInfo.default.AugManagerClass, Self);
		AugmentationSystem.CreateAugmentations(Self);
		AugmentationSystem.AddDefaultAugmentations();
        AugmentationSystem.SetOwner(Self);
	}

	if (SkillSystem != none && SkillSystem.class != PawnInfo.default.SkillManagerClass)
	{
		SkillSystem.Destroy();
		SkillSystem = none;
	}

	if (SkillSystem == none && PawnInfo.default.SkillManagerClass != none)
	{
		SkillSystem = Spawn(PawnInfo.default.SkillManagerClass, self);
		SkillSystem.CreateSkills(self);
	}
}

function float GetCurrentGroundSpeed()
{
	local float augValue, speed;

	if (PawnInfo == none) return 0;

	if ( AugmentationSystem == None ) return PawnInfo.default.GroundSpeed;

	augValue = AugmentationSystem.GetAugLevelValue(class'AugSpeed');

	if (augValue == -1.0)
		augValue = 1.0;

	speed = PawnInfo.default.GroundSpeed * augValue;

	return speed;
}

function PreTravel()
{
}

event TravelPostAccept()
{
	Super(PlayerPawnExt).TravelPostAccept();
}

exec function RestartLevel() {}
exec function LoadGame(int saveIndex) {}
exec function QuickSave() {}
exec function QuickLoad() {}
function QuickLoadConfirmed() {}
exec function StartNewGame(String startMap) {}
function StartTrainingMission() {}
function ShowIntro(optional bool bStartNewGame) {}
function ShowCredits(optional bool bLoadIntro) {}
function StartListenGame(string options) {}
function StartMultiplayerGame(string command) {}
function NewMultiplayerMatch() {}

function ShowMultiplayerWin( String winnerName, int winningTeam, String Killer, String Killee, String Method )
{
	// todo: show final win window
}

function MultiplayerDeathMsg( Pawn killer, bool killedSelf, bool valid, String killerName, String killerMethod )
{
	// todo: show death screen
}

function ShowProgress()
{
	// related to MultiplayerDeathMsg
}

function ResetPlayer(optional bool bTraining) {}
function ResetPlayerToDefaults()
{
	local inventory anItem;
	local inventory nextItem;

	while(Inventory != None)
	{
		anItem = Inventory;
		DeleteInventory(anItem);
		anItem.Destroy();
	}

	if (BeltInventory != none)
		BeltInventory.Reset();

	SetInHandPending(None);
	SetInHand(None);

	bInHandTransition = False;

	RestoreAllHealth();
	ClearLog();

	// Reinitialize all subsystems we've just nuked
	InitializeSubSystems();

	//NintendoImmunityEffect( True );
    GiveInitialInventory();
}

simulated function RefreshSystems(float DeltaTime)
{
	local DeusExRootWindow root;
	local DeusExBaseWindow w;

	if (GetPlayerPawn() == self)
	{
		if (PawnInfo != none)
			PawnInfo.static.Event_PlayerTick(self, DeltaTime);
	}

	//if (Role == ROLE_Authority) return;

	//if (LastRefreshTime < 0) LastRefreshTime = 0;

	//LastRefreshTime = LastRefreshTime + DeltaTime;

	//if (LastRefreshTime < 0.25) return;

	//root = DeusExRootWindow(rootWindow);
	//if (root != None)
	//{
	//	w = root.GetTopWindow();
	//	if (w != none) w.RefreshWindow(DeltaTime);
	//}

	//LastRefreshTime = 0;
}

function StartPoison( Pawn poisoner, int Damage )
{
	local float augLevel;

	// Don't do poison and drug effects if in multiplayer and AugEnviro is on
	if (AugmentationSystem != none)
	{
		augLevel = AugmentationSystem.GetAugLevelValue(class'AugEnviro');
		if ( augLevel != -1.0 )
			return;
	}

	myPoisoner = poisoner;

	if (Health <= 0)  // no more pain -- you're already dead!
		return;

	poisonCounter = 4;    // take damage no more than four times (over 8 seconds)
	poisonTimer   = 0;    // reset pain timer
	if (poisonDamage < Damage)  // set damage amount
		poisonDamage = Damage;

	drugEffectTimer += 4;  // make the player vomit for the next four seconds

	// In multiplayer, don't let the effect last longer than 30 seconds
	if ( drugEffectTimer > 30 )
		drugEffectTimer = 30;
}

function RepairInventory() {}
function Bleed(float deltaTime) {}
function SpawnBlood(Vector HitLocation, float Damage) {}
function SpawnEMPSparks(Actor empActor, Rotator rot) {}
function RestoreSkillPoints() {}
function SaveSkillPoints() {}
exec function AugAdd(class<Augmentation> aWantedAug) {}
function AddAugmentationDisplay(Augmentation aug) {}
function RemoveAugmentationDisplay(Augmentation aug) {}
function ClearAugmentationDisplay() {}
function UpdateAugmentationDisplayStatus(Augmentation aug) {}
function AddChargedDisplay(ChargedPickup item) {}
function RemoveChargedDisplay(ChargedPickup item) {}
function SkillPointsAdd(int numPoints) {}

function GrantAugs(int NumAugs) { PawnInfo.static.Event_GrantAugs(self, NumAugs); }

function RegularGrantAugs(int NumAugs)
{
   local Augmentation CurrentAug;
   local int PriorityIndex;
   local int AugsLeft;
   local int i;
   local CBPAugmentationManager mmaugmanager;
   local string tmp;

   if (Role < ROLE_Authority)
      return;

   mmaugmanager = CBPAugmentationManager(AugmentationSystem);
   if (mmaugmanager == none) return;

   AugsLeft = NumAugs;

   for (PriorityIndex = 0; PriorityIndex < ArrayCount(AugPrefs); PriorityIndex++)
   {
		if (AugsLeft <= 0)
		{
			return;
		}
		if (AugPrefs[PriorityIndex] == '')
		{
			return;
		}

		tmp = string(AugPrefs[PriorityIndex]);

		for (i = 0; i < 18; i++)
		{
			if (string(mmaugmanager.mpAugs[i].default.OldAugClass.Name) == tmp)
			{
				if (mmaugmanager.mpStatus[i] == 0)
				{
					mmaugmanager.NewGivePlayerAugmentation(mmaugmanager.mpAugs[i]);
					AugsLeft -= 1;
				}
				break;
			}
		}
	}
}

//
// inventory related functions
//
function SetInHand(Inventory newInHand)
{
	inHand = newInHand;
}

function SetInHandPending(Inventory newInHandPending)
{
	if ( newInHandPending == None )
		ClientInHandPending = None;

	inHandPending = newInHandPending;
}

function UpdateBeltText(Inventory item);
function ClearPosition(int pos);
function ClearBelt();
function RemoveObjectFromBelt(Inventory item);
function AddObjectToBelt(Inventory item, int pos, bool bOverride);

function Bool FindInventorySlot(Inventory anItem, optional Bool bSearchOnly)
{
	if (anItem == None)
		return false;

	if ((anItem.IsA('DataVaultImage')) || (anItem.IsA('NanoKey')) || (anItem.IsA('Credits')) || (anItem.IsA('Ammo')))
		return true;

	if (BeltInventory == none) return false;
	if (!BeltInventory.CanPlaceInventory(anItem)) return false;

	return true;
}

function bool AddInventory(inventory NewItem)
{
	// Skip if already in the inventory.
	local inventory Inv;

	// The item should not have been destroyed if we get here.
	if (NewItem == None )
		log("tried to add none inventory to "$self);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if( Inv == NewItem )
			return false;

	if (NewItem.Owner != None && NewItem.Owner != self)
		Pawn(NewItem.Owner).DeleteInventory(NewItem);

	if (!NewItem.IsA('Ammo'))
	{
		if (BeltInventory != none && !BeltInventory.AddInventory(NewItem))
			return false;
	}

	// Add to front of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = Inventory;
	Inventory = NewItem;

	return true;
}

function bool DeleteInventory(inventory item)
{
	local bool retval;
	local PersonaScreenInventory winInv;

	// If the item was inHand, clear the inHand
	if (inHand == item)
	{
		SetInHand(None);
		SetInHandPending(None);
	}

	if (BeltInventory != none)
		BeltInventory.RemoveInventory(item);

	return Super.DeleteInventory(item);
}

function GiveInventory(class<Inventory> InvType)
{
	local Inventory anItem;

	//anItem = Spawn(InvType);
	//anItem.Frob(Self, None);
	//inventory.bInObjectBelt = True;
	//anItem.Destroy();
	anItem = FindInventoryType(InvType);
	if (anItem != none)
	{
		if (CBPPickup(anItem) != none && CBPPickup(anItem).bCanHaveMultipleCopies)
		{
			if (CBPPickup(anItem).NumCopies < CBPPickup(anItem).maxCopies)
				CBPPickup(anItem).NumCopies++;
		} // gren.AmmoType.AmmoAmount >= gren.AmmoType.MaxAmmo
		if (CBPGrenade(anItem) != none && CBPGrenade(anItem).AmmoType.AmmoAmount < CBPGrenade(anItem).AmmoType.MaxAmmo)
		{
			CBPGrenade(anItem).AmmoType.AddAmmo(Weapon(anItem).PickupAmmoCount);
		}
		return;
	}

	anItem = Spawn(InvType, self);
	if (anItem != none)
	{
		if (Weapon(anItem) != none)
		{
			Weapon(anItem).GiveAmmo(self);
		}
		anItem.GiveTo(self);
		if (Weapon(anItem) != none)
		{
			Weapon(anItem).Instigator = self;
			Weapon(anItem).SetSwitchPriority(self);
			Weapon(anItem).AmbientGlow = 0;
		}
	}
}

exec function BuySkills()
{
}

function GiveInitialInventory()
{
	PawnInfo.static.GiveInitialInventory(self);
}

simulated function DrawInvulnShield()
{
}

simulated function CreateShadow()
{
}

simulated function KillShadow()
{
}

function bool IsLeaning ()
{
	return false;
}

function ServerUpdateLean(Vector Z48)
{
}

event Possess()
{
	local DeusExRootWindow root;
	local PlayerPawn localpawn;

	localpawn = GetPlayerPawn();
	// init root window only on client side!
	if (localpawn == self)
	{
		log("Initializing root window");
		InitRootWindow();
		root = DeusExRootWindow(rootWindow);
		if (root != none)
		{
			if (root.HUD != none) root.HUD.Destroy();
			root.HUD = DeusExHUD(root.NewChild(DeusExHUDClass));
			root.HUD.UpdateSettings(self);
			root.HUD.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0.00, 0.00);
			if (root.actorDisplay != none)
			{
				root.actorDisplay.Destroy();
				root.actorDisplay = none;
			}
		}
	}

	bIsPlayer = true;
	NetPriority = 3.25;

	if (localpawn == self)
	{
		ServerPlayerReady();
	}
}

function int HealPlayer(int baseHealPoints, optional Bool bUseMedicineSkill) { return PawnInfo.static.Event_HealPlayer(self, baseHealPoints, bUseMedicineSkill); }
function int RegularHealPlayer(int baseHealPoints, optional Bool bUseMedicineSkill) { return super.HealPlayer(baseHealPoints, bUseMedicineSkill); }

function MultiplayerTick(float DeltaTime)
{
	local int burnTime;
	local float augLevel;
	local int damage;

   Super(PlayerPawnExt).MultiplayerTick(DeltaTime);

   //If we've just put away items, reset this.
   if ((LastInHand != InHand) && (Level.Netmode == NM_Client) && (inHand == None))
   {
	   ClientInHandPending = None;
   }

   LastInHand = InHand;

   if ((PlayerIsClient()) || (Level.NetMode == NM_ListenServer))
   {
      if ((ShieldStatus != SS_Off) && (DamageShield == None))
         DrawShield();
		if ( (NintendoImmunityTimeLeft > 0.0) && ( InvulnSph == None ))
			DrawInvulnShield();
      if (Style != STY_Translucent)
         CreateShadow();
      else
         KillShadow();
   }

   if (Role < ROLE_Authority)
      return;

   // do server tick on pawninfo
   PawnInfo.static.Event_ServerTick(self, DeltaTime);

   // set ambient sound if we are not dead
   if (IsInState('PlayerWalking') && PawnInfo.default.AmbientSound != none)
		AmbientSound = PawnInfo.default.AmbientSound;
   else if (AugmentationSystem == none || AugmentationSystem.NumAugsActive() == 0) AmbientSound = none;

   UpdateInHand();

   UpdatePoison(DeltaTime);

   if (lastRefreshTime < 0)
      lastRefreshTime = 0;

   lastRefreshTime = lastRefreshTime + DeltaTime;

	if (bOnFire)
	{
		burnTime = WFlameThrowerClass.Default.BurnTime;
		burnTimer += deltaTime;
		if (burnTimer >= burnTime)
			ExtinguishFire();
	}

	if (bOnFire && (LastBurnTime + 1.0) < Level.TimeSeconds)
	{
		LastBurnTime = Level.TimeSeconds;
		damage = WFlameThrowerClass.Default.BurnDamage;
		TakeDamage(damage, myBurner, Location, vect(0,0,0), 'Burned');

		if (HealthTorso <= 0)
		{
			TakeDamage(10, myBurner, Location, vect(0,0,0), 'Burned');
			ExtinguishFire();
		}
	}

   if (lastRefreshTime < 0.25)
      return;

   if (ShieldTimer > 0)
      ShieldTimer = ShieldTimer - lastRefreshTime;

   if (ShieldStatus == SS_Fade)
      ShieldStatus = SS_Off;

   if (ShieldTimer <= 0)
   {
      if (ShieldStatus == SS_Strong)
         ShieldStatus = SS_Fade;
   }

	// If we have a drone active (post-death etc) and we're not using the aug, kill it off
    if (AugmentationSystem != none)
    {
		augLevel = AugmentationSystem.GetAugLevelValue(class'AugDrone');
		if (( aDrone != None ) && (augLevel == -1.0))
			aDrone.TakeDamage(100, None, aDrone.Location, vect(0,0,0), 'EMP');
    }

	if ( Level.Timeseconds > ServerTimeLastRefresh )
	{
		SetServerTimeDiff( Level.Timeseconds );
		ServerTimeLastRefresh = Level.Timeseconds + 10.0;
	}

   MaintainEnergy(lastRefreshTime);
   UpdateTranslucency(lastRefreshTime);
	if ( bNintendoImmunity )
	{
		NintendoImmunityTimeLeft = NintendoImmunityTime - Level.Timeseconds;
		if ( Level.Timeseconds > NintendoImmunityTime )
			NintendoImmunityEffect( False );
	}
   //RepairInventory();
   lastRefreshTime = 0;
}

function UpdateTranslucency(float DeltaTime)
{
   local float DarkVis;
   local float CamoVis;
	local AdaptiveArmor armor;
   local bool bMakeTranslucent;

   bMakeTranslucent = false;

   CamoVis = 1.0;

   //Check cloaking.
	if (AugmentationSystem != none && AugmentationSystem.GetAugLevelValue(class'AugCloak') != -1.0)
   {
      bMakeTranslucent = TRUE;
      CamoVis = 0.0;
   }

   // If you have a weapon out, scale up the camo and turn off the cloak.
   // Adaptive armor leaves you completely invisible, but drains quickly.
   if ((inHand != None) && (inHand.IsA('DeusExWeapon')) && (CamoVis < 1.0))
   {
      CamoVis = 1.0;
      bMakeTranslucent=FALSE;
      ClientMessage(WeaponUnCloak);
	  if (AugmentationSystem != none)
		AugmentationSystem.FindAugmentation(class'AugCloak').Deactivate();
   }

   ScaleGlow = Default.ScaleGlow * CamoVis;

   //Translucent is < 0.1, untranslucent if > 0.2, not same edge to prevent sharp breaks.
   if (bMakeTranslucent)
   {
      Style = STY_Translucent;
      //if (Self.IsA('JCDentonMale'))
      //{
      //   MultiSkins[6] = Texture'BlackMaskTex';
      //   MultiSkins[7] = Texture'BlackMaskTex';
      //}
   }
   else if (!bMakeTranslucent)
   {
      //if (Self.IsA('JCDentonMale'))
      //{
      //   MultiSkins[6] = Default.MultiSkins[6];
      //   MultiSkins[7] = Default.MultiSkins[7];
      //}
      Style = Default.Style;
   }
}

simulated function CreatePlayerTracker()
{
   local CBPPlayerTrack PlayerTracker;

   PlayerTracker = Spawn(PlayerTrackClass);
   PlayerTracker.AttachedPlayer = Self;
}

function Carcass SpawnCarcass()
{
	local CBPCarcass Car;
	local Inventory Inv;
	local Vector Loc;

	if (CarcassType == none) return none; // no carcass

	if ( Health >= -80 )
	{
		Car = CBPCarcass(Spawn(CarcassType));
	}
	if (Car != None)
	{
		Car.Initfor(self);
		Loc = Location;
		Loc.Z = Loc.Z - CollisionHeight + Car.CollisionHeight;
		Car.SetLocation(Loc);
		Car.bPlayerCarcass = True;
		MoveTarget = Car;
	}

	while (Inventory != None)
	{
		Inv = Inventory;
		DeleteInventory(Inv);
		if (Car != None) Car.AddInventory(Inv);
		else Inv.Destroy();
	}

	return Car;
}

event HeadZoneChange(ZoneInfo newHeadZone)
{
	local float mult, augLevel;

	// hack to get the zone's ambientsound working until Tim fixes it
	if (newHeadZone.AmbientSound != None)
		newHeadZone.SoundRadius = 255;
	if (HeadRegion.Zone.AmbientSound != None)
		HeadRegion.Zone.SoundRadius = 0;

	if (newHeadZone.bWaterZone && !HeadRegion.Zone.bWaterZone)
	{
		// make sure we're not crouching when we start swimming
		bIsCrouching = False;
		bCrouchOn = False;
		bWasCrouchOn = False;
		bDuck = 0;
		lastbDuck = 0;
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		if (SkillSystem != none)
			mult = SkillSystem.GetSkillLevelValue(class'SkillSwimming');
		else mult = 1.0;

		swimDuration = PawnInfo.default.UnderWaterTime * mult;
		swimTimer = swimDuration;

		augLevel = -1.0;
		if ( AugmentationSystem != None )
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugAqualung');
		if ( augLevel == -1.0 )
			WaterSpeed = PawnInfo.Default.WaterSpeed * mult;
		else
			WaterSpeed = PawnInfo.Default.WaterSpeed * 2.0 * mult;
	}

	Super(PlayerPawnExt).HeadZoneChange(newHeadZone);
}

simulated function int GetMPHitLocation (Vector S30)
{
	local float headOffsetZ;
	local float armOffset;
	local Vector Offset;

	Offset = S30 - Location << Rotation;
	headOffsetZ = CollisionHeight * 0.78;
	armOffset = CollisionRadius * 0.35;
	if (Offset.Z > headOffsetZ)
	{
		return 1;
	} else {
		if ( Offset.Z < 0.00 )
		{
			if ( Offset.Y > 0.00 )
			{
				return 4;
			} else {
				return 3;
			}
		} else {
			if ( Offset.Y > armOffset )
			{
				return 6;
			} else {
				if ( Offset.Y <  -armOffset )
				{
					return 5;
				} else {
					return 2;
				}
			}
		}
	}
	return 0;
}

function SetDamagePercent(float percent)
{
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	PawnInfo.static.Event_TakeDamage(self, Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

// ----------------------------------------------------------------------
// DXReduceDamage()
//
// Calculates reduced damage from augmentations and from inventory items
// Also calculates a scalar damage reduction based on the mission number
// ----------------------------------------------------------------------
function bool DXReduceDamage(int Damage, name damageType, vector hitLocation, out int adjustedDamage, bool bCheckOnly)
{
	local float newDamage;
	local float augLevel, skillLevel;
	local float pct;
	local HazMatSuit suit;
	local BallisticArmor armor;
	local bool bReduced;

	bReduced = False;
	newDamage = Float(Damage);

	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation') ||
		(damageType == 'HalonGas')  || (damageType == 'PoisonEffect') || (damageType == 'Poison'))
	{
		augLevel = -1.0;
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugEnviro');

		if (augLevel >= 0.0)
			newDamage *= augLevel;

		// get rid of poison if we're maxed out
		if (newDamage ~= 0.0)
		{
			StopPoison();
			drugEffectTimer -= 4;	// stop the drunk effect
			if (drugEffectTimer < 0)
				drugEffectTimer = 0;
		}
	}

	if (damageType == 'HalonGas')
	{
		if (bOnFire && !bCheckOnly)
			ExtinguishFire();
	}

	if ((damageType == 'Shot') || (damageType == 'AutoShot'))
	{
		augLevel = -1.0;
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugBallistic');

		if (augLevel >= 0.0)
			newDamage *= augLevel;
	}

	if (damageType == 'EMP')
	{
		augLevel = -1.0;
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugEMP');

		if (augLevel >= 0.0)
			newDamage *= augLevel;
	}

	if ((damageType == 'Burned') || (damageType == 'Flamed') ||
		(damageType == 'Exploded') || (damageType == 'Shocked') ||
		damageType == 'Bite' || damageType == 'Bump' || damageType == 'Swipe')
	{
		augLevel = -1.0;
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugShield');

		if (augLevel >= 0.0)
			newDamage *= augLevel;
	}

	if (newDamage < Damage)
	{
		if (!bCheckOnly)
		{
			pct = 1.0 - (newDamage / Float(Damage));
			SetDamagePercent(pct);
			ClientFlash(0.01, vect(0, 0, 50));
		}
		bReduced = True;
	}
	else
	{
		if (!bCheckOnly)
			SetDamagePercent(0.0);
	}

	adjustedDamage = Int(newDamage);

	return bReduced;
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	// need to replicate to client too
	if (Role == ROLE_Authority && (GetPlayerPawn() != self))
		ClientPlayDying(damageType, HitLocation);
	PlayDying(damageType, HitLocation);
}

function ClientPlayDying(name damageType, vector HitLocation)
{
	PlayDying(damageType, HitLocation);
}

exec function Suicide()
{
	TakeDamage(100000.0, self, vect(0,0,0), vect(0,0,0), 'Suicided');
}

function RegularTakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	local byte VBE;
	local int actualDamage;
	local int MPHitLoc;
	local bool bAlreadyDead;
	local bool bPlayAnim;
	local bool bDamageGotReduced;
	local Vector Offset;
	local Vector dst;
	local float origHealth;
	local float fdst;
	local DeusExLevelInfo Info;
	local WeaponRifle VBF;
	local string bodyString;

	bodyString="";
	origHealth=Health;
	if ( Level.NetMode != 0 )
	{
		Damage *= MPDamageMult;
	}
	Offset=HitLocation - Location << Rotation;
	bDamageGotReduced=DXReduceDamage(Damage,DamageType,HitLocation,actualDamage,False);
	if ( ReducedDamageType == DamageType )
	{
		actualDamage=actualDamage * (1.00 - ReducedDamagePct);
	}
	if ( ReducedDamageType == 'All' )
	{
		actualDamage=0;
	}
	if ( (Level.Game != None) && (Level.Game.DamageMutator != None) )
	{
		Level.Game.DamageMutator.MutatorTakeDamage(actualDamage,self,instigatedBy,HitLocation,Momentum,DamageType);
	}
	if ( bNintendoImmunity || (actualDamage == 0) && (NintendoImmunityTimeLeft > 0.00) )
	{
		return;
	}
	if ( actualDamage < 0 )
	{
		return;
	}
	if ( DamageType == 'NanoVirus' )
	{
		return;
	}
	if ( (DamageType == 'Poison') || (DamageType == 'PoisonEffect') )
	{
		AddDamageDisplay('PoisonGas',Offset);
	} else {
		AddDamageDisplay(DamageType,Offset);
	}
	if ( (DamageType == 'Poison') || (Level.NetMode != 0) && (DamageType == 'TearGas') )
	{
		if ( Level.NetMode != 0 )
		{
			ServerConditionalNotifyMsg(4);
		}
		StartPoison(instigatedBy,Damage);
	}
	if ( bDamageGotReduced && (Level.NetMode != 0) )
	{
		ShieldStatus=SS_Strong;
		ShieldTimer=1.00;
	}
	if (DeusExPlayer(instigatedBy) != None)
	{
		VBF=WeaponRifle(DeusExPlayer(instigatedBy).Weapon);
		if ( (VBF != None) &&  !VBF.bZoomed && (VBF.Class == Class'WeaponRifle') )
		{
			actualDamage *= VBF.mpNoScopeMult;
		}
		if ( Level.Game.bTeamGame && (DeusExPlayer(instigatedBy) != self) && class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(instigatedBy),self))
		{
			actualDamage *= CBPGame(Level.Game).FriendlyFireMult;
			if ( (DamageType != 'TearGas') && (DamageType != 'PoisonEffect') )
			{
				DeusExPlayer(instigatedBy).MultiplayerNotifyMsg(2);
			}
		}
	}
	if ( DamageType == 'EMP' )
	{
		EnergyDrain += actualDamage;
		EnergyDrainTotal += actualDamage;
		PlayTakeHitSound(actualDamage,DamageType,1);
		return;
	}
	bPlayAnim=True;
	if ( (DamageType == 'Burned') || PlayerReplicationInfo.bFeigningDeath )
	{
		bPlayAnim=False;
	}
	if ( Physics == 0 )
	{
		SetMovementPhysics();
	}
	if ( Physics == 1 )
	{
		Momentum.Z=0.40 * VSize(Momentum);
	}
	if ( instigatedBy == self )
	{
		Momentum *= 0.60;
	}
	Momentum=Momentum / Mass;
	MPHitLoc=GetMPHitLocation(HitLocation);
	if ( MPHitLoc == 0 )
	{
		return;
	} else {
		if ( MPHitLoc == 1 )
		{
			bodyString=HeadString;
			if ( bPlayAnim )
			{
				PawnInfo.static.PlayAnimation_HitHead(self);
			}
			if ( Level.NetMode != 0 )
			{
				actualDamage *= 2;
				HealthHead -= actualDamage;
			} else {
				HealthHead -= actualDamage * 2;
			}
		} else {
			if ( (MPHitLoc == 3) || (MPHitLoc == 4) )
			{
				bodyString=TorsoString;
				if ( MPHitLoc == 4 )
				{
					if ( bPlayAnim )
					{
						PawnInfo.static.PlayAnimation_HitLegRight(self);
					}
				} else {
					if ( bPlayAnim )
					{
						PawnInfo.static.PlayAnimation_HitLegLeft(self);
					}
				}
				if ( Level.NetMode != 0 )
				{
					HealthLegRight -= actualDamage;
					HealthLegLeft -= actualDamage;
					if ( HealthLegLeft < 0 )
					{
						HealthArmRight += HealthLegLeft;
						HealthTorso += HealthLegLeft;
						HealthArmLeft += HealthLegLeft;
						HealthLegLeft=0;
						HealthLegRight=0;
					}
				} else {
					if ( MPHitLoc == 4 )
					{
						HealthLegRight -= actualDamage;
					} else {
						HealthLegLeft -= actualDamage;
					}
					if ( (HealthLegRight < 0) && (HealthLegLeft > 0) )
					{
						HealthLegLeft += HealthLegRight;
						HealthLegRight=0;
					} else {
						if ( (HealthLegLeft < 0) && (HealthLegRight > 0) )
						{
							HealthLegRight += HealthLegLeft;
							HealthLegLeft=0;
						}
					}
					if ( HealthLegLeft < 0 )
					{
						HealthTorso += HealthLegLeft;
						HealthLegLeft=0;
					}
					if ( HealthLegRight < 0 )
					{
						HealthTorso += HealthLegRight;
						HealthLegRight=0;
					}
				}
			} else {
				bodyString=TorsoString;
				if ( MPHitLoc == 6 )
				{
					if ( bPlayAnim )
					{
						PawnInfo.static.PlayAnimation_HitArmRight(self);
					}
				} else {
					if ( MPHitLoc == 5 )
					{
						if ( bPlayAnim )
						{
							PawnInfo.static.PlayAnimation_HitArmLeft(self);
						}
					} else {
						if ( bPlayAnim )
						{
							PawnInfo.static.PlayAnimation_HitTorso(self);
						}
					}
				}
				if ( Level.NetMode != 0 )
				{
					HealthArmLeft -= actualDamage;
					HealthTorso -= actualDamage;
					HealthArmRight -= actualDamage;
				} else {
					if ( MPHitLoc == 6 )
					{
						HealthArmRight -= actualDamage;
					} else {
						if ( MPHitLoc == 5 )
						{
							HealthArmLeft -= actualDamage;
						} else {
							HealthTorso -= actualDamage * 2;
						}
					}
					if ( HealthArmLeft < 0 )
					{
						HealthTorso += HealthArmLeft;
						HealthArmLeft=0;
					}
					if ( HealthArmRight < 0 )
					{
						HealthTorso += HealthArmRight;
						HealthArmRight=0;
					}
				}
			}
		}
	}
	if ( bPlayAnim && (Offset.X < 0.00) )
	{
		if ( MPHitLoc == 1 )
		{
			PawnInfo.static.PlayAnimation_HitHeadBack(self);
		} else {
			PawnInfo.static.PlayAnimation_HitTorsoBack(self);
		}
	}
	if ( bPlayAnim && Region.Zone.bWaterZone )
	{
		if ( Offset.X < 0.00 )
		{
			PawnInfo.static.PlayAnimation_WaterHitTorsoBack(self);
		} else {
			PawnInfo.static.PlayAnimation_WaterHitTorso(self);
		}
	}
	GenerateTotalHealth();
	if ( (DamageType != 'Stunned') && (DamageType != 'TearGas') && (DamageType != 'HalonGas') && (DamageType != 'PoisonGas') && (DamageType != 'Radiation') && (DamageType != 'EMP') && (DamageType != 'NanoVirus') && (DamageType != 'Drowned') && (DamageType != 'KnockedOut') )
	{
		BleedRate += (origHealth - Health) / 30.00;
	}
	if ( carriedDecoration != None )
	{
		DropDecoration();
	}
	if ( (Level.NetMode == 0) && (Health <= 0) )
	{
		Info=GetLevelInfo();
		if ( (Info != None) && (Info.missionNumber == 0) )
		{
			HealthTorso=FMax(HealthTorso,10.00);
			HealthHead=FMax(HealthHead,10.00);
			GenerateTotalHealth();
		}
	}
	if ( Health > 0 )
	{
		if ( (Level.NetMode != 0) && (HealthLegLeft == 0) && (HealthLegRight == 0) )
		{
			ServerConditionalNotifyMsg(10);
		}
		if ( instigatedBy != None )
		{
			damageAttitudeTo(instigatedBy);
		}
		PlayDXTakeDamageHit(actualDamage,HitLocation,DamageType,Momentum,bDamageGotReduced);
	}
	else
	{
		bIsAlive = false;
		NextState='None';
		PlayDeathHit(actualDamage,HitLocation,DamageType,Momentum);

		MyLastKiller = CBPPlayer(instigatedBy);
		if (MyLastKiller == none && damageType == 'Suicided')
			MyLastKiller = self;
		KilledWeapon = DeusExWeapon(MyLastKiller.inHand);

		CreateKillerProfile(instigatedBy,actualDamage,DamageType,bodyString);

		if ( actualDamage > Mass )
		{
			Health=-1 * actualDamage;
		}
		Enemy=instigatedBy;
		Died(instigatedBy,DamageType,HitLocation);
		return;
	}
	MakeNoise(1.00);
	if ( (DamageType == 'Flamed') &&  !bOnFire )
	{
		if ( Level.NetMode != 0 )
		{
			ServerConditionalNotifyMsg(5);
		}
		CatchFire(instigatedBy);
	}

	myProjKiller=None;
}

// todo: fix this when using CBP weapons
function GetWeaponName(DeusExWeapon w, out String name)
{
	if ( w != None )
	{
		if ( CBPWeaponGEPGun(w) != None )
			name = CBPWeaponGEPGun(w).shortName;
		else if ( CBPWeaponLAM(w) != None )
			name = CBPWeaponLAM(w).shortName;
		else
			name = w.itemName;
	}
	else
		name = NoneString;
}

// killer profile not yet supported
// just create KilledMethod string
function CreateKillerProfile( Pawn killer, int damage, name damageType, String bodyPart )
{
	local DeusExProjectile proj;
	local DeusExDecoration decProj;
	local string wShortString;

	KilledMethod = NoneString;

	switch( damageType )
	{
		//case 'AutoShot':
		//	killProfile.methodStr = WithTheString $ AutoTurret(myTurretKiller).titleString  $ "!";
		//	killProfile.bTurretKilled = True;
		//	killProfile.killerLoc = AutoTurret(myTurretKiller).Location;
		//	if ( pkiller.SkillSystem != None )
		//	{
		//		killProfile.activeSkill = class'SkillComputer'.Default.skillName;
		//		killProfile.activeSkillLevel = pkiller.SkillSystem.GetSkillLevel(class'SkillComputer');
		//	}
		//	break;
		case 'Fell':
			KilledMethod = " with deadly fall!";
			break;
		case 'ThrownDecoration':
			KilledMethod = " with thrown decoration!";
			break;
		case 'AutoShot':
			KilledMethod = " with Auto Turret!";
			break;
		case 'Suicided':
			KilledMethod = " (suicide).";
			break;
		case 'Bite':
			KilledMethod = " with deadly bite!";
			break;
		case 'Swipe':
			KilledMethod = " with deadly swipe!";
			break;
		case 'Bump':
			KilledMethod = " with deadly bump!";
			break;
		case 'Radiation':
			if (myProjKiller == none)
				KilledMethod = " with deadly radiation!";
			break;
		case 'PoisonEffect':
			KilledMethod = PoisonString $ "!";
			break;
		case 'Burned':
		case 'Flamed':
			if (( WeaponPlasmaRifle(KilledWeapon) != None ) || ( CBPWeaponFlamethrower(KilledWeapon) != None ))
			{
				// Use the weapon if it's still in hand
			}
			else
			{
				KilledMethod = BurnString $ "!";
			}
			break;
	}

	if ( KilledMethod ~= NoneString )
	{
		proj = DeusExProjectile(myProjKiller);
		decProj = DeusExDecoration(myProjKiller);

		if (( killer != None ) && (proj != None) && (!(proj.itemName ~= "")) )
		{
			KilledMethod = WithString $ proj.itemArticle $ " " $ proj.itemName $ "!";
		}
		else if (( killer != None ) && ( decProj != None ) && (!(decProj.itemName ~= "" )) )
		{
			KilledMethod = WithString $ decProj.itemArticle $ " " $ decProj.itemName $ "!";
		}
		if ((killer != None) && (KilledWeapon != None))
		{
			GetWeaponName(KilledWeapon, wShortString);
			KilledMethod = WithString $ KilledWeapon.itemArticle $ " " $ wShortString $ "!";
		}
		else
			log("Warning: Failed to determine killer method killer:"$killer$" damage:"$damage$" damageType:"$damageType$" " );
	}

	if ( KilledMethod ~= NoneString )
	{
		log("===>Warning: Failed to get killer method:"$Self$" damageType:"$damageType$" " );
		killProfile.bValid = False;
	}
}


function bool HandleItemPickup (Actor FrobTarget, optional bool bSearchOnly)
{
	local bool VB4;
	local bool bCanPickup;
	local bool VB5;
	local Inventory foundItem;

	VB5=True;
	bCanPickup=True;
	VB4=False;
	//if ( V7B )
	//{
	//	if ( FrobTarget.IsA('DeusExWeapon') )
	//	{
	//		DeusExWeapon(FrobTarget).PickupAmmoCount=1;
	//		DeusExWeapon(FrobTarget).mpPickupAmmoCount=1;
	//	} else {
	//		if ( FrobTarget.IsA('Ammo') )
	//		{
	//			Ammo(FrobTarget).AmmoAmount=1;
	//		}
	//	}
	//}
	if ( FrobTarget.IsA('DataVaultImage') || FrobTarget.IsA('NanoKey') || FrobTarget.IsA('Credits') )
	{
		VB5=False;
	} else {
		if ( FrobTarget.IsA('DeusExPickup') )
		{
			if ( (FindInventoryType(FrobTarget.Class) != None) && DeusExPickup(FrobTarget).bCanHaveMultipleCopies )
			{
				VB5=False;
			}
		} else {
			foundItem=GetWeaponOrAmmo(Inventory(FrobTarget));
			if ( foundItem != None )
			{
				VB5=False;
				if ( foundItem.IsA('Ammo') )
				{
					if ( Ammo(foundItem).AmmoAmount >= Ammo(foundItem).MaxAmmo )
					{
						ClientMessage(TooMuchAmmo);
						bCanPickup=False;
					}
				} else {
					if ( foundItem.IsA('CBPWeaponEMP') || foundItem.IsA('CBPWeaponGasGrenade') || foundItem.IsA('WeaponNanoVirusGrenade') || foundItem.IsA('CBPWeaponLAM') )
					{
						if ( DeusExWeapon(foundItem).AmmoType.AmmoAmount >= DeusExWeapon(foundItem).AmmoType.MaxAmmo )
						{
							ClientMessage(TooMuchAmmo);
							bCanPickup=False;
						}
					} else {
						if ( foundItem.IsA('Weapon') )
						{
							bCanPickup= !(Weapon(foundItem).ReloadCount == 0) && (Weapon(foundItem).PickupAmmoCount == 0) && (Weapon(foundItem).AmmoName != None);
							if (  !bCanPickup )
							{
								ClientMessage(Sprintf(CanCarryOnlyOne,foundItem.ItemName));
							}
						}
					}
				}
			}
			//else
			//{
			//	if ( V7B )
			//	{
			//		VB4=True;
			//	}
			//}
		}
	}
	if ( VB5 && bCanPickup )
	{
		if ( FindInventorySlot(Inventory(FrobTarget),bSearchOnly) == False )
		{
			ClientMessage(Sprintf(InventoryFull,Inventory(FrobTarget).ItemName));
			bCanPickup=False;
			ServerConditionalNotifyMsg(11);
		}
	}
	if ( bCanPickup )
	{
		if ( (Level.NetMode != 0) && (FrobTarget.IsA('DeusExWeapon') || FrobTarget.IsA('DeusExAmmo')) )
		{
			PlaySound(Sound'WeaponPickup',SLOT_Interact,0.50 + FRand() * 0.25,,256.00,0.95 + FRand() * 0.10);
		}
		DoFrob(self,inHand);
		if ( Level.NetMode != 0 )
		{
			if ( FrobTarget.IsA('DeusExWeapon') && (DeusExWeapon(FrobTarget).PickupAmmoCount == 0) )
			{
				DeusExWeapon(FrobTarget).PickupAmmoCount=DeusExWeapon(FrobTarget).Default.mpPickupAmmoCount * 3;
			}
		}
		if ( VB4 )
		{
			foundItem=GetWeaponOrAmmo(Inventory(FrobTarget));
			if ( DeusExWeapon(foundItem) != None )
			{
				DeusExWeapon(foundItem).AmmoType.AmmoAmount=1;
			}
		}
	}
	//V7B=False;
	return bCanPickup;
}


function Died(pawn Killer, name damageType, vector HitLocation)
{
	PawnInfo.static.Event_Died(self, HitLocation);
	super.Died(Killer, damageType, HitLocation);
}

function Bump(Actor other)
{
	PawnInfo.static.Event_Bump(self, other);
	super.Bump(other);
}

function bool IsFrobbable(actor A) { return PawnInfo.static.IsFrobbable(self, A); }
exec function AltFire(optional float F) { PawnInfo.static.Exec_AltFire(self, F); }
exec function Fire(optional float F) { PawnInfo.static.Exec_Fire(self, F); }
exec function ParseLeftClick() { PawnInfo.static.Exec_ParseLeftClick(self); }
exec function ParseRightClick() { PawnInfo.static.Exec_ParseRightClick(self); }
function RegularParseLeftClick() { super.ParseLeftClick(); }
function RegularParseRightClick() { super.ParseRightClick(); }
function RegularFire( optional float F ) { super.Fire(F); }
function RegularAltFire( optional float F ) { super.AltFire(F); }

function Timer();

function CatchFire( Pawn burner )
{
	local Fire f;
	local int i;
	local vector loc;

	myBurner = burner;

	burnTimer = 0;

   if (bOnFire || Region.Zone.bWaterZone)
		return;

	bOnFire = True;
	burnTimer = 0;

	for (i=0; i<8; i++)
	{
		loc.X = 0.5*CollisionRadius * (1.0-2.0*FRand());
		loc.Y = 0.5*CollisionRadius * (1.0-2.0*FRand());
		loc.Z = 0.6*CollisionHeight * (1.0-2.0*FRand());
		loc += Location;

      // DEUS_EX AMSD reduce the number of smoke particles in multiplayer
      // by creating smokeless fire (better for server propagation).
      if ((Level.NetMode == NM_Standalone) || (i <= 0))
         f = Spawn(class'Fire', Self,, loc);
      else
         f = Spawn(class'SmokelessFire', Self,, loc);

		if (f != None)
		{
			f.DrawScale = 0.5*FRand() + 1.0;

         //DEUS_EX AMSD Reduce the penalty in multiplayer
         if (Level.NetMode != NM_Standalone)
            f.DrawScale = f.DrawScale * 0.5;

			// turn off the sound and lights for all but the first one
			if (i > 0)
			{
				f.AmbientSound = None;
				f.LightType = LT_None;
			}

			// turn on/off extra fire and smoke
         // MP already only generates a little.
			if ((FRand() < 0.5) && (Level.NetMode == NM_Standalone))
				f.smokeGen.Destroy();
			if ((FRand() < 0.5) && (Level.NetMode == NM_Standalone))
				f.AddFire();
		}
	}

	LastBurnTime = Level.TimeSeconds;
}

function ExtinguishFire()
{
	local Fire f;

	bOnFire = False;
	burnTimer = 0;

	foreach BasedActors(class'Fire', f)
		f.Destroy();
}

function ClientDeath()
{
   if (!PlayerIsClient())
      return;

   FlashTimer = 0;

   if (BeltInventory != none)
	BeltInventory.Reset();

	// This should get rid of the scope death problem in multiplayer
	if (( DeusExRootWindow(rootWindow).scopeView != None ) && DeusExRootWindow(rootWindow).scopeView.bViewVisible )
	   DeusExRootWindow(rootWindow).scopeView.DeactivateView();

	if ( bOnFire )
		ExtinguishFire();

	// Don't come back to life drugged or posioned
	poisonCounter		= 0;
	poisonTimer			= 0;
	drugEffectTimer	= 0;

	// Don't come back to life crouched
	bCrouchOn			= False;
	bWasCrouchOn		= False;
	bIsCrouching		= False;
	bForceDuck			= False;
	lastbDuck			= 0;
	bDuck					= 0;

	// No messages carry over
	mpMsgCode = 0;
	mpMsgTime = 0;

   bleedrate = 0;
   dropCounter = 0;

}

function MaintainEnergy(float deltaTime)
{
	local Float energyUse;
   local Float energyRegen;

   if (AugmentationSystem == none) return;

	// make sure we can't continue to go negative if we take damage
	// after we're already out of energy
	if (Energy <= 0)
	{
		Energy = 0;
		EnergyDrain = 0;
		EnergyDrainTotal = 0;
	}

   energyUse = 0;

	// Don't waste time doing this if the player is dead or paralyzed
	if ((!IsInState('Dying')) && (!IsInState('Paralyzed')))
   {
      if (Energy > 0)
      {
         // Decrement energy used for augmentations
         energyUse = AugmentationSystem.CalcEnergyUse(deltaTime);

         Energy -= EnergyUse;

         // Calculate the energy drain due to EMP attacks
         if (EnergyDrain > 0)
         {
            energyUse = EnergyDrainTotal * deltaTime;
            Energy -= EnergyUse;
            EnergyDrain -= EnergyUse;
            if (EnergyDrain <= 0)
            {
               EnergyDrain = 0;
               EnergyDrainTotal = 0;
            }
         }
      }

      //Do check if energy is 0.
      // If the player's energy drops to zero, deactivate
      // all augmentations
      if (Energy <= 0)
      {
         //If we were using energy, then tell the client we're out.
         //Otherwise just make sure things are off.  If energy was
         //already 0, then energy use will still be 0, so we won't
         //spam.  DEUS_EX AMSD
         if (energyUse > 0)
            ClientMessage(EnergyDepleted);
         Energy = 0;
         EnergyDrain = 0;
         EnergyDrainTotal = 0;
         AugmentationSystem.DeactivateAll();
      }

      // If all augs are off, then start regenerating in multiplayer,
      // up to 25%.
      if ((energyUse == 0) && (Energy <= MaxRegenPoint) && (Level.NetMode != NM_Standalone))
      {
         energyRegen = RegenRate * deltaTime;
         Energy += energyRegen;
      }
	}
}

function SwimAnimUpdate(bool bNotForward)
{
	if (PawnInfo.static.PlayingAnimGroup_Attack(self)) return;

	if (!bAnimTransition && PawnInfo.static.PlayingAnimGroup_Gesture(self))
	{
		if ( bNotForward )
	 	{
		 	 if ( PawnInfo.static.PlayingAnimGroup_Waiting(self) )
				TweenToWaiting(0.1);
		}
		else if ( PawnInfo.static.PlayingAnimGroup_Waiting(self) )
			TweenToSwimming(0.1);
	}
}

state Dying
{
	exec function ShowMainMenu()
	{
		// reduce the white glow when the menu is up
		if (InstantFog != vect(0,0,0))
		{
			InstantFog   = vect(0.1,0.1,0.1);
			InstantFlash = 0.01;

			// force an update
			ViewFlash(1.0);
		}

		Global.ShowMainMenu();
	}

	function ServerReStartPlayer()
	{
		if (NextPawnInfo != PawnInfo)
		{
			SetPawnInfo(NextPawnInfo);
			InstallPawnInfo();
			log("Pawn type is: " $ PawnInfo);
		}

		super.ServerRestartPlayer();
	}

	exec function Fire(optional float F)
	{
		if (!bFrozen)
		{
			bCanRestart = false;
			ServerReStartPlayer();
		}
	}

	function Timer()
	{
		bFrozen = false;
		bCanRestart = true;

		if (GetPlayerPawn() == self && CBPGameReplicationInfo(GameReplicationInfo).ForceTeam != 255 &&
			CBPGameReplicationInfo(GameReplicationInfo).ForceTeam != PlayerReplicationInfo.Team)
		{
			ShowMainMenu();
		}
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		if ( bPressedJump )
		{
			Fire(0);
			bPressedJump = false;
		}
		GetAxes(ViewRotation,X,Y,Z);
		// Update view rotation.
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		{
			If (aLookUp > 0)
				ViewRotation.Pitch = 18000;
			else
				ViewRotation.Pitch = 49152;
		}
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function BeginState()
	{
		Super.BeginState();

		bCanRestart = false;
		bIsAlive = false;
		CBPPlayerReplicationInfo(PlayerReplicationInfo).bIsDead = true;

		bFrozen = true;
		bPressedJump=False;
		bJustFired=False;
		bJustAltFired=False;

		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}

		SetTimer(AfterDeathPause, false);

		if (Role == ROLE_Authority &&
			BeltInventory != none) BeltInventory.Reset();
	}

	simulated function EndState()
	{
		super.EndState();
		ShowHud(true);
	}

	function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
	{
		local vector ViewVect, HitLocation, HitNormal, whiteVec;
		local float ViewDist;
		local actor HitActor;
		local float time;

		ViewActor = Self;
		if (bHidden)
		{
			// spiral up and around carcass and fade to white in five seconds
			time = Level.TimeSeconds - FrobTime;

			if (MyLastKiller != none)
			{
				if (MyLastKiller != self)
					ViewVect = MyLastKiller.Location - Location;
				CameraLocation = Location;
				CameraRotation = Rotator(ViewVect);
			}
			else if (time < 8.0)
			{
				whiteVec.X = time / 16.0;
				whiteVec.Y = time / 16.0;
				whiteVec.Z = time / 16.0;
				CameraRotation.Pitch = -16384;
				CameraRotation.Yaw = (time * 8192.0) % 65536;
				ViewDist = 32 + time * 32;
				InstantFog = whiteVec;
				InstantFlash = 0.5;
				ViewFlash(1.0);
				// make sure we don't go through the ceiling
				ViewVect = vect(0,0,1);
				HitActor = Trace(HitLocation, HitNormal, Location + ViewDist * ViewVect, Location);
				if ( HitActor != None )
					CameraLocation = HitLocation;
				else
					CameraLocation = Location + ViewDist * ViewVect;
			}
			else
			{
				// make sure we don't go through the ceiling
				ViewVect = vect(0,0,1);
				HitActor = Trace(HitLocation, HitNormal, Location + ViewDist * ViewVect, Location);
				if ( HitActor != None )
					CameraLocation = HitLocation;
				else
					CameraLocation = Location + ViewDist * ViewVect;
			}
		}
		else
		{
			// use FrobTime as the cool DeathCam timer
			FrobTime = Level.TimeSeconds;

			// make sure we don't go through the wall
		    ViewDist = 190;
			ViewVect = vect(1,0,0) >> Rotation;
			HitActor = Trace( HitLocation, HitNormal,
					Location - ViewDist * vector(CameraRotation), Location, false, vect(12,12,2));
			if ( HitActor != None )
				CameraLocation = HitLocation;
			else
				CameraLocation = Location - ViewDist * ViewVect;
		}
	}

Begin:
	if (DeusExWeapon(inHand) != None)
	{
		DeusExWeapon(inHand).bZoomed=False;
		DeusExWeapon(inHand).RefreshScopeDisplay(self,True,False);
		if ( Level.NetMode == 3 )
		{
			DeusExWeapon(inHand).GotoState('SimIdle');
		} else {
			DeusExWeapon(inHand).GotoState('Idle');
		}
	}

	if (DeusExRootWindow(RootWindow) != None )
	{
		if ( (DeusExRootWindow(RootWindow).HUD != None) && (DeusExRootWindow(RootWindow).HUD.augDisplay != None) )
		{
			DeusExRootWindow(RootWindow).HUD.augDisplay.bVisionActive=False;
			DeusExRootWindow(RootWindow).HUD.augDisplay.activeCount=0;
		}
		if ( DeusExRootWindow(RootWindow).scopeView != None )
		{
			DeusExRootWindow(RootWindow).scopeView.DeactivateView();
		}
	}
	UnderWaterTime = PawnInfo.Default.UnderWaterTime;
	SetCollision(True,True,True);
	SetPhysics(PHYS_Walking);
	bCollideWorld = True;
	BaseEyeHeight = PawnInfo.Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	poisonCounter = 0;
	poisonTimer = 0.00;
	drugEffectTimer = 0.00;
	bCrouchOn = False;
	bWasCrouchOn = False;
	bIsCrouching = False;
	bForceDuck = False;
	lastbDuck = 0;
	bDuck = 0;
	FrobTime = Level.TimeSeconds;
	bBehindView = True;
	Velocity = vect(0.00,0.00,0.00);
	Acceleration = vect(0.00,0.00,0.00);
	DesiredFOV = DefaultFOV;
	FinishAnim();
	KillShadow();
	FlashTimer = 0.00;
	bHidden = True;
	SpawnCarcass();
	HidePlayer();
}

state PlayerSwimming
{
	function BeginState()
	{
		local float mult, augLevel;

		bIsAlive = true;
		CBPPlayerReplicationInfo(PlayerReplicationInfo).bIsDead = false;

		// set us to be two feet high
		SetBasedPawnSize(PawnInfo.Default.CollisionRadius, PawnInfo.Default.SwimmingCollisionHeight);

		// get our skill info
		if (SkillSystem != none)
			mult = SkillSystem.GetSkillLevelValue(class'SkillSwimming');
		else mult = 1.0;

		swimDuration = PawnInfo.default.UnderWaterTime * mult;
		swimTimer = swimDuration;
		swimBubbleTimer = 0;

		augLevel = -1.0;
		if ( AugmentationSystem != None )
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugAqualung');
		if ( augLevel == -1.0 )
			WaterSpeed = PawnInfo.Default.WaterSpeed * mult;
		else
			WaterSpeed = PawnInfo.Default.WaterSpeed * 2.0 * mult;

		Super(PlayerPawnExt).BeginState();
	}

	function AnimEnd()
	{
		local vector X,Y,Z;
		GetAxes(Rotation, X,Y,Z);
		if ( (Acceleration Dot X) <= 0 )
		{
			if (PawnInfo.static.PlayingAnimGroup_TakeHit(self))
			{
				bAnimTransition = true;
				TweenToWaiting(0.2);
			}
			else
				PlayWaiting();
		}
		else
		{
			if (PawnInfo.static.PlayingAnimGroup_TakeHit(self))
			{
				bAnimTransition = true;
				TweenToSwimming(0.2);
			}
			else
				PlaySwimming();
		}
	}

	event PlayerTick(float deltaTime)
	{
		local Vector pos;

		RefreshSystems(deltaTime);
		DrugEffects(deltaTime);
		HighlightCenterObject();
		UpdateDynamicMusic(deltaTime);
		MultiplayerTick(deltaTime);
		FrobTime += deltaTime;

		if ( bOnFire )
		{
			ExtinguishFire();
		}

		FloorMaterial=GetFloorMaterial();
		WallMaterial=GetWallMaterial(WallNormal);

		if ( Role == ROLE_Authority )
		{
			if ( swimTimer > 0 )
			{
				PainTime=swimTimer;
			}
		}

		CheckActorDistances();
		swimBubbleTimer += deltaTime;
		if ( swimBubbleTimer >= 0.20 )
		{
			swimTimer = FMax(0.00, swimTimer - swimBubbleTimer);
			swimBubbleTimer = 0.00;
			if (FRand() < 0.40)
			{
				pos = Location + VRand() * 4;
				pos += vector(ViewRotation) * CollisionRadius * 2;
				pos.Z += CollisionHeight * 0.90;
				Spawn(Class'CBPAirBubble', self, , pos);
			}
		}
		UpdateTimePlayed(deltaTime);
		if (bUpdatePosition)
		{
			ClientUpdatePosition();
		}
		PlayerMove(deltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		//add bobbing when swimming
		if ( !bShowMenu )
		{
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
		}

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		bPressedJump = false;
	}

}

state PlayerWalking
{
	function BeginState()
	{
		super.BeginState();
		bIsAlive = true;
		CBPPlayerReplicationInfo(PlayerReplicationInfo).bIsDead = false;
	}

	event PlayerTick(float deltaTime)
	{
		super.PlayerTick(deltaTime);
	}

	exec function FeignDeath()
	{
	}

	function Timer()
	{
		BaseEyeHeight = PawnInfo.Default.BaseEyeHeight;
	}

	function AnimEnd()
	{
		bAnimTransition = false;
		if (Physics == PHYS_Walking)
		{
			if (bIsCrouching || bForceDuck)
			{
				if ( !bIsTurning && ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000) )
				{
					PlayDuck();
				}
				else
					PlayCrawling();
			}
			else
			{
				if ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
				{
					if (PawnInfo.static.PlayingAnimGroup_Waiting(self))
						PlayWaiting();
					else
					{
						bAnimTransition = true;
						TweenToWaiting(0.2);
					}
				}
				else if (bIsWalking)
				{
					if (PawnInfo.static.PlayingAnimGroup_Waiting(self) ||
						PawnInfo.static.PlayingAnimGroup_Gesture(self) ||
						PawnInfo.static.PlayingAnimGroup_TakeHit(self) ||
						PawnInfo.static.PlayingAnimGroup_Landing(self))
					{
						TweenToWalking(0.1);
						bAnimTransition = true;
					}
					else
						PlayWalking();
				}
				else
				{
					if (PawnInfo.static.PlayingAnimGroup_Waiting(self) ||
						PawnInfo.static.PlayingAnimGroup_Gesture(self) ||
						PawnInfo.static.PlayingAnimGroup_TakeHit(self) ||
						PawnInfo.static.PlayingAnimGroup_Landing(self))
					{
						bAnimTransition = true;
						TweenToRunning(0.1);
					}
					else
						PlayRunning();
				}
			}
		}
		else
			PlayInAir();
	}

	function ProcessMove (float deltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
		local int newSpeed, defSpeed;
		local name mat;
		local vector HitLocation, HitNormal, checkpoint, downcheck;
		local Actor HitActor, HitActorDown;
		local bool bCantStandUp;
		local Vector loc, traceSize;
		local float alpha, maxLeanDist;
		local float legTotal, weapSkill;
		local vector OldAccel;

		aExtra0 = 0.00;
		bCanLean = False;
		curLeanDist = 0.00;
		prevLeanDist = 0.00;

		// if the spy drone augmentation is active
		if (bSpyDroneActive)
		{
			if ( aDrone != None )
			{
				// put away whatever is in our hand
				if (inHand != None)
					PutInHand(None);

				// make the drone's rotation match the player's view
				aDrone.SetRotation(ViewRotation);

				// move the drone
				// CBP: added support for drone speed
				loc = Normal((aUp * vect(0,0,1) + aForward * vect(1,0,0) + aStrafe * vect(0,1,0)) >> ViewRotation) * DroneSpeedMulti;

				// opportunity for client to translate movement to server
				MoveDrone( DeltaTime, loc );

				// freeze the player
				Velocity = vect(0,0,0);
			}
			return;
		}

		defSpeed = GetCurrentGroundSpeed();

      // crouching makes you two feet tall
		if (bIsCrouching || bForceDuck)
		{
			SetBasedPawnSize(PawnInfo.Default.CollisionRadius, PawnInfo.Default.CrouchingCollisionHeight);

			// check to see if we could stand up if we wanted to
			checkpoint = Location;
			// check normal standing height
			checkpoint.Z = checkpoint.Z - CollisionHeight + 2 * GetDefaultCollisionHeight();
			traceSize.X = CollisionRadius;
			traceSize.Y = CollisionRadius;
			traceSize.Z = 1;
			HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, True, traceSize);
			if (HitActor == None)
				bCantStandUp = False;
			else
				bCantStandUp = True;
		}
		else
		{
			GroundSpeed = defSpeed;
			ResetBasedPawnSize();
		}

		if (bCantStandUp)
			bForceDuck = True;
		else
			bForceDuck = False;

		// if the player's legs are damaged, then reduce our speed accordingly
		newSpeed = defSpeed;

		// let the player pull themselves along with their hands even if both of
		// their legs are blown off
		if ((HealthLegLeft < 1) && (HealthLegRight < 1))
		{
			newSpeed = defSpeed * 0.8;
			bIsWalking = True;
			bForceDuck = True;
		}
		// make crouch speed faster than normal
		else if (bIsCrouching || bForceDuck)
		{
			bIsWalking = True;
		}

		// slow the player down if he's carrying something heavy
		if (CarriedDecoration != None)
		{
			newSpeed -= CarriedDecoration.Mass * 2;
		}
		// don't slow the player down if he's skilled at the corresponding weapon skill
		else if ((DeusExWeapon(Weapon) != None) && (Weapon.Mass > 30) && (DeusExWeapon(Weapon).GetWeaponSkill() > -0.25) && (Level.NetMode==NM_Standalone))
		{
			bIsWalking = True;
			newSpeed = defSpeed;
		}
		else if ((inHand != None) && inHand.IsA('POVCorpse'))
		{
			newSpeed -= inHand.Mass * 3;
		}

		// Multiplayer movement adjusters
		if ( Weapon != None )
		{
			weapSkill = DeusExWeapon(Weapon).GetWeaponSkill();
			// Slow down heavy weapons in multiplayer
			if ((DeusExWeapon(Weapon) != None) && (Weapon.Mass > 30) )
			{
				newSpeed = defSpeed;
				newSpeed -= ((( Weapon.Mass - 30.0 ) / (class'WeaponGEPGun'.Default.Mass - 30.0 )) * (0.70 + weapSkill) * defSpeed );
			}
			// Slow turn rate of GEP gun in multiplayer to discourage using it as the most effective close quarters weapon
			if ((CBPWeaponGEPGun(Weapon) != None) && (!CBPWeaponGEPGun(Weapon).bZoomed))
				TurnRateAdjuster = FClamp( 0.20 + -(weapSkill*0.5), 0.25, 1.0 );
			else
				TurnRateAdjuster = 1.0;
		}
		else
			TurnRateAdjuster = 1.0;

		// if we are moving really slow, force us to walking
		if ((newSpeed <= defSpeed / 3) && !bForceDuck)
		{
			bIsWalking = True;
			newSpeed = defSpeed;
		}

		GroundSpeed = FMax(newSpeed, 100);

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );

		if ( bPressedJump )
			DoJump();
		if (Physics == PHYS_Walking && !PawnInfo.static.PlayingAnimGroup_Attack(self))
		{
			if (!bIsCrouching)
			{
				if (bDuck != 0)
				{
					bIsCrouching = true;
					PlayDuck();
				}
			}
			else if (bDuck == 0)
			{
				OldAccel = vect(0,0,0);
				bIsCrouching = false;
				TweenToRunning(0.1);
			}

			if ( !bIsCrouching && !bForceDuck)
			{
				if ( (!bAnimTransition || (AnimFrame > 0)) && AnimSequence != 'Land')
				{
					if ( Acceleration != vect(0,0,0) )
					{
						if (PawnInfo.static.PlayingAnimGroup_Waiting(self) ||
							PawnInfo.static.PlayingAnimGroup_Gesture(self) ||
							PawnInfo.static.PlayingAnimGroup_TakeHit(self) )
						{
							bAnimTransition = true;
							TweenToRunning(0.1);
						}
					}
			 		else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
						&& !PawnInfo.static.PlayingAnimGroup_Gesture(self) )
			 		{
			 			if ( PawnInfo.static.PlayingAnimGroup_Waiting(self) )
			 			{
							if ( bIsTurning && (AnimFrame >= 0) )
							{
								bAnimTransition = true;
								PlayTurning();
							}
						}
			 			else if ( !bIsTurning )
						{
							bAnimTransition = true;
							TweenToWaiting(0.2);
						}
					}
				}
			}
			else
			{
				if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
					PlayCrawling();
			 	else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
			 	{
					PlayDuck();
			 	}
			}
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		NewAccel.Z = 0;

		if ( (Physics == PHYS_Walking))
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					ViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}

			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			//add bobbing when walking
			if ( !bShowMenu )
				CheckBob(DeltaTime, Speed2D, Y);

		}
		else if ( !bShowMenu )
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}
}

simulated function MoveDrone (float VC5, Vector VC6)
{
	if ( aDrone != None )
	{
		Super.MoveDrone(VC5,VC6);
	}
}

function DroneExplode()
{
	local Augmentation anAug;

	if (aDrone != None)
	{
		aDrone.Explode(aDrone.Location, vect(0,0,1));
		if (Role == ROLE_Authority && AugmentationSystem != none)
		{
			anAug = AugmentationSystem.FindAugmentation(class'AugDrone');
			if (anAug != None) anAug.Deactivate();
		}
	}
}


function ForceDroneOff()
{
	local Augmentation anAug;

	if (Role == ROLE_Authority && AugmentationSystem != none)
	{
		anAug = AugmentationSystem.FindAugmentation(class'AugDrone');
		if (anAug != None) anAug.Deactivate();
	}
}


state CBPGameEnded
{
	ignores ShowScores, ActivateAugmentation, DualmapF3, DualmapF4, DualmapF5, DualmapF6, DualmapF7, DualmapF8, DualmapF9, DualmapF10, DualmapF11, DualmapF12,
		TakeDamage, Died, ZoneChange, FootZoneChange, PlayerSpectate, SpectatorPlay, Fire, AltFire, ParseLeftClick, ParseRightClick, Multiplayertick, PlayerSetPawnType;

	exec function ShowMainMenu()
	{
		ConsoleCommand("disconnect");
	}

	event PlayerTick(float DeltaTime)
	{
		if (bUpdatePosition)
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		//GetAxes(ViewRotation,X,Y,Z);
		//// Update view rotation.

		//if ( !bFixedCamera )
		//{
		//	aLookup  *= 0.24;
		//	aTurn    *= 0.24;
		//	ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		//	ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
		//	ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		//	If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		//	{
		//		If (aLookUp > 0)
		//			ViewRotation.Pitch = 18000;
		//		else
		//			ViewRotation.Pitch = 49152;
		//	}
		//}
		//else if ( ViewTarget != None )
		//	ViewRotation = ViewTarget.Rotation;

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ServerMove
	(
		float TimeStamp,
		vector InAccel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							bFired, bAltFired, bForceFire, bForceAltFire, DodgeMove, ClientRoll, (32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)) );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			if ( ViewTarget != None )
				cameraLoc = ViewTarget.Location;
			else
				cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
	}

	function BeginState()
	{
		EndZoom();
		AnimRate = 0.0;
		SimAnim.Y = 0;
		bFire = 0;
		bAltFire = 0;
		SetCollision(false,false,false);
		bShowScores = true;
		bIsAlive = false;
		SetPhysics(PHYS_None);
		if (CBPPlayerReplicationInfo(PlayerReplicationInfo) != none)
			CBPPlayerReplicationInfo(PlayerReplicationInfo).bIsDead = false;
		LightType = default.LightType;
		LightBrightness = default.LightBrightness;
		LightHue = default.LightHue;
		LightSaturation = default.LightSaturation;
		LightRadius = default.LightRadius;
		ScaleGlow = default.ScaleGlow;
		AmbientSound = none;
		bOnFire = false;
		GameEndedTime = Level.TimeSeconds;
		bCollideWorld = false;
		EyeHeight = BaseEyeHeight;
		poisonCounter = 0;
		poisonTimer = 0.00;
		drugEffectTimer = 0.00;
		bCrouchOn = False;
		bWasCrouchOn = False;
		bIsCrouching = False;
		bForceDuck = False;
		lastbDuck = 0;
		bDuck = 0;
		if (DeusExWeapon(inHand) != None)
		{
			DeusExWeapon(inHand).bZoomed=False;
			DeusExWeapon(inHand).RefreshScopeDisplay(self,True,False);
			if ( Level.NetMode == 3 )
			{
				DeusExWeapon(inHand).GotoState('SimIdle');
			} else {
				DeusExWeapon(inHand).GotoState('Idle');
			}
		}

		if (DeusExRootWindow(RootWindow) != None )
		{
			if ( (DeusExRootWindow(RootWindow).HUD != None) && (DeusExRootWindow(RootWindow).HUD.augDisplay != None) )
			{
				DeusExRootWindow(RootWindow).HUD.augDisplay.bVisionActive=False;
				DeusExRootWindow(RootWindow).HUD.augDisplay.activeCount=0;
			}
			if ( DeusExRootWindow(RootWindow).scopeView != None )
			{
				DeusExRootWindow(RootWindow).scopeView.DeactivateView();
			}
			DeusExRootWindow(RootWindow).MaskBackground(True);
			ShowHud(false);
		}
		FrobTime = Level.TimeSeconds;
		bBehindView = false;
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);
		DesiredFOV = DefaultFOV;
		KillShadow();
		FlashTimer = 0.00;
		bHidden = True;
		HidePlayer();
	}
}



////////////////
// ANIMATIONS //
////////////////

function UpdateAnimRate( float augValue )
{
	if ( augValue == -1.0 )
		humanAnimRate = PawnInfo.default.MeshAnimRate;
	else
		humanAnimRate = PawnInfo.default.MeshAnimRate * augValue * 0.85;	// Scale back about 15% so were not too fast
}

function Bool IsFiring()
{
	if ((Weapon != None) && ( Weapon.IsInState('NormalFire') || Weapon.IsInState('ClientFiring') ) )
		return True;
	else
		return False;
}

function Bool HasTwoHandedWeapon()
{
	if ((Weapon != None) && (Weapon.Mass >= 30))
		return True;
	else
		return False;
}

//
// animation functions
//
function PlayPickupAnim(Vector locPickup)
{
	PawnInfo.static.PlayAnimation_Pickup(self, locPickup);
}

function PlayTurning()
{
	PawnInfo.static.PlayAnimation_Turning(self);
}

function TweenToWalking(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToWalking(self, tweentime);
}

function PlayWalking()
{
	PawnInfo.static.PlayAnimation_Walking(self, humanAnimRate);
}

function TweenToRunning(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToRunning(self, tweentime, humanAnimRate);
}

function PlayRunning()
{
	PawnInfo.static.PlayAnimation_Running(self, humanAnimRate);
}

function TweenToWaiting(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToWaiting(self, tweentime);
}

function PlayWaiting()
{
	PawnInfo.static.PlayAnimation_Waiting(self);
}

function PlaySwimming()
{
	PawnInfo.static.PlayAnimation_Swimming(self);
}

function TweenToSwimming(float tweentime)
{
	PawnInfo.static.PlayAnimation_TweenToSwimming(self, tweentime);
}

function PlayLanded(float impactVel)
{
	PawnInfo.static.PlayAnimation_Landed(self);
}

function PlayDuck()
{
	PawnInfo.static.PlayAnimation_Crouch(self);
}

function PlayRising()
{
	PawnInfo.static.PlayAnimation_Rising(self);
}

function PlayCrawling()
{
	PawnInfo.static.PlayAnimation_Crawling(self);
}

function PlayFiring()
{
	PawnInfo.static.PlayAnimation_Firing(self, DeusExWeapon(Weapon));
}

function PlayWeaponSwitch(Weapon newWeapon)
{
	PawnInfo.static.PlayAnimation_WeaponSwitch(self);
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

	GetAxes(Rotation, X, Y, Z);
	dotp = (Location - HitLoc) dot X;

	if (Region.Zone.bWaterZone)
	{
		PawnInfo.static.PlayAnimation_DeathWater(self);
	}
	else
	{
		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
			PawnInfo.static.PlayAnimation_DeathBack(self);
		else				// shot from the back, fall front
			PawnInfo.static.PlayAnimation_DeathFront(self);
	}

	PlayDyingSound();
}


//
// sound functions
//

function Gasp()
{
	PawnInfo.static.PlaySound_Gasp(self);
}

function PlayDyingSound()
{
	if (Region.Zone.bWaterZone)
		PawnInfo.static.PlaySound_WaterDeath(self);
	else
		PawnInfo.static.PlaySound_Death(self);
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float rnd;

	if ( Level.TimeSeconds - LastPainSound < FRand() + 0.5)
		return;

	LastPainSound = Level.TimeSeconds;

	if (Region.Zone.bWaterZone)
	{
		if (damageType == 'Drowned')
		{
			if (FRand() < 0.8)
				PawnInfo.static.PlaySound_Drown(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		}
		else
			PawnInfo.static.PlaySound_PainSmall(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	}
	else
	{
		// Body hit sound for multiplayer only
		if (((damageType=='Shot') || (damageType=='AutoShot'))  && ( Level.NetMode != NM_Standalone ))
		{
			PawnInfo.static.PlaySound_BodyHit(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		}

		if ((damageType == 'TearGas') || (damageType == 'HalonGas'))
			PawnInfo.static.PlaySound_PainEye(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		//else if (damageType == 'PoisonGas')
		//	PlaySound(sound'MaleCough', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		else
		{
			rnd = FRand();
			if (rnd < 0.33)
				PawnInfo.static.PlaySound_PainSmall(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
			else if (rnd < 0.66)
				PawnInfo.static.PlaySound_PainMedium(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
			else
				PawnInfo.static.PlaySound_PainLarge(self, FMax(Mult * TransientSoundVolume, Mult * 2.0));
		}
	}
}

function PlayBodyThud()
{
	PawnInfo.static.PlaySound_BodyThud(self);
}

//
// functions called from animations
//
simulated function PlayFootStep()
{
	local Sound stepSound;
	local float rnd;
	local float speedFactor, massFactor;
	local float volume, pitch, range;
	local float radius, mult;
	local float volumeMultiplier;
	local DeusExPlayer pp;
	local bool bOtherPlayer;

	pp = DeusExPlayer( GetPlayerPawn() );

	if ( pp != Self )
		bOtherPlayer = True;
	else
		bOtherPlayer = False;

	rnd = FRand();

	volumeMultiplier = 1.0;
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
	{
		volumeMultiplier = 0.5;
		if (rnd < 0.5)
			stepSound = Sound'Swimming';
		else
			stepSound = Sound'Treading';
	}
	else if (FootRegion.Zone.bWaterZone)
	{
		volumeMultiplier = 1.0;
		if (rnd < 0.33)
			stepSound = Sound'WaterStep1';
		else if (rnd < 0.66)
			stepSound = Sound'WaterStep2';
		else
			stepSound = Sound'WaterStep3';
	}
	else
	{
		if (WalkSound != none) stepSound = WalkSound;
		else
		{
			switch(FloorMaterial)
			{
				case 'Textile':
				case 'Paper':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'CarpetStep1';
					else if (rnd < 0.5)
						stepSound = Sound'CarpetStep2';
					else if (rnd < 0.75)
						stepSound = Sound'CarpetStep3';
					else
						stepSound = Sound'CarpetStep4';
					break;

				case 'Foliage':
				case 'Earth':
					volumeMultiplier = 0.6;
					if (rnd < 0.25)
						stepSound = Sound'GrassStep1';
					else if (rnd < 0.5)
						stepSound = Sound'GrassStep2';
					else if (rnd < 0.75)
						stepSound = Sound'GrassStep3';
					else
						stepSound = Sound'GrassStep4';
					break;

				case 'Metal':
				case 'Ladder':
					volumeMultiplier = 1.0;
					if (rnd < 0.25)
						stepSound = Sound'MetalStep1';
					else if (rnd < 0.5)
						stepSound = Sound'MetalStep2';
					else if (rnd < 0.75)
						stepSound = Sound'MetalStep3';
					else
						stepSound = Sound'MetalStep4';
					break;

				case 'Ceramic':
				case 'Glass':
				case 'Tiles':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'TileStep1';
					else if (rnd < 0.5)
						stepSound = Sound'TileStep2';
					else if (rnd < 0.75)
						stepSound = Sound'TileStep3';
					else
						stepSound = Sound'TileStep4';
					break;

				case 'Wood':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'WoodStep1';
					else if (rnd < 0.5)
						stepSound = Sound'WoodStep2';
					else if (rnd < 0.75)
						stepSound = Sound'WoodStep3';
					else
						stepSound = Sound'WoodStep4';
					break;

				case 'Brick':
				case 'Concrete':
				case 'Stone':
				case 'Stucco':
				default:
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'StoneStep1';
					else if (rnd < 0.5)
						stepSound = Sound'StoneStep2';
					else if (rnd < 0.75)
						stepSound = Sound'StoneStep3';
					else
						stepSound = Sound'StoneStep4';
					break;
			}
		}
	}

	// compute sound volume, range and pitch, based on mass and speed
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
		speedFactor = WaterSpeed/180.0;
	else
		speedFactor = VSize(Velocity)/180.0;

	massFactor  = Mass/150.0;
	radius      = 375.0;
	volume      = (speedFactor+0.2) * massFactor;
	range       = radius * volume;
	pitch       = (volume+0.5);
	volume      = FClamp(volume, 0, 1.0) * 0.5;		// Hack to compensate for increased footstep volume.
	range       = FClamp(range, 0.01, radius*4);
	pitch       = FClamp(pitch, 1.0, 1.5);

	// AugStealth decreases our footstep volume
	volume *= RunSilentValue;

	if ( Level.NetMode == NM_Standalone )
		PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
	else	// special case for multiplayer
	{
		if ( !bIsWalking || !PawnInfo.default.bCanRun)
		{
			// Tone down player's own footsteps
			if ( !bOtherPlayer )
			{
				volume *= 0.33;
				PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
			}
			else // Exagerate other players sounds (range slightly greater than distance you see with vision aug)
			{
				volume *= 2.0;
				range = (class'AugVision'.Default.mpAugValue * 1.2);
				volume = FClamp(volume, 0, 1.0);
				PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
			}
		}
	}
}


//
// replicated special effect functions
//
simulated function SEF_ChunkUp(vector ChunkLocation, float ColRadius, float ColHeight)
{
	local int i;
	local float size;
	local Vector loc;
	local FleshFragment chunk;

	// gib the carcass
	size = (ColRadius + ColHeight) / 2;
	if (size > 10.0)
	{
		for (i = 0; i < size / 4.0; i++)
		{
			loc.X = (1-2*FRand()) * ColRadius;
			loc.Y = (1-2*FRand()) * ColRadius;
			loc.Z = (1-2*FRand()) * ColRadius;
			loc += ChunkLocation;
			chunk = Spawn(class'CBPFleshFragment', None,, ChunkLocation);
			if (chunk != None)
			{
				chunk.DrawScale = size / 25;
				chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
				chunk.bFixedRotationDir = True;
				chunk.RotationRate = RotRand(False);
			}
		}
	}
}

simulated function SEF_SpewBlood(Vector position)
{
	spawn(class'CBPBloodSpurt', , , position);
	spawn(class'CBPBloodDrop', , , position);
	if (FRand() < 0.5) spawn(class'CBPBloodDrop', , , position);
}


simulated function SEF_SpawnBlood(Vector position, int q)
{
	local int i;
	spawn(class'CBPBloodSpurt', , , position);
	spawn(class'CBPBloodDrop', , , position);
	for (i = 0; i < q; i++)
		spawn(class'CBPBloodDrop', , , position);
}

simulated function SEF_SpawnBloodFromWeapon(Actor bleeder, Vector HitLocation, Vector HitNormal, Rotator rot)
{
	if (bleeder == none) return; // bleeder is not replicated to us, so just return

	spawn(class'CBPBloodSpurt',,,HitLocation + HitNormal, rot);
	spawn(class'CBPBloodDrop',,,HitLocation + HitNormal);
	if (FRand() < 0.5) spawn(class'CBPBloodDrop',,,HitLocation + HitNormal);
}

simulated function SEF_SpawnBloodFromProjectile(Actor bleeder, Vector HitLocation, Vector HitNormal, byte dmg)
{
	local int i;

	if (bleeder == none) return; // bleeder is not replicated to us, so just return

	spawn(class'CBPBloodSpurt',,,HitLocation+HitNormal);
	for (i=0; i<dmg; i++)
	{
		if (FRand() < 0.5)
			spawn(class'CBPBloodDrop',,,HitLocation+HitNormal*4);
	}
}

simulated function SEF_SpawnTracerFromWeapon(Actor instigator, Vector loc, Rotator rot)
{
	if (instigator == none) return; // instigator is not replicated to us, so just return
	Spawn(class'Tracer',,, loc, rot);
}

simulated function SEF_SpawnShellCasing(Actor instigator, Vector loc, Rotator rot)
{
	local ShellCasing sc;
	if (instigator == none) return; // instigator is not replicated to us, so just return
	sc = spawn(class'ShellCasing',,, loc);
	if (sc != none) sc.Velocity = Vector(rot) * 100 + VRand() * 30;
}

simulated function SparkPlayHitSound(actor destActor, Actor hitActor)
{
	local float rnd;
	local sound snd;

	rnd = FRand();

	if (rnd < 0.25)
		snd = sound'Ricochet1';
	else if (rnd < 0.5)
		snd = sound'Ricochet2';
	else if (rnd < 0.75)
		snd = sound'Ricochet3';
	else
		snd = sound'Ricochet4';

	// play a different ricochet sound if the object isn't damaged by normal bullets
	if (hitActor != None)
	{
		if (hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10))
			snd = sound'ArmorRicochet';
		else if (hitActor.IsA('Robot'))
			snd = sound'ArmorRicochet';
	}

	if (destActor != None)
		destActor.PlaySound(snd, SLOT_None,,, 1024, 1.1 - 0.2*FRand());
}

simulated function SEF_SpawnSpark(Actor instigator, Vector loc, Vector norm, Actor hit)
{
	local Spark spar;

	if (instigator == none) return; // instigator is not replicated to us, so just return
	spar = spawn(class'Spark',,,loc + norm, Rotator(norm));
	if (spar != none)
	{
		spar.DrawScale = 0.05;
		SparkPlayHitSound(spar, hit);
	}
}

simulated function name GetWallMaterial2(vector HitLocation, vector HitNormal)
{
	local vector EndTrace, StartTrace;
	local actor newtarget;
	local int texFlags;
	local name texName, texGroup;

	StartTrace = HitLocation + HitNormal*16;		// make sure we start far enough out
	EndTrace = HitLocation - HitNormal;

	foreach TraceTexture(class'Actor', newtarget, texName, texGroup, texFlags, StartTrace, HitNormal, EndTrace)
		if ((newtarget == Level) || newtarget.IsA('Mover'))
			break;

	return texGroup;
}

simulated function SEF_SpawnTurretEffects(Actor instigator, Vector HitLocation, Vector HitNormal, Actor Other)
{
	local SmokeTrail puff;
	local int i;
	local BulletHole hole;
	local Rotator rot;

	if (instigator == none) return; // instigator is not replicated to us, so just return

   if (FRand() < 0.5)
	{
		puff = spawn(class'SmokeTrail',,,HitLocation+HitNormal, Rotator(HitNormal));
		if (puff != None)
		{
			puff.DrawScale *= 0.3;
			puff.OrigScale = puff.DrawScale;
			puff.LifeSpan = 0.25;
			puff.OrigLifeSpan = puff.LifeSpan;
		}
	}

	if (!Other.IsA('BreakableGlass'))
		for (i=0; i<2; i++)
			if (FRand() < 0.8)
				spawn(class'Rockchip',,,HitLocation+HitNormal);

	hole = spawn(class'BulletHole', Other,, HitLocation, Rotator(HitNormal));

	// should we crack glass?
	if (GetWallMaterial2(HitLocation, HitNormal) == 'Glass')
	{
		if (FRand() < 0.5)
			hole.Texture = Texture'FlatFXTex29';
		else
			hole.Texture = Texture'FlatFXTex30';

		hole.DrawScale = 0.1;
		hole.ReattachDecal();
	}
}

exec function LagoMeter(bool onoff)
{
	if (LMActor != none && !onoff) ConsoleCommand("inject userflag 0");
	ServerLagoMeter(onoff);
}

function ServerLagoMeter(bool onoff)
{
	if (onoff)
	{
		if (LMActor == none)
		{
			LMActor = Spawn(LagometerClass, self);
		}
	}
	else
	{
		if (LMActor != none)
		{
			LMActor.Destroy();
			LMActor = none;
		}
	}
}

simulated event Destroyed()
{
	if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer)
		if (LMActor != none) LMActor.Destroy();
	if (Role == ROLE_Authority)
	{
		if (BeltInventory != none) BeltInventory.Destroy();
	}
	super.Destroyed();
}

event ClientMessage(coerce string S, optional Name Type, optional bool bBeep)
{
	if (LMActor != none && Left(S, 2) ~= "r=")
	{
		LMActor.SetServerLoad(S);
	}
	else super.ClientMessage(S, Type, bBeep);
}


exec function ActivateBelt(int objectNum)
{
	if (RestrictInput())
		return;

	// todo: buy skills if menu opened

	if (CarriedDecoration == None)
	{
		if (BeltInventory != none)
			BeltInventory.SelectInventory(objectNum);
	}
}

exec function NextBeltItem()
{
	if (RestrictInput())
		return;

	if (CarriedDecoration == None)
	{
		if (BeltInventory != none)
			BeltInventory.NextItem();
	}
}

exec function PrevBeltItem()
{
	if (RestrictInput())
		return;

	if (CarriedDecoration == None)
	{
		if (BeltInventory != none)
			BeltInventory.PrevItem();
	}
}

final function int V29(int V9D, out string V92, string V9E, string V9F, optional byte VA0, optional byte VA1)
{
	local int VA2;
	local int VA3;
	local int VA4;
	local int VA5;
	local int V91;

	if ( V92 == "" )
	{
		return V9D;
	}
	VA3=Len(V9E);
	VA2=InStr(V92,V9E);
JL0031:
	if ( VA2 != -1 )
	{
		VA5=0;
		if ( VA0 != 0 )
		{
			VA4=Len(V92);
			if ( VA1 > 0 )
			{
				VA4=Min(VA4,VA2 + VA3 + VA1);
			}
			VA5=VA2 + VA3;
JL009F:
			if ( VA5 < VA4 )
			{
				V91=Asc(Caps(Mid(V92,VA5,1)));
				if ( (V91 < 48) || (V91 > 57) )
				{
					if ( (VA0 == 1) || (V91 < 65) || (V91 > 70) )
					{
						goto JL0114;
					}
				}
				VA5++;
				goto JL009F;
			}
JL0114:
			VA5 -= VA2 + VA3;
		}
		V92=Left(V92,VA2) $ V9F $ Mid(V92,VA2 + VA3 + VA5);
		V9D -= VA3 + VA5;
		if ( V9D <= 0 )
		{
			V92=Left(V92,VA2 + Len(V9F));
		} else {
			VA2=InStr(V92,V9E);
			goto JL0031;
		}
	}
	return V9D;
}

final function V54 (out string V92, bool VA6)
{
	local int VA7;

	V92=Left(V92,500);
	if (  !VA6 )
	{
		V29(12,V92,Chr(32),"_");
		V29(12,V92,Chr(160),"_");
	}
	VA7=V29(18,V92,"|p","",1,1);
	V29(VA7 + 4,V92,"|P","",1,1);
	VA7=V29(32,V92,"|c","",2,6);
	V29(VA7 + 6,V92,"|C","",2,6);
	V29(12,V92,"|","!");
}

final function V52 (out string V92)
{
	V92=Left(V92,20);
	if ( Level.NetMode == 0 )
	{
		return;
	}
	V54(V92,False);
	if ( V92 == "" )
	{
		V92="Player";
	}
	if ( (V92 ~= "Player") || (V92 ~= "PIayer") || (V92 ~= "P1ayer") )
	{
		V92=V92 $ "_" $ string(Rand(999));
	} else {
		if ( V51(V92) )
		{
			V92=Left(V92,17) $ "_" $ string(Rand(99));
		}
	}
}

function bool V51 (string V92)
{
	local Pawn Player;

	if ( Level.NetMode != 0 )
	{
		Player=Level.PawnList;
JL002B:
		if ( Player != None )
		{
			if ( Player.bIsPlayer && (Player != self) && (Player.PlayerReplicationInfo.PlayerName ~= V92) )
			{
				return True;
			}
			Player=Player.nextPawn;
			goto JL002B;
		}
	}
	return False;
}

function ChangeName(coerce string V92)
{
	V52(V92);
	Level.Game.ChangeName(self, V92, False);
}

exec function Name(coerce string S)
{
	SetName(S);
}

exec function SetName(coerce string S)
{
	if (Level.TimeSeconds - LastNameChangeTime <= 2.50) return;
	S=Left(S, 20);
	ServerSetName(S);
	if (GetDefaultURL("Name") != S)
	{
		UpdateURL("Name", S, True);
		SaveConfig();
	}
	LastNameChangeTime = Level.TimeSeconds;
}

function ServerSetName(coerce string V92)
{
	if (Level.TimeSeconds - LastNameChangeTime > 2.30)
		LastNameChangeTime = Level.TimeSeconds;
	else return;

	V92=Left(V92, 20);
	if (V51(V92)) ClientMessage(l_nametaken);
	else ChangeName(V92);
}

exec function Say(string Msg)
{
	local Pawn P;
	local String str;

	if (Msg == "") return;

	if (!CBPGame(Level.Game).CheckSaySpam(self, Msg)) return;

	str = PlayerReplicationInfo.PlayerName $ "(" $ PlayerReplicationInfo.PlayerID $ "): " $ Msg;

	if ( Role == ROLE_Authority )
		log(str, 'Say');

	for( P = Level.PawnList; P != None; P = P.nextPawn )
	{
		if( P.bIsPlayer || P.IsA('MessagingSpectator') )
			P.ClientMessage( str, 'Say', true );
	}

	return;
}

exec function TeamSay( string Msg )
{
	local Pawn P;
	local String str;

	if (Msg == "") return;

	if (!Level.Game.bTeamGame)
	{
		Say(Msg);
		return;
	}

	if (!CBPGame(Level.Game).CheckSaySpam(self, Msg)) return;

	str = PlayerReplicationInfo.PlayerName $ "(" $ PlayerReplicationInfo.PlayerID $ "): " $ Msg;

	if ( Role == ROLE_Authority )
		log( str, 'TeamSay' );

	for( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
		{
			if ( P.IsA('DeusExPlayer') )
				DeusExPlayer(P).ClientMessage( str, 'TeamSay', true );
		}
	}
}

//exec function ShowShit()
//{
//	local DeusExRootWindow root;

//	root = DeusExRootWindow(rootWindow);
//	if (root != None)
//	{
//		if (root.actorDisplay == none)
//		{
//			root.actorDisplay=ActorDisplayWindow(root.NewChild(Class'ActorDisplayWindow'));
//			root.actorDisplay.SetWindowAlignments(HALIGN_Full,VALIGN_Full);
//		}
//		root.actorDisplay.SetViewClass(class'CBPPlayer');
//		root.actorDisplay.ShowCylinder(true);
//		root.actorDisplay.ShowEyes(true);
//	}
//}

defaultproperties
{
    KillProfileClass=Class'DeusEx.KillerProfile'
    LagometerClass=Class'Lagometer'
    humanAnimRate=1.00
    AfterDeathPause=3.00
    bShowDeadHUD=True
    SecondsToNewMap=15.00
    DroneSpeedMulti=1.00
    WFlameThrowerClass=Class'CBPWeaponFlamethrower'
    DeusExHUDClass=Class'CBPDeusExHUD'
    PlayerTrackClass=Class'CBPPlayerTrack'
    l_nametaken="Someone is already playing with that name, please choose another."
    BaseEyeHeight=10.00
    PlayerReplicationInfoClass=Class'CBPPlayerReplicationInfo'
    AnimSequence=Still
    CollisionRadius=20.00
    CollisionHeight=20.00
}
