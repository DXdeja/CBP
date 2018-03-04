class CBPGasGrenade extends CBPThrownProjectile;

defaultproperties
{
    bSpawnClouds=True
    fuseLength=1.50
    proxRadius=128.00
    AISoundLevel=0.00
    bBlood=False
    bDebris=False
    DamageType=TearGas
    spawnWeaponClass=Class'CBPWeaponGasGrenade'
    bIgnoresNanoDefense=True
    ItemName="Gas Grenade"
    speed=1000.00
    MaxSpeed=1000.00
    Damage=20.00
    MomentumTransfer=50000
    ImpactSound=Sound'DeusExSounds.Weapons.GasGrenadeExplode'
    LifeSpan=0.00
    Mesh=LodMesh'DeusExItems.GasGrenadePickup'
    CollisionRadius=4.30
    CollisionHeight=1.40
    Mass=5.00
    Buoyancy=2.00
}
