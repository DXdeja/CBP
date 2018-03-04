class CBPBloodSpurt extends BloodSpurt;

auto state Flying
{
	function BeginState()
	{
		Velocity = vect(0,0,0);
		DrawScale -= FRand() * 0.5;
		PlayAnim('Spurt');
	}
}

defaultproperties
{
}
