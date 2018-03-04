//-----------------------------------------------------------
// CBP204 added
//-----------------------------------------------------------
class CBPMapList extends MapList;

var(Maps) globalconfig string Maps[32];
var globalconfig int MapNum;

function string GetNextMap()
{
	local string CurrentMap;
	local int i;

	CurrentMap = GetURLMap();
	log("Current map is: " $ CurrentMap);
	if (CurrentMap != "")
	{
		if (Right(CurrentMap, 3) ~= ".dx" )
			CurrentMap = CurrentMap;
		else
			CurrentMap = CurrentMap $ ".dx";

		for (i = 0; i < ArrayCount(Maps); i++)
		{
			if (CurrentMap ~= Maps[i])
			{
				MapNum = i;
				break;
			}
		}
	}

	MapNum++;
	if (MapNum > ArrayCount(Maps) - 1)
		MapNum = 0;
	if (Maps[MapNum] == "")
		MapNum = 0;

	SaveConfig();

	log("Next map is: " $ Maps[MapNum]);

	return Maps[MapNum];
}

DefaultProperties
{
}
