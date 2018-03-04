class CBPEMP extends CBPThrownProjectile;

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ExplosionLight light;
	local SphereEffect sphere;
   local ExplosionSmall expeffect;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	if (light != None)
	{
      if (!bDamaged)
         light.RemoteRole = ROLE_None;
		light.size = 8;
		light.LightHue = 128;
		light.LightSaturation = 96;
		light.LightEffect = LE_Shell;
	}

	expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
   if ((expeffect != None) && (!bDamaged))
      expeffect.RemoteRole = ROLE_None;

	// draw a cool light sphere
	sphere = Spawn(class'SphereEffect',,, HitLocation);
	if (sphere != None)
   {
      if (!bDamaged)
         sphere.RemoteRole = ROLE_None;
		sphere.size = blastRadius / 32.0;
   }
}

defaultproperties
{
    fuseLength=1.50
    proxRadius=128.00
    AISoundLevel=0.10
    bBlood=False
    bDebris=False
    blastRadius=768.00
    DamageType=EMP
    spawnWeaponClass=Class'CBPWeaponEMP'
    bIgnoresNanoDefense=True
    ItemName="Electromagnetic Pulse (EMP) Grenade"
    speed=1000.00
    MaxSpeed=1000.00
    Damage=200.00
    MomentumTransfer=50000
    ImpactSound=Sound'DeusExSounds.Weapons.EMPGrenadeExplode'
    LifeSpan=0.00
    Mesh=LodMesh'DeusExItems.EMPGrenadePickup'
    CollisionRadius=3.00
    CollisionHeight=1.90
    Mass=5.00
    Buoyancy=2.00
}
