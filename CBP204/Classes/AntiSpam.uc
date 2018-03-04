class AntiSpam extends Object;

// todo: make this better, configurable
var float SameTextIgnoreTime;
var float CheckInterval;
var int MaxLettersPerCheckInterval;

function bool CheckSay(CBPPlayer owner, string Msg)
{
	local int MsgLen;

	if (owner.AS_LastMsg == Msg)
	{
		// add 2 sec prot time on same text
		if ((owner.AS_LastMsgTime + SameTextIgnoreTime) >= owner.Level.TimeSeconds)
			return false;
	}

	if ((owner.AS_LetterCountResetTime + CheckInterval) < owner.Level.TimeSeconds)
	{
		owner.AS_LetterCountResetTime = owner.Level.TimeSeconds;
		owner.AS_LetterCount = 0;
	}

	MsgLen = Len(Msg);

	if ((owner.AS_LetterCount + MsgLen) > MaxLettersPerCheckInterval)
		return false;

	owner.AS_LetterCount += MsgLen;
	owner.AS_LastMsg = Msg;
	owner.AS_LastMsgTime = owner.Level.TimeSeconds;

	return true;
}

defaultproperties
{
    SameTextIgnoreTime=2.00
    CheckInterval=3.00
    MaxLettersPerCheckInterval=200
}
