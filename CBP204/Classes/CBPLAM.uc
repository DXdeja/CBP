class CBPLAM extends CBPThrownProjectile;

simulated function Tick(float deltaTime)
{
	local float blinkRate;

	Super.Tick(deltaTime);

	if (bDisabled)
	{
		Skin = Texture'BlackMaskTex';
		return;
	}

	// flash faster as the time expires
	if (fuseLength - time <= 0.75)
		blinkRate = 0.1;
	else if (fuseLength - time <= fuseLength * 0.5)
		blinkRate = 0.3;
	else
		blinkRate = 0.5;

   if ((Level.NetMode == NM_Standalone) || (Role < ROLE_Authority) || (Level.NetMode == NM_ListenServer))
   {
      if (Abs((fuseLength - time)) % blinkRate > blinkRate * 0.5)
         Skin = Texture'BlackMaskTex';
      else
         Skin = Texture'LAM3rdTex1';
   }
}

defaultproperties
{
    fuseLength=1.50
    proxRadius=128.00
    spawnWeaponClass=Class'CBPWeaponLAM'
    bIgnoresNanoDefense=True
    ItemName="Lightweight Attack Munition (LAM)"
    speed=1000.00
    MaxSpeed=1000.00
    Damage=500.00
    MomentumTransfer=50000
    ImpactSound=Sound'DeusExSounds.Weapons.LAMExplode'
    ExplosionDecal=Class'DeusEx.ScorchMark'
    LifeSpan=0.00
    Mesh=LodMesh'DeusExItems.LAMPickup'
    CollisionRadius=4.30
    CollisionHeight=3.80
    Mass=5.00
    Buoyancy=2.00
}
