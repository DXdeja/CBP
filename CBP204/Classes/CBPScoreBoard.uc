class CBPScoreBoard extends ScoreBoard;

var Font SmallFont;
var Color ColWhite;
var Color ColDarkYellow;
var Color ColYellow;
var Color ColDarkRed;
var Color ColRed;
var Color ColDarkGreen;
var Color ColGreen;
var Color ColCyan;

var string ObjText;

struct InfoProperty
{
	var int Xoff;
	var string DisplayName;
	var string AltDisplayName;
};

var InfoProperty Properties[8]; // properties to draw
var byte HideProperties[8];

struct PlayerInfo
{
	var CBPPlayerReplicationInfo PRI; // linked PRI
	var string Properties[8];
	var int SortingCrit; // according to this value, sort is issued
	var bool bLocalPlayer;
};

var PlayerInfo PlayerInfos[32];

var int TableXSize;


var int LetterHeight;
var int CurrentYoff;
var int CurrentXoff;

function int GetNumPlayers()
{
	return PlayerPawn(Owner).GameReplicationInfo.NumPlayers;
}

// override this - Y size depends on number of teams, size of headers, etc
function int GetTableYSize()
{
	// pheader + pheader_line + numplayers + space + sheader + sheader_line
	return (GetNumPlayers() + 3) * LetterHeight + 2 * 3;
}

function ResetHideProperties()
{
	local int i;
	for (i = 0; i < 8; i++) HideProperties[i] = 0;
}

// override this to show certain spectators related properties only
function SetShowSpectatorProperties()
{
	HideProperties[2] = 1; // kills
	HideProperties[3] = 1; // deaths
}

function int PlayerInfosCount()
{
	local int i, c;
	for (i = 0; i < 32; i++) if (PlayerInfos[i].PRI != none) c++;
	return c;
}

function SinglePlayerInfoClear(out PlayerInfo pi)
{
	local int i;
	pi.PRI = none;
	pi.SortingCrit = 0;
	pi.bLocalPlayer = false;
	for (i = 0; i < 8; i++) pi.Properties[i] = "";
}

function PlayerInfosClear()
{
	local int i;
	for (i = 0; i < 32; i++) SinglePlayerInfoClear(PlayerInfos[i]);
}

// override this function to set different sorting mechanism
function SetSortingCritForPlayerInfo(out PlayerInfo pi)
{
	// weighted scoring, prolly noone dies more than 10000 times :)
	pi.SortingCrit = int(pi.PRI.Score) * 10000 - int(pi.PRI.Deaths);
}

// override this function
function FillPropertiesArray(out PlayerInfo pi)
{
	pi.Properties[0] = string(pi.PRI.PlayerID);
	pi.Properties[1] = pi.PRI.PlayerName;
	pi.Properties[2] = string(int(pi.PRI.Score));
	pi.Properties[3] = string(int(pi.PRI.Deaths));
	pi.Properties[4] = string(pi.PRI.Ping);
}

function SinglePlayerInfoFill(out PlayerInfo pi)
{
	SetSortingCritForPlayerInfo(pi);

	if (pi.PRI == CBPPlayerReplicationInfo(PlayerPawn(Owner).PlayerReplicationInfo))
		pi.bLocalPlayer = true;

	FillPropertiesArray(pi);
}

function int FillPlayerInfos(bool bSpectator, bool bMatchTeam, optional byte Team)
{
	local CBPPlayerReplicationInfo PRI;
	local int i;

	PlayerInfosClear();
	foreach AllActors(class'CBPPlayerReplicationInfo', PRI)
	{
		if (PRI.bIsSpectator == bSpectator)
		{
			if (!bMatchTeam || PRI.Team == Team)
			{
				PlayerInfos[i].PRI = PRI;
				SinglePlayerInfoFill(PlayerInfos[i]);
				i++;
				if (i == 32) return i;
			}
		}
	}

	return i;
}

function SwapPlayerInfos(int a, int b)
{
	local PlayerInfo tmp;
	local int i;

	tmp.PRI = PlayerInfos[a].PRI;
	tmp.bLocalPlayer = PlayerInfos[a].bLocalPlayer;
	tmp.SortingCrit = PlayerInfos[a].SortingCrit;
	for (i = 0; i < 8; i++) tmp.Properties[i] = PlayerInfos[a].Properties[i];

	PlayerInfos[a].PRI = PlayerInfos[b].PRI;
	PlayerInfos[a].bLocalPlayer = PlayerInfos[b].bLocalPlayer;
	PlayerInfos[a].SortingCrit = PlayerInfos[b].SortingCrit;
	for (i = 0; i < 8; i++) PlayerInfos[a].Properties[i] = PlayerInfos[b].Properties[i];

	PlayerInfos[b].PRI = tmp.PRI;
	PlayerInfos[b].bLocalPlayer = tmp.bLocalPlayer;
	PlayerInfos[b].SortingCrit = tmp.SortingCrit;
	for (i = 0; i < 8; i++) PlayerInfos[b].Properties[i] = tmp.Properties[i];
}

function int SortPlayerInfos(int count)
{
	// perform sort according to SortingCrit
	local int i, j, max;

	for (i = 0; i < count - 1; i++)
	{
		max = i;
		for (j = i + 1; j < count; j++)
		{
			if (PlayerInfos[j].SortingCrit > PlayerInfos[max].SortingCrit)
				max = j;
		}
		if (max != i) SwapPlayerInfos(max, i);
	}

	return count;
}

function DrawSinglePlayerInfo(Canvas canvas, PlayerInfo pi, bool bFriendly)
{
	local int i;

	if (pi.bLocalPlayer)
	{
		if (pi.PRI.bIsDead && !pi.PRI.bIsSpectator) canvas.DrawColor = ColDarkYellow;
		else canvas.DrawColor = ColYellow;
	}
	else if (bFriendly)
	{
		if (pi.PRI.bIsSpectator) canvas.DrawColor = ColWhite;
		else if (pi.PRI.bIsDead) canvas.DrawColor = ColDarkGreen;
		else canvas.DrawColor = ColGreen;
	}
	else
	{
		if (pi.PRI.bIsSpectator) canvas.DrawColor = ColWhite;
		else if (pi.PRI.bIsDead) canvas.DrawColor = ColDarkRed;
		else canvas.DrawColor = ColRed;
	}

	for (i = 0; i < 8; i++)
	{
		if (Properties[i].DisplayName == "") break;
		if (HideProperties[i] == 1) continue;
		canvas.SetPos(CurrentXoff + Properties[i].Xoff, CurrentYoff);
		canvas.DrawText(pi.Properties[i]);
	}
}

function DrawPlayerInfos(Canvas canvas, int count)
{
	local int i;
	local bool bFriendly, bTeamGame;

	bTeamGame = PlayerPawn(Owner).GameReplicationInfo.bTeamGame;

	for (i = 0; i < count; i++)
	{
		if (bTeamGame && PlayerPawn(Owner).PlayerReplicationInfo.Team == PlayerInfos[i].PRI.Team) bFriendly = true;
		else bFriendly = false;
		DrawSinglePlayerInfo(canvas, PlayerInfos[i], bFriendly);
		CurrentYoff += LetterHeight;
	}
}

function DrawPlayerGroupHeader(Canvas canvas, bool bAlt, int count)
{
	local int i;
	local string str;

	for (i = 0; i < 8; i++)
	{
		if (Properties[i].DisplayName == "") break;
		if (HideProperties[i] == 1) continue;
		canvas.SetPos(CurrentXoff + Properties[i].Xoff, CurrentYoff);
		if (!bAlt || Properties[i].AltDisplayName == "")
			str = Properties[i].DisplayName;
		else
			str = Properties[i].AltDisplayName;

		if (i == 1) str = str $ " (" $ count $ ")";
		canvas.DrawText(str);
	}
	CurrentYoff += LetterHeight;
	canvas.SetPos(CurrentXoff, CurrentYoff);
	canvas.DrawRect(Texture'Solid', TableXSize, 1);
	CurrentYoff += 3;
}

function DrawContent(Canvas canvas)
{
	local int count;

	// draw players
	ResetHideProperties();
	count = SortPlayerInfos(FillPlayerInfos(false, false));
	canvas.DrawColor = ColWhite;
	DrawPlayerGroupHeader(canvas, false, count);
	DrawPlayerInfos(canvas, count);

	// draw spectators
	CurrentYoff += LetterHeight;
	SetShowSpectatorProperties();
	count = FillPlayerInfos(true, false);
	canvas.DrawColor = ColWhite;
	DrawPlayerGroupHeader(canvas, true, count);
	DrawPlayerInfos(canvas, count);
}

// set text font, colors, X offset etc...
function PreDraw(Canvas canvas)
{
	local float w, h;

	canvas.Font = SmallFont;
	canvas.TextSize("A", w, h);
	LetterHeight = h;

	CurrentYoff = (Canvas.SizeY - GetTableYSize()) / 2;
	CurrentXoff = (Canvas.SizeX - TableXSize) / 2;
}

function string GetWinningString();

function DrawHeader(Canvas canvas)
{
	local float w, h;
	local string str;

	if (PlayerPawn(Owner).IsInState('CBPGameEnded'))
	{
		str = GetWinningString();
	}
	else str = ObjText;

	// a bit above the table
	canvas.DrawColor = ColCyan;
	canvas.TextSize(str, w, h);
	canvas.SetPos((canvas.SizeX - w) / 2, CurrentYoff - 32);
	canvas.DrawText(str);
}

function DrawFooter(Canvas canvas)
{
	local string str;
	local float w, h;

	if (PlayerPawn(Owner).IsInState('CBPGameEnded'))
	{
		canvas.DrawColor = ColWhite;
		CurrentYoff += 2 * LetterHeight;

        // CBP204
		str = Max(int((CBPPlayer(Owner).GameEndedTime + CBPPlayer(Owner).SecondsToNewMap) - Level.TimeSeconds), 0) $ " seconds to new map: " $ CBPPlayer(Owner).NextMap;
		//
		canvas.TextSize(str, w, h);
		canvas.SetPos((canvas.SizeX - w) / 2, CurrentYoff);
		canvas.DrawText(str);

		CurrentYoff += h;

		str = "Press <" $ CBPPlayer(Owner).keyMainMenu $ "> to disconnect.";
		canvas.TextSize(str, w, h);
		canvas.SetPos((canvas.SizeX - w) / 2, CurrentYoff);
		canvas.DrawText(str);
	}
}

function ShowScores(Canvas canvas)
{
	PreDraw(canvas);
	DrawHeader(canvas);
	DrawContent(canvas);
	DrawFooter(canvas);
}

defaultproperties
{
    SmallFont=Font'DeusExUI.FontMenuSmall_DS'
    colWhite=(R=255,G=255,B=255,A=0),
    ColDarkYellow=(R=127,G=127,B=0,A=0),
    ColYellow=(R=255,G=255,B=0,A=0),
    colDarkRed=(R=127,G=0,B=0,A=0),
    colRed=(R=255,G=0,B=0,A=0),
    colDarkGreen=(R=0,G=127,B=0,A=0),
    colGreen=(R=0,G=255,B=0,A=0),
    colCyan=(R=0,G=255,B=255,A=0),
    ObjText="NOT DEFINED"
    Properties(0)=(Xoff=0,displayName="ID",AltDisplayName=""),
    Properties(1)=(Xoff=30,displayName="Players",AltDisplayName="Spectators"),
    Properties(2)=(Xoff=170,displayName="Kills",AltDisplayName=""),
    Properties(3)=(Xoff=220,displayName="Deaths",AltDisplayName=""),
    Properties(4)=(Xoff=270,displayName="Ping",AltDisplayName=""),
    TableXSize=300
}
