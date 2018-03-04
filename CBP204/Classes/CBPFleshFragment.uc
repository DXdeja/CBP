class CBPFleshFragment extends FleshFragment;

function Tick(float deltaTime)
{
	Super(DeusExFragment).Tick(deltaTime);
	
	if (!IsInState('Dying'))
		if (FRand() < 0.5)
			Spawn(class'CBPBloodDrop',,, Location);
}

defaultproperties
{
}
