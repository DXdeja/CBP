class CBPRocket extends Rocket;

auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (bStuck)
			return;

		if ((Other != instigator) && (DeusExProjectile(Other) == None) &&
			(Other != Owner))
		{
			damagee = Other;
			Explode(HitLocation, Normal(HitLocation-damagee.Location));

         if (Role == ROLE_Authority)
			{
            if (bBlood && CBPPlayer(damagee) != none && CBPPlayer(damagee).bCanBleed)
				class'CBPGame'.static.SEF_SpawnBloodFromProjectile(damagee, HitLocation, Normal(HitLocation - damagee.Location), Damage);
			}
		}
	}
}

defaultproperties
{
}
