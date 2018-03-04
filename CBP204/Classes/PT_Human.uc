class PT_Human extends PawnType;

static function PlayAnimation_InAir(Actor owner)
{
	if (CBPPlayer(owner) != none && CBPPlayer(owner).bIsCrouching) return;
	owner.PlayAnim('Jump', 3.0, 0.1);
}

static function PlayAnimation_Landed(Actor owner)
{
	if (CBPPlayer(owner) != none) CBPPlayer(owner).PlayFootStep();
	if (CBPPlayer(owner) != none && CBPPlayer(owner).bIsCrouching) return;
	owner.PlayAnim('Land', 3.0, 0.1);
}

static function PlayAnimation_Crouch(Actor owner)
{
	if (owner.AnimSequence != 'Crouch' && owner.AnimSequence != 'CrouchWalk')
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
		{
			owner.PlayAnim('CrouchShoot', , 0.1);
		}
		else
		{
			owner.PlayAnim('Crouch', , 0.1);
		}
	}
	else
	{
		owner.TweenAnim('CrouchWalk', 0.1);
	}
}

static function PlayAnimation_TweenToWalking(Actor owner, float tweentime)
{
	if (CBPPlayer(owner) != none && (CBPPlayer(owner).bForceDuck || CBPPlayer(owner).bCrouchOn))
	{
		owner.TweenAnim('CrouchWalk', tweentime);
	}
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
		{
			owner.TweenAnim('Walk2H', tweentime);
		}
		else
		{
			owner.TweenAnim('Walk', tweentime);
		}
	}
}

static function PlayAnimation_Walking(Actor owner, float animrate)
{
	local float newhumanAnimRate;

	// UnPhysic.cpp walk speed changed by proportion 0.7/0.3 (2.33), but that looks too goofy (fast as hell), so we'll try something a little slower
	newhumanAnimRate = animrate * 1.75;

	if (CBPPlayer(owner) != none && (CBPPlayer(owner).bForceDuck || CBPPlayer(owner).bCrouchOn))
	{
		owner.LoopAnim('CrouchWalk', newhumanAnimRate);
	}
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
		{
			owner.LoopAnim('Walk2H', newhumanAnimRate);
		}
		else
		{
			owner.LoopAnim('Walk', newhumanAnimRate);
		}
	}
}

static function PlayAnimation_TweenToRunning(Actor owner, float tweentime, float animrate)
{
	if (Pawn(owner) != none && Pawn(owner).bIsWalking)
	{
		PlayAnimation_TweenToWalking(owner, 0.1);
		return;
	}

	if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
	{
		if (CBPPlayer(owner).aStrafe != 0)
		{
			if (CBPPlayer(owner).HasTwoHandedWeapon())
				owner.PlayAnim('Strafe2H', animrate, tweentime);
			else
				owner.PlayAnim('Strafe', animrate, tweentime);
		}
		else
		{
			if (CBPPlayer(owner).HasTwoHandedWeapon())
				owner.PlayAnim('RunShoot2H', animrate, tweentime);
			else
				owner.PlayAnim('RunShoot', animrate, tweentime);
		}
	}
	else if (Pawn(Owner) != none && Pawn(Owner).bOnFire)
		owner.PlayAnim('Panic', animrate, tweentime);
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
			owner.PlayAnim('RunShoot2H', animrate, tweentime);
		else
			owner.PlayAnim('Run', animrate, tweentime);
	}
}

static function PlayAnimation_Running(Actor owner, float animrate)
{
	if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
	{
		if (CBPPlayer(owner).aStrafe != 0)
		{
			if (CBPPlayer(owner).HasTwoHandedWeapon())
				owner.LoopAnim('Strafe2H', animrate);
			else
				owner.LoopAnim('Strafe', animrate);
		}
		else
		{
			if (CBPPlayer(owner).HasTwoHandedWeapon())
				owner.LoopAnim('RunShoot2H', animrate);
			else
				owner.LoopAnim('RunShoot', animrate);
		}
	}
	else if (Pawn(Owner) != none && Pawn(Owner).bOnFire)
		owner.LoopAnim('Panic', animrate);
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
			owner.LoopAnim('RunShoot2H', animrate);
		else
			owner.LoopAnim('Run', animrate);
	}
}

static function PlayAnimation_TweenToWaiting(Actor owner, float tweentime)
{
	if (owner.IsInState('PlayerSwimming') || (owner.Physics == PHYS_Swimming))
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
			owner.LoopAnim('TreadShoot');
		else
			owner.LoopAnim('Tread');
	}
	else if (CBPPlayer(owner) != none && CBPPlayer(owner).bForceDuck)
		owner.TweenAnim('CrouchWalk', tweentime);
	else if ((owner.AnimSequence == 'Pickup' && owner.bAnimFinished) || 
		((owner.AnimSequence != 'Pickup') && CBPPlayer(owner) != none && !CBPPlayer(owner).IsFiring()))
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
			owner.TweenAnim('BreatheLight2H', tweentime);
		else
			owner.TweenAnim('BreatheLight', tweentime);
	}
}

static function PlayAnimation_Waiting(Actor owner)
{
	if (owner.IsInState('PlayerSwimming') || owner.Physics == PHYS_Swimming)
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
			owner.LoopAnim('TreadShoot');
		else
			owner.LoopAnim('Tread');
	}
	else if (CBPPlayer(owner) != none && CBPPlayer(owner).bForceDuck)
		owner.TweenAnim('CrouchWalk', 0.1);
	if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
	{
		if (CBPPlayer(owner).HasTwoHandedWeapon())
			owner.LoopAnim('BreatheLight2H');
		else
			owner.LoopAnim('BreatheLight');
	}
}

static function PlayAnimation_Swimming(Actor owner)
{
	owner.LoopAnim('Tread');
}

static function PlayAnimation_TweenToSwimming(Actor owner, float tweentime)
{
	owner.TweenAnim('Tread', tweentime);
}

static function PlayAnimation_Rising(Actor owner)
{
	owner.PlayAnim('Stand',,0.1);
}

static function PlayAnimation_Crawling(Actor owner)
{
	if (CBPPlayer(owner) != none && CBPPlayer(owner).IsFiring())
		owner.LoopAnim('CrouchShoot');
	else
		owner.LoopAnim('CrouchWalk');
}

static function PlayAnimation_Firing(Actor owner, DeusExWeapon W)
{
	if (W != None)
	{
		if (owner.IsInState('PlayerSwimming') || (owner.Physics == PHYS_Swimming))
			owner.LoopAnim('TreadShoot',,0.1);
		else if (W.bHandToHand)
		{
			if (owner.bAnimFinished || (owner.AnimSequence != 'Attack'))
				owner.PlayAnim('Attack',,0.1);
		}
		else if (CBPPlayer(owner) != none && CBPPlayer(owner).bIsCrouching)
			owner.LoopAnim('CrouchShoot',,0.1);
		else
		{
			if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
				owner.LoopAnim('Shoot2H',,0.1);
			else
				owner.LoopAnim('Shoot',,0.1);
		}
	}
}

static function PlayAnimation_WeaponSwitch(Actor owner)
{
	if (CBPPlayer(owner) != none && !CBPPlayer(owner).bIsCrouching && !CBPPlayer(owner).bForceDuck && !CBPPlayer(owner).bCrouchOn)
		owner.PlayAnim('Reload');
}

static function PlayAnimation_Pickup(Actor owner, Vector locPickup)
{
	if (owner.Location.Z - locPickup.Z < 16)
		owner.PlayAnim('PushButton',,0.1);
	else
		owner.PlayAnim('Pickup',,0.1);
}

static function PlayAnimation_DeathWater(Actor owner)
{
	owner.PlayAnim('WaterDeath',,0.1);
}

static function PlayAnimation_DeathFront(Actor owner)
{
	owner.PlayAnim('DeathFront',,0.1);
}

static function PlayAnimation_DeathBack(Actor owner)
{
	owner.PlayAnim('DeathBack',,0.1);
}

static function PlayAnimation_Turning(Actor owner)
{
	if (CBPPlayer(owner) != none && (CBPPlayer(owner).bForceDuck || CBPPlayer(owner).bCrouchOn))
		owner.TweenAnim('CrouchWalk', 0.1);
	else
	{
		if (CBPPlayer(owner) != none && CBPPlayer(owner).HasTwoHandedWeapon())
			owner.TweenAnim('Walk2H', 0.1);
		else
			owner.TweenAnim('Walk', 0.1);
	}
}

static function PlayAnimation_HitHead(Actor owner)
{
	owner.PlayAnim('HitHead',,0.10);
}

static function PlayAnimation_HitLegRight(Actor owner)
{
	owner.PlayAnim('HitLegRight',,0.10);
}

static function PlayAnimation_HitLegLeft(Actor owner)
{
	owner.PlayAnim('HitLegLeft',,0.10);
}

static function PlayAnimation_HitArmRight(Actor owner)
{
	owner.PlayAnim('HitArmRight',,0.10);
}

static function PlayAnimation_HitArmLeft(Actor owner)
{
	owner.PlayAnim('HitArmLeft',,0.10);
}

static function PlayAnimation_HitTorso(Actor owner)
{
	owner.PlayAnim('HitTorso',,0.10);
}

static function PlayAnimation_HitHeadBack(Actor owner)
{
	owner.PlayAnim('HitHeadBack',,0.10);
}

static function PlayAnimation_HitTorsoBack(Actor owner)
{
	owner.PlayAnim('HitTorsoBack',,0.10);
}

static function PlayAnimation_WaterHitTorso(Actor owner)
{
	owner.PlayAnim('WaterHitTorso',,0.10);
}

static function PlayAnimation_WaterHitTorsoBack(Actor owner)
{
	owner.PlayAnim('WaterHitTorsoBack',,0.10);
}


static function PlaySound_Jump(Actor owner)
{
	owner.PlaySound(Sound'DeusExSounds.Player.MaleJump', SLOT_None, 1.5, true, 1200, 1.0 - 0.2*FRand());
}

static function PlaySound_Gasp(Actor owner)
{
	owner.PlaySound(sound'MaleGasp', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_Death(Actor owner)
{
	owner.PlaySound(sound'MaleDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_WaterDeath(Actor owner)
{
	owner.PlaySound(sound'MaleWaterDeath', SLOT_Pain,,,, RandomPitch());
}

static function PlaySound_PainSmall(Actor owner, optional float vol)
{
	owner.PlaySound(sound'MalePainSmall', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainMedium(Actor owner, optional float vol)
{
	owner.PlaySound(sound'MalePainMedium', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainLarge(Actor owner, optional float vol)
{
	owner.PlaySound(sound'MalePainLarge', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_PainEye(Actor owner, optional float vol)
{
	owner.PlaySound(sound'MaleEyePain', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_BodyHit(Actor owner, optional float vol)
{
	owner.PlaySound(sound'BodyHit', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_Drown(Actor owner, optional float vol)
{
	owner.PlaySound(sound'MaleDrown', SLOT_Pain, vol,,, RandomPitch());
}

static function PlaySound_BodyThud(Actor owner)
{
	owner.PlaySound(sound'BodyThud', SLOT_Interact);
}

static function bool PlayingAnimGroup_Waiting(Actor owner)
{
	if (owner.GetAnimGroup(owner.AnimSequence) == 'Waiting') return true;
	else return false;
}

static function bool PlayingAnimGroup_Gesture(Actor owner)
{
	if (owner.GetAnimGroup(owner.AnimSequence) == 'Gesture') return true;
	else return false;
}

static function bool PlayingAnimGroup_TakeHit(Actor owner)
{
	if (owner.GetAnimGroup(owner.AnimSequence) == 'TakeHit') return true;
	else return false;
}

static function bool PlayingAnimGroup_Landing(Actor owner)
{
	if (owner.GetAnimGroup(owner.AnimSequence) == 'Landing') return true;
	else return false;
}

static function Exec_Fire(CBPPlayer owner, optional float F)
{
	owner.RegularFire(F);
}

static function Exec_AltFire(CBPPlayer owner, optional float F)
{
	owner.RegularAltFire(F);
}

static function Exec_ParseLeftClick(CBPPlayer owner)
{
	owner.RegularParseLeftClick();
}

static function Exec_ParseRightClick(CBPPlayer owner)
{
	owner.RegularParseRightClick();
}

static function bool IsFrobbable(CBPPlayer owner, Actor A)
{
	if (!A.bHidden)
		if (A.IsA('Mover') || A.IsA('DeusExDecoration') || A.IsA('Inventory') ||
			A.IsA('ScriptedPawn') || A.IsA('DeusExCarcass') || A.IsA('DeusExProjectile'))
			return True;

	return False;
}

static function Event_TakeDamage(Pawn owner, int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	CBPPlayer(owner).RegularTakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

static function Event_GrantAugs(CBPPlayer owner, int NumAugs)
{
	owner.RegularGrantAugs(NumAugs);
}

static function int Event_HealPlayer(CBPPlayer owner, int baseHealPoints, optional bool bUseMedicineSkill)
{
	return owner.RegularHealPlayer(baseHealPoints, bUseMedicineSkill);
}

defaultproperties
{
    Mass=150.00
    Buoyancy=155.00
    GroundSpeed=230.00
    WaterSpeed=110.00
    UnderWaterTime=20.00
    AirSpeed=4000.00
    AccelRate=1000.00
    JumpZ=300.00
    CollisionRadius=20.00
    CollisionHeight=47.50
    SwimmingCollisionHeight=16.00
    CrouchingCollisionHeight=30.00
    BaseEyeHeight=40.00
    MeshAnimRate=0.72
    bCanDuck=True
    bCanJump=True
    bCanRun=True
    bCanSwim=True
    RotationRate=(Pitch=4096,Yaw=50000,Roll=3072),
    bCanBleed=True
}
