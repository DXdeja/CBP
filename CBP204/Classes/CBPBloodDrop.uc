class CBPBloodDrop extends BloodDrop;

auto state Flying
{
	function HitWall(vector HitNormal, actor Wall)
	{
		Spawn(class'CBPBloodSplat',,, Location, Rotator(HitNormal));
		Destroy();
	}
	function BeginState()
	{
		Velocity = VRand() * 100;
		DrawScale = 1.0 + FRand();
		SetRotation(Rotator(Velocity));
	}
}

function Tick(float deltaTime)
{
	if (Velocity == vect(0,0,0))
	{
		Spawn(class'CBPBloodSplat',,, Location, rot(16384,0,0));
		Destroy();
	}
	else
		SetRotation(Rotator(Velocity));
}

defaultproperties
{
}
