class CBPAugDefense extends CBPAugmentation
	abstract;

const defenseSoundDelay = 2;

static function DeusExProjectile FindNearestProjectile(DeusExPlayer dxp)
{
   local DeusExProjectile proj, minproj;
   local float dist, mindist;
   local bool bValidProj;

   minproj = None;
   mindist = 999999;
   foreach dxp.AllActors(class'DeusExProjectile', proj)
   {
      bValidProj = !proj.bIgnoresNanoDefense;

      if (bValidProj)
      {
         // make sure we don't own it
         if (proj.Owner != dxp)
         {
			 // MBCODE : If team game, don't blow up teammates projectiles
			if (!((dxp.Level.Game.bTeamGame) && (class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(proj.Owner),dxp))))
			{
				// make sure it's moving fast enough
				if (VSize(proj.Velocity) > 100)
				{
				   dist = VSize(dxp.Location - proj.Location);
				   if (dist < mindist)
				   {
					  mindist = dist;
					  minproj = proj;
				   }
				}
			}
         }
      }
   }

   return minproj;
}

static function ActivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	manager.LastDefenseTime = dxp.Level.TimeSeconds;
}

static function DeactivateAction(DeusExPlayer dxp)
{
	local CBPAugmentationManager manager;
	manager = GetManager(dxp);
	manager.SetDefenseAugStatus(none);
	manager.bDefenseActive = false;
}

static function TickAction(DeusExPlayer dxp, float deltaTime)
{
	local CBPAugmentationManager manager;
	local DeusExProjectile minproj;
	local float mindist;

	manager = GetManager(dxp);

	if ((manager.LastDefenseTime + 0.1) < dxp.Level.TimeSeconds)
	{  
		manager.LastDefenseTime = dxp.Level.TimeSeconds;

		if (dxp.Level.Timeseconds > manager.defenseSoundTime)
		{
			dxp.PlaySound(Sound'AugDefenseOn', SLOT_Interact, 1.0, ,(default.LevelValues[3]*1.33), 0.75);
			manager.defenseSoundTime = dxp.Level.Timeseconds + defenseSoundDelay;
		}

		minproj = FindNearestProjectile(dxp);

		if (minproj != None)
		{
			manager.bDefenseActive = True;
			mindist = VSize(dxp.Location - minproj.Location);

			manager.SetDefenseAugStatus(minproj);

			// play a warning sound
			dxp.PlaySound(sound'GEPGunLock', SLOT_None,,,, 2.0);

			if (mindist < default.LevelValues[3])
			{
				minproj.bAggressiveExploded=True;
				minproj.Explode(minproj.Location, vect(0,0,1));
				dxp.PlaySound(sound'ProdFire', SLOT_None,,,, 2.0);
			}
		}
		else if (manager.bDefenseActive)
		{
			manager.SetDefenseAugStatus(none);
			manager.bDefenseActive = false;
		}
	}
}

defaultproperties
{
    OldAugClass=Class'DeusEx.AugDefense'
    ManagerIndex=12
    EnergyRate=35.00
    Icon=Texture'DeusExUI.UserInterface.AugIconDefense'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconDefense_Small'
    AugmentationName="Aggressive Defense System"
    LevelValues(0)=160.00
    LevelValues(1)=320.00
    LevelValues(2)=480.00
    LevelValues(3)=500.00
    MPConflictSlot=9
}
