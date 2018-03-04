class CBPSkillManager extends SkillManager;

var byte SkillLevels[11];

var const float SkillWeaponValues[4];
var const float SkillDemolitionValues[4];
var const float SkillEnviroValues[4];
var const float SkillTechValues[4];
var const float SkillMedValues[4];
var const float SkillCompValues[4];
var const float SkillSwimValues[4];

var const int SkillCosts[11];

replication
{
    //variables server to client
	reliable if ((Role == ROLE_Authority) && (bNetOwner))
	    SkillLevels;

	reliable if (Role < ROLE_Authority)
		IncLevel;
}

static function int GetSkillGroupByClass(class<Skill> sclass)
{
	local int i;

	for (i = 0; i < 10; i++)
		if (default.skillClasses[i] == sclass) return ((i + 1) % 10);

	return -1;
}

simulated function bool IsPurchasePossible()
{
	local int skillIndex;

	for(skillIndex=0; skillIndex<arrayCount(SkillLevels) - 1; skillIndex++)
	{
		if (SkillLevels[skillIndex] < 3 && Player.SkillPointsAvail >= SkillCosts[skillIndex])
			return true;
	}

	return false;
}



simulated function string GetSkillClassNameByIndex(byte index)
{
	if (index >= ArrayCount(skillClasses)) return "";

	if (index == 7) return class<SkillTech>(skillClasses[index]).default.MultitoolString;
	else return skillClasses[index].default.SkillName;
}

simulated function string GetSkillClassNameByClass(class<Skill> cskill)
{
	if (class<SkillTech>(cskill) != none) return class<SkillTech>(cskill).default.MultitoolString;
	else return cskill.default.SkillName;
}

// do not spend skill points to upgrade
function ForceIncLevel(byte sindex)
{
	if (sindex >= ArrayCount(SkillLevels)) return;

	if (SkillLevels[sindex] < 3)
	{
		SkillLevels[sindex]++;
		if (sindex == 5) 
		{
			if (SkillLevels[10] < 3)
				SkillLevels[10]++; // if enviro, upgrade swimming too
		}
	}
}

function IncLevel(byte sindex)
{
	if (sindex >= ArrayCount(SkillLevels)) return;

	if (SkillLevels[sindex] < 3)
	{
		if (player.SkillPointsAvail >= SkillCosts[sindex])
		{
			player.SkillPointsAvail -= SkillCosts[sindex];
			SkillLevels[sindex]++;
			if (sindex == 5) 
			{
				if (SkillLevels[10] < 3)
					SkillLevels[10]++; // if enviro, upgrade swimming too
			}
		}
	}
}

function CreateSkills(DeusExPlayer newPlayer)
{
	FirstSkill = None;
	player = newPlayer;
	ResetSkills();
}

function bool SkillUse(class<Skill> sclass)
{
	local bool bDoIt;

	bDoIt = True;

	if (sclass.default.itemNeeded != None)
	{
		bDoIt = False;

		if ((Player.inHand != None) && (Player.inHand.Class == sclass.default.itemNeeded))
		{
			SkilledTool(Player.inHand).PlayUseAnim();

			bDoIt = True;
		}
	}

	return bDoIt;
}

simulated function bool IsSkilled(class SkillClass, int TestLevel)
{
	local int skillIndex;

	for(skillIndex=0; skillIndex<arrayCount(SkillLevels); skillIndex++)
	{
		if (skillClasses[skillIndex] == SkillClass) 
		{
			if (SkillUse(skillClasses[skillIndex]))
			{
				if (SkillLevels[skillIndex] >= TestLevel)
				{
					Player.ClientMessage(SuccessMessage);
					return True;
				}
				else
					Player.ClientMessage(Sprintf(NoSkillMessage, skillClasses[skillIndex].default.SkillName, 
						GetItemName(String(skillClasses[skillIndex].default.itemNeeded))));
			}
			else
				Player.ClientMessage(Sprintf(NoToolMessage, 
					GetItemName(String(skillClasses[skillIndex].default.itemNeeded))));

			break;
		}
	}

	return False;
}

simulated function Skill GetSkillFromClass(class SkillClass)
{
	return none;
}

simulated function float GetSkillLevelValue(class SkillClass)
{
	local int skillIndex;

	for(skillIndex=0; skillIndex<arrayCount(SkillLevels); skillIndex++)
	{
		if (skillClasses[skillIndex] == SkillClass)
		{
			switch (skillIndex)
			{
			case 0:
			case 1:
			case 2:
			case 3:
				return SkillWeaponValues[SkillLevels[skillIndex]];
			case 4:
				return SkillDemolitionValues[SkillLevels[skillIndex]];
			case 5:
				return SkillEnviroValues[SkillLevels[skillIndex]];
			case 6:
			case 7:
				return SkillTechValues[SkillLevels[skillIndex]];
			case 8:
				return SkillMedValues[SkillLevels[skillIndex]];
			case 9:
				return SkillCompValues[SkillLevels[skillIndex]];
			case 10:
				return SkillSwimValues[SkillLevels[skillIndex]];
			}
		}
	}

	return 1.0;
}

simulated function float GetSkillLevel(class SkillClass)
{
	local int skillIndex;

	for(skillIndex=0; skillIndex<arrayCount(SkillLevels); skillIndex++)
	{
		if (skillClasses[skillIndex] == SkillClass) return float(SkillLevels[skillIndex]);
	}

	return 0;
}

function AddSkill(Skill aNewSkill)
{
}

function SetPlayer(DeusExPlayer newPlayer)
{
	Player = newPlayer;
}

function AddAllSkills()
{
	local int skillIndex;

	for(skillIndex=0; skillIndex<arrayCount(SkillLevels); skillIndex++)
	{
		SkillLevels[skillIndex] = 3;
	}
}

function ResetSkills()
{
	local int skillIndex;

	for(skillIndex=0; skillIndex<arrayCount(SkillLevels); skillIndex++)
	{
		SkillLevels[skillIndex] = Min(CBPGame(Level.Game).MPSkillStartLevel, 3);
	}
}

defaultproperties
{
    SkillWeaponValues(0)=-0.10
    SkillWeaponValues(1)=-0.25
    SkillWeaponValues(2)=-0.37
    SkillWeaponValues(3)=-0.50
    SkillDemolitionValues(1)=-0.10
    SkillDemolitionValues(2)=-0.30
    SkillDemolitionValues(3)=-0.50
    SkillEnviroValues(0)=1.00
    SkillEnviroValues(1)=0.75
    SkillEnviroValues(2)=0.50
    SkillEnviroValues(3)=0.25
    SkillTechValues(0)=0.10
    SkillTechValues(1)=0.40
    SkillTechValues(2)=0.55
    SkillTechValues(3)=0.95
    SkillMedValues(0)=1.00
    SkillMedValues(1)=1.00
    SkillMedValues(2)=2.00
    SkillMedValues(3)=3.00
    SkillCompValues(0)=0.40
    SkillCompValues(1)=0.40
    SkillCompValues(2)=1.00
    SkillCompValues(3)=5.00
    SkillSwimValues(0)=1.00
    SkillSwimValues(1)=1.25
    SkillSwimValues(2)=1.50
    SkillSwimValues(3)=2.25
    SkillCosts(0)=2000
    SkillCosts(1)=2000
    SkillCosts(2)=2000
    SkillCosts(3)=2000
    SkillCosts(4)=1000
    SkillCosts(5)=1000
    SkillCosts(6)=1000
    SkillCosts(7)=1000
    SkillCosts(8)=1000
    SkillCosts(9)=1000
    NetPriority=1.40
}
