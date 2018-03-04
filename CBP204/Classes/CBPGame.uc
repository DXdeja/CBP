class CBPGame extends GameInfo;

var() globalconfig float FriendlyFireMult;
var() globalconfig byte MPSkillStartLevel;
var() globalconfig bool bTeamBalancer;

var class<PawnType> DefaultPawnType;
var class<CBPMainMenu> MainMenuClass;
var class<AntiSpam> AntiSpamClass;

var AntiSpam AntiSpamSystem;
// CBP204
var MapList MList;
var string NextMap;
//

function AdjustTeamBalancer(optional CBPPlayerReplicationInfo quitpri)
{
	local int team0c, team1c;
	local CBPPlayerReplicationInfo pri;

	if (!bTeamBalancer || !bTeamGame) return;
	if (bGameEnded) return;

	// count number of players on each side
	foreach AllActors(class'CBPPlayerReplicationInfo', pri)
	{
		if (pri == quitpri) continue;
		if (!pri.bIsSpectator)
		{
			if (pri.Team == 0) team0c++;
			else if (pri.Team == 1) team1c++;
		}
	}

	if (team0c + 1 < team1c) CBPGameReplicationInfo(GameReplicationInfo).ForceTeam = 0;
	else if (team1c + 1 < team0c) CBPGameReplicationInfo(GameReplicationInfo).ForceTeam = 1;
	else CBPGameReplicationInfo(GameReplicationInfo).ForceTeam = 255;
}

function FinishGame(optional int winner) // playerid or team
{
	local CBPPlayer player;

	if (bGameEnded) return; // already ended

	foreach AllActors(class'CBPPlayer', player)
	{
	    // CBP204
	    player.NextMap = NextMap;
	    //
		player.GotoState('CBPGameEnded');
		player.ClientGameEnded();
	}
	bGameEnded = true;
	SetTimer(class<CBPPlayer>(DefaultPlayerClass).default.SecondsToNewMap - 4, false);
}

function Timer()
{
	// todo: map select
	if (bGameEnded)
       // CBP204
       Level.ServerTravel(NextMap, false);
       // Level.ServerTravel(Left(string(Level), InStr(string(Level), ".")), false);
	else super.Timer();
}

function bool AllowsBroadcast( actor broadcaster, int Len ) { return true; }

function bool CheckSaySpam(CBPPlayer owner, string Msg)
{
	if (AntiSpamSystem != none)
		return AntiSpamSystem.CheckSay(owner, Msg);
	return true;
}

event InitGame(string Options, out string Error)
{
	super.InitGame(Options, Error);
	if (AntiSpamClass != none) AntiSpamSystem = new AntiSpamClass;

	// CBP204
	if (MapListType != none)
    {
        MList = Spawn(MapListType);
        NextMap = MList.GetNextMap();
        MList.Destroy();
    }

	SaveConfig();
	//
}

function NavigationPoint FindStartingPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	return FindPlayerStart( Player, InTeam, incomingName );
}

event PreLogin (string Z56, string Z59, out string Z57, out string Z5A)
{
	Super.PreLogin(Z56,Z59,Z57,Z5A);
	if (Z57 != "" )
	{
	    if ( (Len(Z56) > 800) || HasOption(Z56,string('LoadGame')) )
	    {
		    Z57="PreLogin Failed.";
	    }
	}
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local NavigationPoint StartSpot;
	local PlayerPawn      NewPlayer;
	local string          InName, InPassword, InSkin, InFace, InChecksum;
	local byte            InTeam;

	// Make sure there is capacity. (This might have changed since the PreLogin call).
	if ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) )
	{
		Error=MaxedOutMessage;
		return None;
	}

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 20);
	InTeam     = GetIntOption( Options, "Team", 0 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InSkin	   = ParseOption ( Options, "Skin"    );
	InFace     = ParseOption ( Options, "Face"    );
	InChecksum = ParseOption ( Options, "Checksum" );

	log( "Login:" @ InName );
	if( InPassword != "" )
		log( "Password"@InPassword );

	// Find a start spot.
	StartSpot = FindStartingPlayerStart( None, InTeam, Portal );

	if( StartSpot == None )
	{
		Error = FailedPlaceMessage;
		return None;
	}

	SpawnClass = DefaultPlayerClass;

	NewPlayer = Spawn(SpawnClass,,,StartSpot.Location,StartSpot.Rotation);
	if( CBPPlayer(NewPlayer) !=None )
	{
		NewPlayer.ViewRotation = StartSpot.Rotation;
		CBPPlayer(NewPlayer).NextPawnInfo = DefaultPawnType;
	}

	// Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player at "$StartSpot);
		Error = FailedSpawnMessage;
		return None;
	}

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Init player's information.
	NewPlayer.ClientSetRotation(NewPlayer.Rotation);
	if( InName=="" )
		InName=DefaultPlayerName;
	ChangeName( NewPlayer, InName, false );

	CBPPlayer(NewPlayer).V52(NewPlayer.PlayerReplicationInfo.PlayerName);

	// Change player's team.
	if ( !ChangeTeam(newPlayer, InTeam) )
	{
		Error = FailedTeamMessage;
		return None;
	}

	// Init player's administrative privileges
	NewPlayer.Password = InPassword;
	AdminLogin(NewPlayer, InPassword);

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastMessage( NewPlayer.PlayerReplicationInfo.PlayerName$EnteredMessage, false );

	// Teleport-in effect.
	StartSpot.PlayTeleportEffect( NewPlayer, true );

	// Log it.
	if ( LocalLog != None )
		LocalLog.LogPlayerConnect(NewPlayer);
	if ( WorldLog != None )
		WorldLog.LogPlayerConnect(NewPlayer, InChecksum);

	NumPlayers++;

	return newPlayer;
}

event PostLogin(PlayerPawn newPlayer)
{
	super.PostLogin(newPlayer);

	if (bGameEnded)
	{
		newPlayer.GotoState('CBPGameEnded');
		newPlayer.ClientGameEnded();
	}
}

event Logout(Pawn pp)
{
	super.Logout(pp);
	AdjustTeamBalancer(CBPPlayerReplicationInfo(pp.PlayerReplicationInfo));
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon newWeapon;
	local class<Weapon> WeapClass;
	local CBPPlayer p;

	p = CBPPlayer(PlayerPawn);
	if (p == none) return;
	if (p.PawnInfo == none) return;
	p.JumpZ = p.PawnInfo.Default.JumpZ * PlayerJumpZScaling();

	// Spawn default weapon.
	//WeapClass = BaseMutator.MutatedDefaultWeapon();
	//if( (WeapClass!=None) && (PlayerPawn.FindInventoryType(WeapClass)==None) )
	//{
	//	newWeapon = Spawn(WeapClass);
	//	if( newWeapon != None )
	//	{
	//		newWeapon.Instigator = PlayerPawn;
	//		newWeapon.BecomeItem();
	//		newWeapon.GiveAmmo(PlayerPawn);
	//		PlayerPawn.AddInventory(newWeapon);
	//		newWeapon.BringUp();
	//		newWeapon.SetSwitchPriority(PlayerPawn);
	//		newWeapon.WeaponSet(PlayerPawn);
	//	}
	//}
	BaseMutator.ModifyPlayer(PlayerPawn);
}

function bool RestartPlayer( pawn aPlayer )
{
    local DeusExPlayer PlayerToRestart;
    local bool SuperResult;

    log("CBP Game restart player");
    PlayerToRestart = DeusExPlayer(aPlayer);

    if (PlayerToRestart == None)
    {
        log("Trying to restart non Deus Ex player!");
        return false;
    }

    //Restore HUD
    PlayerToRestart.ShowHud(True);
    //Clear Augmentations
	if (PlayerToRestart.AugmentationSystem != none)
		PlayerToRestart.AugmentationSystem.ResetAugmentations();
    //Clear Skills
	if (PlayerToRestart.SkillSystem != none)
		PlayerToRestart.SkillSystem.ResetSkills();

	SuperResult = Super.RestartPlayer(aPlayer);

    PlayerToRestart.ResetPlayerToDefaults();

    //Restore Augs
    //PlayerToRestart.ClearAugmentationDisplay();
    //PlayerToRestart.AugmentationSystem.CreateAugmentations(PlayerToRestart);
    //PlayerToRestart.AugmentationSystem.AddDefaultAugmentations();
    //Restore Bio-Energy
    PlayerToRestart.Energy = PlayerToRestart.EnergyMax;
    //Restore Skills
    //PlayerToRestart.SkillSystem.CreateSkills(PlayerToRestart);
    //Replace with skill points based on game info.
    //SetupAbilities(PlayerToRestart);

	PlayerToRestart.myProjKiller = None;

    return SuperResult;
}

function DiscardInventory( Pawn Other )
{
	// do nothing
}

function KillReward(CBPPlayer player, CBPPlayer other)
{
}

//
// static special effect functions
// called from various actors on server side
// called on all players with visual contact
//
static function SEF_ChunkUp(Actor owner)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_ChunkUp(owner.Location, owner.CollisionRadius, owner.CollisionHeight);
	}
}

static function SEF_SpewBlood(Actor owner, Vector position)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpewBlood(position);
	}
}

static function SEF_SpawnBlood(Actor owner, Vector position, int q)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnBlood(position, q);
	}
}

static function SEF_SpawnBloodFromWeapon(Actor owner, Vector HitLocation, Vector HitNormal, optional Rotator rot)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnBloodFromWeapon(owner, HitLocation, HitNormal, rot);
	}
}

static function SEF_SpawnBloodFromProjectile(Actor owner, Vector HitLocation, Vector HitNormal, float dmg)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnBloodFromProjectile(owner, HitLocation, HitNormal, dmg);
	}
}

static function SEF_SpawnTracerFromWeapon(Actor owner, Vector loc, Rotator rot)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnTracerFromWeapon(owner, loc, rot);
	}
}

static function SEF_SpawnShellCasing(Actor owner, Vector loc, Rotator rot)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnShellCasing(owner, loc, rot);
	}
}

static function SEF_SpawnSpark(Actor owner, Vector loc, Vector norm, Actor hit)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnSpark(owner, loc, norm, hit);
	}
}

static function SEF_SpawnTurretEffects(Actor owner, Vector HitLocation, Vector HitNormal, Actor Other)
{
	local CBPPlayer curplayer;

	foreach owner.AllActors(class'CBPPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) ||
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true)))
			curplayer.SEF_SpawnTurretEffects(owner, HitLocation, HitNormal, Other);
	}
}

static function bool ArePlayersAllied(DeusExPlayer FirstPlayer, DeusExPlayer SecondPlayer)
{
	if ((FirstPlayer == None) || (SecondPlayer == None)) return false;
	return (FirstPlayer.PlayerReplicationInfo.team == SecondPlayer.PlayerReplicationInfo.team);
}

defaultproperties
{
    MPSkillStartLevel=1
    DefaultPawnType=Class'Human_JCDenton'
    MainMenuClass=Class'CBPMainMenu'
    AntiSpamClass=Class'AntiSpam'
    DefaultPlayerClass=Class'CBPPlayer'
    ScoreBoardType=Class'CBPScoreBoard'
    HUDType=Class'CBPHUD'
    GameReplicationInfoClass=Class'CBPGameReplicationInfo'
    RemoteRole=ROLE_None

    // CBP204
    MapListType=Class'CBPMapList'
    //
}
