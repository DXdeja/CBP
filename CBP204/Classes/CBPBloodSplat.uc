class CBPBloodSplat extends BloodSplat;

function BeginPlay()
{
	local Rotator rot;
	local float rnd;

	rnd = FRand();
	if (rnd < 0.25)
		Texture = Texture'FlatFXTex3';
	else if (rnd < 0.5)
		Texture = Texture'FlatFXTex5';
	else if (rnd < 0.75)
		Texture = Texture'FlatFXTex6';

	DrawScale += FRand() * 0.2;

	Super(DeusExDecal).BeginPlay();
}

defaultproperties
{
}
