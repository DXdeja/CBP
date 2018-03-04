class CBPCarcass extends DeusExCarcass;

var float MaxDamagePercMass;
var float EnergyRecharge;

function InitFor(Actor Other)
{
	if (Other != None)
	{
		// set as unconscious or add the pawns name to the description
		if (!bAnimalCarcass)
		{
			if (bNotDead)
				itemName = msgNotDead;
			else if (Other.IsA('ScriptedPawn'))
				itemName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
		}

		Mass           = Other.Mass;
		Buoyancy       = Mass * 1.2;
		MaxDamage      = MaxDamagePercMass * Mass;
		if (ScriptedPawn(Other) != None)
			if (ScriptedPawn(Other).bBurnedToDeath)
				CumulativeDamage = MaxDamage-1;

		SetScaleGlow();

		// Will this carcass spawn flies?
		if (bAnimalCarcass)
		{
			itemName = msgAnimalCarcass;
			if (FRand() < 0.2)
				bGenerateFlies = true;
		}
		else if (!Other.IsA('Robot') && !bNotDead)
		{
			if (FRand() < 0.1)
				bGenerateFlies = true;
			bEmitCarcass = true;
		}

		if (Other.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// set the instigator and tag information
		if (Other.Instigator != None)
		{
			KillerBindName = Other.Instigator.BindName;
			KillerAlliance = Other.Instigator.Alliance;
		}
		else
		{
			KillerBindName = Other.BindName;
			KillerAlliance = '';
		}
		Tag = Other.Tag;
		Alliance = Pawn(Other).Alliance;
		CarcassName = Other.Name;
	}
}

function ChunkUp(int Damage)
{
	class'CBPGame'.static.SEF_ChunkUp(self);
	Super(Carcass).ChunkUp(Damage);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, name damageType)
{
	if (bInvincible)
		return;

	// only take "gib" damage from these damage types
	if ((damageType == 'Shot') || (damageType == 'Sabot') || (damageType == 'Exploded') || (damageType == 'Munch') ||
	    (damageType == 'Tantalus'))
	{
		if ((damageType != 'Munch') && (damageType != 'Tantalus'))
		{
			class'CBPGame'.static.SEF_SpawnBlood(self, HitLocation, Damage / 10);
            //spawn(class'BloodSpurt',,,HitLocation);
            //spawn(class'BloodDrop',,, HitLocation);
            //for (i=0; i<Damage; i+=10)
            //   spawn(class'BloodDrop',,, HitLocation);
		}

		// this section copied from Carcass::TakeDamage() and modified a little
		if (!bDecorative)
		{
			bBobbing = false;
			SetPhysics(PHYS_Falling);
		}
		if ((Physics == PHYS_None) && (Momentum.Z < 0))
			Momentum.Z *= -1;
		Velocity += 3 * momentum/(Mass + 200);
		if (DamageType == 'Shot')
			Damage *= 0.4;
		CumulativeDamage += Damage;
		if (CumulativeDamage >= MaxDamage)
			ChunkUp(Damage);
		if (bDecorative)
			Velocity = vect(0,0,0);
	}

	SetScaleGlow();
}

function Frob(Actor Frobber, Inventory frobWith)
{
	local Inventory item, nextItem, startItem;
	local Pawn P;
	local DeusExWeapon W;
	local bool bFoundSomething;
	local DeusExPlayer player;
	local ammo AmmoType;
	local bool bPickedItemUp;
	local POVCorpse corpse;
	local DeusExPickup invItem;
	local int itemCount;

//log("DeusExCarcass::Frob()--------------------------------");

	// Can we assume only the *PLAYER* would actually be frobbing carci?
	player = DeusExPlayer(Frobber);

	// No doublefrobbing in multiplayer.
	if (bQueuedDestroy)
		return;

	// if we've already been searched, let the player pick us up
	// don't pick up animal carcii
	if (!bAnimalCarcass)
	{
      // DEUS_EX AMSD Since we don't have animations for carrying corpses, and since it has no real use in multiplayer,
      // and since the PutInHand propagation doesn't just work, this is work we don't need to do.
      // Were you to do it, you'd need to check the respawning issue, destroy the POVcorpse it creates and point to the
      // one in inventory (like I did when giving the player starting inventory).
		if ((Inventory == None) && (player != None) && (player.inHand == None) && (Level.NetMode == NM_Standalone))
		{
			if (!bInvincible)
			{
				corpse = Spawn(class'POVCorpse');
				if (corpse != None)
				{
					// destroy the actual carcass and put the fake one
					// in the player's hands
					corpse.carcClassString = String(Class);
					corpse.KillerAlliance = KillerAlliance;
					corpse.KillerBindName = KillerBindName;
					corpse.Alliance = Alliance;
					corpse.bNotDead = bNotDead;
					corpse.bEmitCarcass = bEmitCarcass;
					corpse.CumulativeDamage = CumulativeDamage;
					corpse.MaxDamage = MaxDamage;
					corpse.CorpseItemName = itemName;
					corpse.CarcassName = CarcassName;
					corpse.Frob(player, None);
					corpse.SetBase(player);
					player.PutInHand(corpse);
					bQueuedDestroy=True;
					Destroy();
					return;
				}
			}
		}
	}

	bFoundSomething = False;
	bSearchMsgPrinted = False;
	P = Pawn(Frobber);
	if (P != None)
	{
		// Make sure the "Received Items" display is cleared
      // DEUS_EX AMSD Don't bother displaying in multiplayer.  For propagation
      // reasons it is a lot more of a hassle than it is worth.
		if ( (player != None) && (Level.NetMode == NM_Standalone) )
         DeusExRootWindow(player.rootWindow).hud.receivedItems.RemoveItems();

		if (Inventory != None)
		{

			item = Inventory;
			startItem = item;

			do
			{
//				log("===>DeusExCarcass:item="$item );

				nextItem = item.Inventory;

				bPickedItemUp = False;

				if (item.IsA('Ammo'))
				{
					// Only let the player pick up ammo that's already in a weapon
					DeleteInventory(item);
					item.Destroy();
					item = None;
				}
				else if ( (item.IsA('DeusExWeapon')) )
				{
               // Any weapons have their ammo set to a random number of rounds (1-4)
               // unless it's a grenade, in which case we only want to dole out one.
               // DEUS_EX AMSD In multiplayer, give everything away.
               W = DeusExWeapon(item);
               
               // Grenades and LAMs always pickup 1
               if (W.IsA('WeaponNanoVirusGrenade') || 
                  W.IsA('CBPWeaponGasGrenade') || 
                  W.IsA('CBPWeaponEMP') ||
                  W.IsA('CBPWeaponLAM'))
                  W.PickupAmmoCount = 1;
               else if (Level.NetMode == NM_Standalone)
                  W.PickupAmmoCount = Rand(4) + 1;
				}
				
				if (item != None)
				{
					bFoundSomething = True;

					if (item.IsA('NanoKey'))
					{
						if (player != None)
						{
							player.PickupNanoKey(NanoKey(item));
							AddReceivedItem(player, item, 1);
							DeleteInventory(item);
							item.Destroy();
							item = None;
						}
						bPickedItemUp = True;
					}
					else if (item.IsA('Credits'))		// I hate special cases
					{
						if (player != None)
						{
							AddReceivedItem(player, item, Credits(item).numCredits);
							player.Credits += Credits(item).numCredits;
							P.ClientMessage(Sprintf(Credits(item).msgCreditsAdded, Credits(item).numCredits));
							DeleteInventory(item);
							item.Destroy();
							item = None;
						}
						bPickedItemUp = True;
					}
					else if (item.IsA('DeusExWeapon'))   // I *really* hate special cases
					{
						// Okay, check to see if the player already has this weapon.  If so,
						// then just give the ammo and not the weapon.  Otherwise give
						// the weapon normally. 
						W = DeusExWeapon(player.FindInventoryType(item.Class));

						// If the player already has this item in his inventory, piece of cake,
						// we just give him the ammo.  However, if the Weapon is *not* in the 
						// player's inventory, first check to see if there's room for it.  If so,
						// then we'll give it to him normally.  If there's *NO* room, then we 
						// want to give the player the AMMO only (as if the player already had 
						// the weapon).

						if ((W != None) || ((W == None) && (!player.FindInventorySlot(item, True))))
						{
							// Don't bother with this is there's no ammo
							if ((Weapon(item).AmmoType != None) && (Weapon(item).AmmoType.AmmoAmount > 0))
							{
								AmmoType = Ammo(player.FindInventoryType(Weapon(item).AmmoName));

                        if ((AmmoType != None) && (AmmoType.AmmoAmount < AmmoType.MaxAmmo))
								{
                           AmmoType.AddAmmo(Weapon(item).PickupAmmoCount);
                           AddReceivedItem(player, AmmoType, Weapon(item).PickupAmmoCount);
                           
									// Update the ammo display on the object belt
									player.UpdateAmmoBeltText(AmmoType);

									// if this is an illegal ammo type, use the weapon name to print the message
									if (AmmoType.PickupViewMesh == Mesh'TestBox')
										P.ClientMessage(item.PickupMessage @ item.itemArticle @ item.itemName, 'Pickup');
									else
										P.ClientMessage(AmmoType.PickupMessage @ AmmoType.itemArticle @ AmmoType.itemName, 'Pickup');

									// Mark it as 0 to prevent it from being added twice
									Weapon(item).AmmoType.AmmoAmount = 0;
								}
							}

							// Print a message "Cannot pickup blah blah blah" if inventory is full
							// and the player can't pickup this weapon, so the player at least knows
							// if he empties some inventory he can get something potentially cooler
							// than he already has. 
							if ((W == None) && (!player.FindInventorySlot(item, True)))
								P.ClientMessage(Sprintf(Player.InventoryFull, item.itemName));

							// Only destroy the weapon if the player already has it.
							if (W != None)
							{
								// Destroy the weapon, baby!
								DeleteInventory(item);
								item.Destroy();
								item = None;
							}

							bPickedItemUp = True;
						}
					}

					else if (item.IsA('DeusExAmmo'))
					{
						if (DeusExAmmo(item).AmmoAmount == 0)
							bPickedItemUp = True;
					}

					if (!bPickedItemUp)
					{
						// Special case if this is a DeusExPickup(), it can have multiple copies
						// and the player already has it.

						if ((item.IsA('DeusExPickup')) && (DeusExPickup(item).bCanHaveMultipleCopies) && (player.FindInventoryType(item.class) != None))
						{
							invItem   = DeusExPickup(player.FindInventoryType(item.class));
							itemCount = DeusExPickup(item).numCopies;

							// Make sure the player doesn't have too many copies
							if ((invItem.MaxCopies > 0) && (DeusExPickup(item).numCopies + invItem.numCopies > invItem.MaxCopies))
							{	
								// Give the player the max #
								if ((invItem.MaxCopies - invItem.numCopies) > 0)
								{
									itemCount = (invItem.MaxCopies - invItem.numCopies);
									DeusExPickup(item).numCopies -= itemCount;
									invItem.numCopies = invItem.MaxCopies;
									P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
									AddReceivedItem(player, invItem, itemCount);
								}
								else
								{
									P.ClientMessage(Sprintf(msgCannotPickup, invItem.itemName));
								}
							}
							else
							{
								invItem.numCopies += itemCount;
								DeleteInventory(item);

								P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
								AddReceivedItem(player, invItem, itemCount);
							}
						}
						else
						{
							// check if the pawn is allowed to pick this up
							if ((P.Inventory == None) || (Level.Game.PickupQuery(P, item)))
							{
								DeusExPlayer(P).FrobTarget = item;
								if (DeusExPlayer(P).HandleItemPickup(Item) != False)
								{
                           DeleteInventory(item);

                           // DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
                           item.bInObjectBelt=False;
                           item.BeltPos=-1;
									
                           item.SpawnCopy(P);

									// Show the item received in the ReceivedItems window and also 
									// display a line in the Log
									AddReceivedItem(player, item, 1);
									
									P.ClientMessage(Item.PickupMessage @ Item.itemArticle @ Item.itemName, 'Pickup');
									PlaySound(Item.PickupSound);
								}
							}
							else
							{
								DeleteInventory(item);
								item.Destroy();
								item = None;
							}
						}
					}
				}

				item = nextItem;
			}
			until ((item == None) || (item == startItem));
		}

//log("  bFoundSomething = " $ bFoundSomething);

		if (!bFoundSomething)
			P.ClientMessage(msgEmpty);
	}

   if ((player != None) && (Level.Netmode != NM_Standalone) && EnergyRecharge > 0.0)
   {
      player.ClientMessage(Sprintf(msgRecharged, 25));
      
      PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
      
      player.Energy += EnergyRecharge;
      if (player.Energy > player.EnergyMax)
         player.Energy = player.EnergyMax;
   }

	Super(Carcass).Frob(Frobber, frobWith);

   if ((Level.Netmode != NM_Standalone) && (Player != None))   
   {
	   bQueuedDestroy = true;
	   Destroy();	  
   }
}

defaultproperties
{
    MaxDamagePercMass=0.80
    EnergyRecharge=25.00
    NetUpdateFrequency=10.00
}
