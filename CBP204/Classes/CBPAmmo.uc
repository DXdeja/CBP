class CBPAmmo extends DeusExAmmo;

var class<ShellCasing> ShellCasingSilentClass;
var class<ShellCasing> ShellCasingClass;

simulated function bool SimUseAmmo()
{
	local vector offset, tempvec, X, Y, Z;
	local ShellCasing shell;
	local DeusExWeapon W;

	if (GetPlayerPawn() != Owner) return false; // do not do this on server

	if (AmmoAmount > 0)
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
		offset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
		tempvec = 0.8 * Owner.CollisionHeight * Z;
		offset.Z += tempvec.Z;

		W = DeusExWeapon(Pawn(Owner).Weapon);

		if ((W != None) && ((W.NoiseLevel < 0.1) || W.bHasSilencer))
		{
			shell = spawn(ShellCasingSilentClass,,, Owner.Location + offset);
		}
		else
		{
			shell = spawn(ShellCasingClass,,, Owner.Location + offset);
		}

		if (shell != None)
		{
			shell.Velocity = (FRand()*20+90) * Y + (10-FRand()*20) * X;
			shell.Velocity.Z = 0;
		}

		return True;
	}
	return False;
}

defaultproperties
{
    ShellCasingSilentClass=Class'DeusEx.ShellCasingSilent'
    ShellCasingClass=Class'DeusEx.ShellCasing'
}
