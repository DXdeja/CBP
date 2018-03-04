class PawnType extends Object;

// gameplay
var float Mass;
var float Buoyancy;
var float GroundSpeed;
var float WaterSpeed;
var float UnderWaterTime;
var float AirSpeed;
var float AccelRate;
var float JumpZ;
var float AirControl;
var float CollisionRadius;
var float CollisionHeight;
var float SwimmingCollisionHeight;
var float CrouchingCollisionHeight;
var float BaseEyeHeight;
var float MeshAnimRate;
var bool bCanDuck;
var bool bCanJump;
var bool bCanRun;
var bool bCanSwim;
var int HealthTorso;
var float KillReward;

var class<CBPBeltInventory> BeltInventoryClass;
var class<CBPAugmentationManager> AugManagerClass;
var class<CBPSkillManager> SkillManagerClass;

// eating
var float EatTime;
var int EatDamage;
var int EatHeal;

// animal attack
var float AnimalAttackTime;
var int AnimalAttackDamage;
var float AnimalAttackMomentum;
var float AnimalAttackDistance;
var name AnimalAttackDamageType;

// animal shoot
var float AnimalShootTime;
var class<Projectile> AnimalShootProj;

// visual
var float DrawScale;
var mesh Mesh;
var texture MultiSkins[8];
var Rotator RotationRate;
var class<Carcass> CarcassType;
var bool bCanBleed;
var Texture Texture;
var Vector PrePivot;
var bool bOwnHealthBar;

// sounds
var sound WalkSound;
var sound AmbientSound;

static function float RandomPitch()
{
	return (1.1 - 0.2*FRand());
}

static function PlaySound_Jump(Actor owner);
static function PlaySound_Gasp(Actor owner);
static function PlaySound_Death(Actor owner);
static function PlaySound_WaterDeath(Actor owner);
static function PlaySound_PainSmall(Actor owner, optional float vol);
static function PlaySound_PainMedium(Actor owner, optional float vol);
static function PlaySound_PainLarge(Actor owner, optional float vol);
static function PlaySound_PainEye(Actor owner, optional float vol);
static function PlaySound_BodyHit(Actor owner, optional float vol);
static function PlaySound_Drown(Actor owner, optional float vol);
static function PlaySound_BodyThud(Actor owner);
static function PlaySound_Eat(Actor owner);
static function PlaySound_Roar(Actor owner);
static function PlaySound_Attack(Actor owner);
static function PlaySound_Shoot(Actor owner);

static function PlayAnimation_InAir(Actor owner);
static function PlayAnimation_Landed(Actor owner);
static function PlayAnimation_Crouch(Actor owner);
static function PlayAnimation_TweenToWalking(Actor owner, float tweentime);
static function PlayAnimation_Walking(Actor owner, float animrate);
static function PlayAnimation_TweenToRunning(Actor owner, float tweentime, float animrate);
static function PlayAnimation_Running(Actor owner, float animrate);
static function PlayAnimation_TweenToWaiting(Actor owner, float tweentime);
static function PlayAnimation_Waiting(Actor owner);
static function PlayAnimation_Swimming(Actor owner);
static function PlayAnimation_TweenToSwimming(Actor owner, float tweentime);
static function PlayAnimation_Rising(Actor owner);
static function PlayAnimation_Crawling(Actor owner);
static function PlayAnimation_Firing(Actor owner, DeusExWeapon W);
static function PlayAnimation_WeaponSwitch(Actor owner);
static function PlayAnimation_Pickup(Actor owner, Vector locPickup);
static function PlayAnimation_DeathWater(Actor owner);
static function PlayAnimation_DeathFront(Actor owner);
static function PlayAnimation_DeathBack(Actor owner);
static function PlayAnimation_Turning(Actor owner);
static function PlayAnimation_HitHead(Actor owner);
static function PlayAnimation_HitLegRight(Actor owner);
static function PlayAnimation_HitLegLeft(Actor owner);
static function PlayAnimation_HitArmRight(Actor owner);
static function PlayAnimation_HitArmLeft(Actor owner);
static function PlayAnimation_HitTorso(Actor owner);
static function PlayAnimation_HitHeadBack(Actor owner);
static function PlayAnimation_HitTorsoBack(Actor owner);
static function PlayAnimation_WaterHitTorso(Actor owner);
static function PlayAnimation_WaterHitTorsoBack(Actor owner);
static function PlayAnimation_Eat(Actor owner);
static function PlayAnimation_Roar(Actor owner);
static function PlayAnimation_Shoot(Actor owner);

static function bool PlayingAnimGroup_Waiting(Actor owner);
static function bool PlayingAnimGroup_Gesture(Actor owner);
static function bool PlayingAnimGroup_TakeHit(Actor owner);
static function bool PlayingAnimGroup_Landing(Actor owner);
static function bool PlayingAnimGroup_Attack(Actor owner);

static function Exec_Fire(CBPPlayer owner, optional float F);
static function Exec_AltFire(CBPPlayer owner, optional float F);
static function Exec_ParseLeftClick(CBPPlayer owner);
static function Exec_ParseRightClick(CBPPlayer owner);

static function bool IsFrobbable(CBPPlayer owner, Actor A);

static function GiveInitialInventory(CBPPlayer owner);

static function Event_Died(CBPPlayer owner, vector HitLocation);
static function Event_TakeDamage(Pawn owner, int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType);
static function Event_Bump(CBPPlayer owner, Actor Other);
static function Event_PlayerTick(CBPPlayer owner, float DeltaTime);
static function Event_ServerTick(CBPPlayer owner, float DeltaTime);
static function Event_HUDDraw(CBPPlayer owner, Canvas canvas);
static function Event_ExtHUDDraw(CBPPlayer owner, GC gc, Window w);
static function Event_GrantAugs(CBPPlayer owner, int NumAugs);
static function Event_LevelUpReward(CBPPlayer owner);
static function int Event_HealPlayer(CBPPlayer owner, int baseHealPoints, optional bool bUseMedicineSkill);

defaultproperties
{
    AirControl=0.05
    MeshAnimRate=1.00
    HealthTorso=100
    KillReward=1.00
    BeltInventoryClass=Class'CBPBeltInventory'
    AugManagerClass=Class'CBPAugmentationManager'
    SkillManagerClass=Class'CBPSkillManager'
    DrawScale=1.00
}
