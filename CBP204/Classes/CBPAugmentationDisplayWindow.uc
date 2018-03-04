class CBPAugmentationDisplayWindow extends AugmentationDisplayWindow;

function SetSkins (Actor ZFB, out Texture ZFC[9])
{
	local int VD3;

	VD3=0;
JL0007:
	if ( VD3 < 8 )
	{
		ZFC[VD3]=ZFB.MultiSkins[VD3];
		VD3++;
		goto JL0007;
	}
	ZFC[VD3]=ZFB.Skin;
	if ( ZFB.Mesh != None )
	{
		VD3=0;
JL0072:
		if ( VD3 < 8 )
		{
			ZFB.MultiSkins[VD3]=GetGridTexture(ZFB.GetMeshTexture(VD3));
			VD3++;
			goto JL0072;
		}
	} else {
		VD3=0;
JL00BE:
		if ( VD3 < 8 )
		{
			ZFB.MultiSkins[VD3]=None;
			VD3++;
			goto JL00BE;
		}
	}
	ZFB.Skin=GetGridTexture(ZFC[VD3]);
}

function GetTargetReticleColor (Actor ZFD, out Color ZFE)
{
	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
	{
		if (  !ZFD.IsA('DeusExPlayer') || (DeusExPlayer(ZFD).PlayerReplicationInfo != None) )
		{
			GetTargetReticleColorX(ZFD,ZFE);
		}
	}
}

function PostDrawWindow(GC gc)
{
	super.PostDrawWindow(gc);
	if (CBPPlayer(player) != none && CBPPlayer(player).PawnInfo != none && CBPPlayer(player).bIsAlive)
		CBPPlayer(player).PawnInfo.static.Event_ExtHUDDraw(CBPPlayer(player), gc, self);
}

function GetTargetReticleColorX( Actor target, out Color xcolor )
{
	local DeusExPlayer safePlayer;
	local AutoTurret turret;
	local bool bDM, bTeamDM;
	local Vector dist;
   local float SightDist;
	local DeusExWeapon w;
	local int team;
	local String titleString;

	bTeamDM = player.GameReplicationInfo.bTeamGame;
	bDM = !bTeamDM;

	if ( target.IsA('ScriptedPawn') )
	{
		if (ScriptedPawn(target).GetPawnAllianceType(Player) == ALLIANCE_Hostile)
			xcolor = colRed;
		else
			xcolor = colGreen;
	}
	else if ( Player.Level.NetMode != NM_Standalone )	// Only do the rest in multiplayer
	{
		if ( target.IsA('DeusExPlayer') && (target != player) )	// Other players IFF
		{
			if ( bTeamDM && (class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(target),player)) )
			{ 
				xcolor = colGreen;
				if ( (Player.mpMsgFlags & Player.MPFLAG_FirstSpot) != Player.MPFLAG_FirstSpot )
					Player.MultiplayerNotifyMsg( Player.MPMSG_TeamSpot );
			}
			else
				xcolor = colRed;

         SightDist = VSize(target.Location - Player.Location);

			if ( ( bTeamDM && (class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(target),player))) ||
				  (target.Style != STY_Translucent) || (bVisionActive && (Sightdist <= visionLevelvalue)) )              
			{
				targetPlayerName = DeusExPlayer(target).PlayerReplicationInfo.PlayerName;
            // DEUS_EX AMSD Show health of enemies with the target active.
            if (bTargetActive)
               TargetPlayerHealthString = "(" $ int(100 * (DeusExPlayer(target).Health / Float(DeusExPlayer(target).Default.Health))) $ "%)";
				targetOutOfRange = False;
				w = DeusExWeapon(player.Weapon);
				if (( w != None ) && ( xcolor != colGreen ))
				{
					dist = player.Location - target.Location;
					if ( VSize(dist) > w.maxRange ) 
					{
						if (!(( WeaponAssaultGun(w) != None ) && ( Ammo20mm(WeaponAssaultGun(w).AmmoType) != None )))
						{
							targetRangeTime = Player.Level.Timeseconds + 0.1;
							targetOutOfRange = True;
						}
					}
				}
				targetPlayerTime = Player.Level.Timeseconds + targetPlayerDelay;
				targetPlayerColor = xcolor;
			}
			else
				xcolor = colWhite;	// cloaked enemy
		}
		else if (target.IsA('ThrownProjectile'))	// Grenades IFF
		{
			if ( ThrownProjectile(target).bDisabled )
				xcolor = colWhite;
			else if ( (bTeamDM && (ThrownProjectile(target).team == player.PlayerReplicationInfo.team)) || 
				(player == DeusExPlayer(target.Owner)) )
				xcolor = colGreen;
			else
				xcolor = colRed;
		}
		else if ( target.IsA('AutoTurret') || target.IsA('AutoTurretGun') ) // Autoturrets IFF
		{
			if ( target.IsA('AutoTurretGun') )
			{
				team = AutoTurretGun(target).team;
				titleString = AutoTurretGun(target).titleString;
			}
			else
			{
				team = AutoTurret(target).team;
				titleString = AutoTurret(target).titleString;
			}
			if ( (bTeamDM && (player.PlayerReplicationInfo.team == team)) ||
				  (!bTeamDM && (player.PlayerReplicationInfo.PlayerID == team)) )
				xcolor = colGreen;
			else if (team == -1)
				xcolor = colWhite;
			else
				xcolor = colRed;

			targetPlayerName = titleString;
			targetOutOfRange = False;
			targetPlayerTime = Player.Level.Timeseconds + targetPlayerDelay;
			targetPlayerColor = xcolor;
		}
		else if ( target.IsA('ComputerSecurity'))
		{
			if ( ComputerSecurity(target).team == -1 )
				xcolor = colWhite;
			else if ((bTeamDM && (ComputerSecurity(target).team==player.PlayerReplicationInfo.team)) ||
						 (bDM && (ComputerSecurity(target).team==player.PlayerReplicationInfo.PlayerID)))
				xcolor = colGreen;
			else
				xcolor = colRed;
		}
		else if ( target.IsA('SecurityCamera'))
		{
         if ( !SecurityCamera(target).bActive )
            xcolor = colWhite;
			else if ( SecurityCamera(target).team == -1 )
				xcolor = colWhite;
			else if ((bTeamDM && (SecurityCamera(target).team==player.PlayerReplicationInfo.team)) ||
						 (bDM && (SecurityCamera(target).team==player.PlayerReplicationInfo.PlayerID)))
				xcolor = colGreen;
			else
				xcolor = colRed;
		}
	}
}

function DrawTargetAugmentation(GC gc)
{
	local String str;
	local Actor target;
	local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
	local float x, y, w, h, mult;
	local Vector v1, v2;
	local int i, j, k;
	local DeusExWeapon weapon;
	local bool bUseOldTarget;
	local Color crossColor;
	local DeusExPlayer own;
	local vector AimLocation;
	local int AimBodyPart;


	crossColor.R = 255; crossColor.G = 255; crossColor.B = 255;

	// check 500 feet in front of the player
	target = TraceLOS(8000,AimLocation);

   targetplayerhealthstring = "";
   targetplayerlocationstring = "";

	if ( target != None )
	{
		GetTargetReticleColor( target, crossColor );

		if ((DeusExPlayer(target) != None) && (bTargetActive))
		{
			AimBodyPart = DeusExPlayer(target).GetMPHitLocation(AimLocation); // fix this
			if (AimBodyPart == 1)
				TargetPlayerLocationString = "("$msgHead$")";
			else if ((AimBodyPart == 2) || (AimBodyPart == 5) || (AimBodyPart == 6))
				TargetPlayerLocationString = "("$msgTorso$")";
			else if ((AimBodyPart == 3) || (AimBodyPart == 4))
				TargetPlayerLocationString = "("$msgLegs$")";
		}

		weapon = DeusExWeapon(Player.Weapon);
		if ((weapon != None) && !weapon.bHandToHand && !bUseOldTarget && !player.bShowScores)
		{
			// if the target is out of range, don't draw the reticle
			if (weapon.MaxRange >= VSize(target.Location - Player.Location))
			{
				w = width;
				h = height;
				x = int(w * 0.5)-1;
				y = int(h * 0.5)-1;

				// scale based on screen resolution - default is 640x480
				mult = FClamp(weapon.currentAccuracy * 80.0 * (width/640.0), corner, 80.0);

				// make sure it's not too close to the center unless you have a perfect accuracy
				mult = FMax(mult, corner+4.0);
				if (weapon.currentAccuracy == 0.0)
					mult = corner;

				// draw the drop shadowed reticle
				gc.SetTileColorRGB(0,0,0);
				for (i=1; i>=0; i--)
				{
					gc.DrawBox(x+i, y-mult+i, 1, corner, 0, 0, 1, Texture'Solid');
					gc.DrawBox(x+i, y+mult-corner+i, 1, corner, 0, 0, 1, Texture'Solid');
					gc.DrawBox(x-(corner-1)/2+i, y-mult+i, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(x-(corner-1)/2+i, y+mult+i, corner, 1, 0, 0, 1, Texture'Solid');

					gc.DrawBox(x-mult+i, y+i, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(x+mult-corner+i, y+i, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(x-mult+i, y-(corner-1)/2+i, 1, corner, 0, 0, 1, Texture'Solid');
					gc.DrawBox(x+mult+i, y-(corner-1)/2+i, 1, corner, 0, 0, 1, Texture'Solid');

					gc.SetTileColor(crossColor);
				}
			}
		}
		// movers are invalid targets for the aug
		if (target.IsA('DeusExMover'))
			target = None;
	}

	// let there be a 0.5 second delay before losing a target
	if (target == None)
	{
		if ((Player.Level.TimeSeconds - lastTargetTime < 0.5) && IsActorValid(lastTarget))
		{
			target = lastTarget;
			bUseOldTarget = True;
		}
		else
		{
			RemoveActorRef(lastTarget);
			lastTarget = None;
		}
	}
	else
	{
		lastTargetTime = Player.Level.TimeSeconds;
		bUseOldTarget = False;
		if (lastTarget != target)
		{
			RemoveActorRef(lastTarget);
			lastTarget = target;
			AddActorRef(lastTarget);
		}
	}

	if (target != None)
	{
		// draw a cornered targetting box
		v1.X = target.CollisionRadius;
		v1.Y = target.CollisionRadius;
		v1.Z = target.CollisionHeight;

		if (ConvertVectorToCoordinates(target.Location, boxCX, boxCY))
		{
			boxTLX = boxCX;
			boxTLY = boxCY;
			boxBRX = boxCX;
			boxBRY = boxCY;

			// get the smallest box to enclose actor
			// modified from Scott's ActorDisplayWindow
			for (i=-1; i<=1; i+=2)
			{
				for (j=-1; j<=1; j+=2)
				{
					for (k=-1; k<=1; k+=2)
					{
						v2 = v1;
						v2.X *= i;
						v2.Y *= j;
						v2.Z *= k;
						v2.X += target.Location.X;
						v2.Y += target.Location.Y;
						v2.Z += target.Location.Z;

						if (ConvertVectorToCoordinates(v2, x, y))
						{
							boxTLX = FMin(boxTLX, x);
							boxTLY = FMin(boxTLY, y);
							boxBRX = FMax(boxBRX, x);
							boxBRY = FMax(boxBRY, y);
						}
					}
				}
			}

			boxTLX = FClamp(boxTLX, margin, width-margin);
			boxTLY = FClamp(boxTLY, margin, height-margin);
			boxBRX = FClamp(boxBRX, margin, width-margin);
			boxBRY = FClamp(boxBRY, margin, height-margin);

			boxW = boxBRX - boxTLX;
			boxH = boxBRY - boxTLY;

			if ((bTargetActive) && (Player.Level.Netmode == NM_Standalone))
			{
				// set the coords of the zoom window, and draw the box
				// even if we don't have a zoom window
				x = width/8 + margin;
				y = height/2;
				w = width/4;
				h = height/4;

				DrawDropShadowBox(gc, x-w/2, y-h/2, w, h);

				boxCX = width/8 + margin;
				boxCY = height/2;
				boxTLX = boxCX - width/8;
				boxTLY = boxCY - height/8;
				boxBRX = boxCX + width/8;
				boxBRY = boxCY + height/8;

				if (targetLevel > 2)
				{
					if (winZoom != None)
					{
						mult = (target.CollisionRadius + target.CollisionHeight);
						v1 = Player.Location;
						v1.Z += Player.BaseEyeHeight;
						v2 = 1.5 * Player.Normal(target.Location - v1);
						winZoom.SetViewportLocation(target.Location - mult * v2);
						winZoom.SetWatchActor(target);
					}
					// window construction now happens in Tick()
				}
				else
				{
					// black out the zoom window and draw a "no image" message
					gc.SetStyle(DSTY_Normal);
					gc.SetTileColorRGB(0,0,0);
					gc.DrawPattern(boxTLX, boxTLY, w, h, 0, 0, Texture'Solid');

					gc.SetTextColorRGB(255,255,255);
					gc.GetTextExtent(0, w, h, msgNoImage);
					x = boxCX - w/2;
					y = boxCY - h/2;
					gc.DrawText(x, y, w, h, msgNoImage);
				}

				// print the name of the target above the box
				if (target.IsA('Pawn'))
					str = target.BindName;
				else if (target.IsA('DeusExDecoration'))
					str = DeusExDecoration(target).itemName;
				else if (target.IsA('DeusExProjectile'))
					str = DeusExProjectile(target).itemName;
				else
					str = target.GetItemName(String(target.Class));

				// print disabled robot info
				if (target.IsA('Robot') && (Robot(target).EMPHitPoints == 0))
					str = str $ " (" $ msgDisabled $ ")";
				gc.SetTextColor(crossColor);

				// print the range to target
				mult = VSize(target.Location - Player.Location);
				str = str $ CR() $ msgRange @ Int(mult/16) @ msgRangeUnits;

				gc.GetTextExtent(0, w, h, str);
				x = boxTLX + margin;
				y = boxTLY - h - margin;
				gc.DrawText(x, y, w, h, str);

				// level zero gives very basic health info
				if (target.IsA('Pawn'))
					mult = Float(Pawn(target).Health) / Float(Pawn(target).Default.Health);
				else if (target.IsA('DeusExDecoration'))
					mult = Float(DeusExDecoration(target).HitPoints) / Float(DeusExDecoration(target).Default.HitPoints);
				else
					mult = 1.0;

				if (targetLevel == 0)
				{
					// level zero only gives us general health readings
					if (mult >= 0.66)
					{
						str = msgHigh;
						mult = 1.0;
					}
					else if (mult >= 0.33)
					{
						str = msgMedium;
						mult = 0.5;
					}
					else
					{
						str = msgLow;
						mult = 0.05;
					}

					str = str @ msgHealth;
				}
				else
				{
					// level one gives exact health readings
					str = Int(mult * 100.0) $ msgPercent;
					if (target.IsA('Pawn') && !target.IsA('Robot') && !target.IsA('Animal'))
					{
						x = mult;		// save this for color calc
						str = str @ msgOverall;
						mult = Float(Pawn(target).HealthHead) / Float(Pawn(target).Default.HealthHead);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgHead;
						mult = Float(Pawn(target).HealthTorso) / Float(Pawn(target).Default.HealthTorso);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgTorso;
						mult = Float(Pawn(target).HealthArmLeft) / Float(Pawn(target).Default.HealthArmLeft);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgLeftArm;
						mult = Float(Pawn(target).HealthArmRight) / Float(Pawn(target).Default.HealthArmRight);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgRightArm;
						mult = Float(Pawn(target).HealthLegLeft) / Float(Pawn(target).Default.HealthLegLeft);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgLeftLeg;
						mult = Float(Pawn(target).HealthLegRight) / Float(Pawn(target).Default.HealthLegRight);
						str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgRightLeg;
						mult = x;
					}
					else
					{
						str = str @ msgHealth;
					}
				}

				gc.GetTextExtent(0, w, h, str);
				x = boxTLX + margin;
				y = boxTLY + margin;
				gc.SetTextColor(GetColorScaled(mult));
				gc.DrawText(x, y, w, h, str);
				gc.SetTextColor(colHeaderText);

				if (targetLevel > 1)
				{
					// level two gives us weapon info as well
					if (target.IsA('Pawn'))
					{
						str = msgWeapon;
	
						if (Pawn(target).Weapon != None)
							str = str @ target.GetItemName(String(Pawn(target).Weapon.Class));
						else
							str = str @ msgNone;

						gc.GetTextExtent(0, w, h, str);
						x = boxTLX + margin;
						y = boxBRY - h - margin;
						gc.DrawText(x, y, w, h, str);
					}
				}
			}
			else
			{
				// display disabled robots
				if (target.IsA('Robot') && (Robot(target).EMPHitPoints == 0))
				{
					str = msgDisabled;
					gc.SetTextColor(crossColor);
					gc.GetTextExtent(0, w, h, str);
					x = boxCX - w/2;
					y = boxTLY - h - margin;
					gc.DrawText(x, y, w, h, str);
				}
			}
		}
	}
	else if ((bTargetActive) && (Player.Level.NetMode == NM_Standalone))
	{
		if (Player.Level.TimeSeconds % 1.5 > 0.75)
			str = msgScanning1;
		else
			str = msgScanning2;
		gc.GetTextExtent(0, w, h, str);
		x = width/2 - w/2;
		y = (height/2 - h) - 20;
		gc.DrawText(x, y, w, h, str);
	}

	// set the crosshair colors
	DeusExRootWindow(player.rootWindow).hud.cross.SetCrosshairColor(crossColor);
}


// ----------------------------------------------------------------------
// DrawMiscStatusMessages()
// ----------------------------------------------------------------------
function DrawMiscStatusMessages( GC gc )
{
	local DeusExWeapon weap;
	local float x, y, w, h, cury;
	local Color msgColor;
	local String str;
	local bool bNeutralMsg;

	bNeutralMsg = False;

	if (( Player.Level.Timeseconds < Player.mpMsgTime ) && !Player.bShowScores )
	{
		msgColor = colGreen;

		switch( Player.mpMsgCode )
		{
			case Player.MPMSG_TeamUnatco:
				str = msgTeamUnatco;
				cury = TopCentralMessage( gc, str, msgColor );
				if ( keyTalk ~= KeyNotBoundString )
					RefreshMultiplayerKeys();
				str = UseString $ keyTalk $ TalkString;
				gc.GetTextExtent( 0, w, h, str );
				cury += h;
				DrawFadedText( gc, (width * 0.5) - (w * 0.5), cury, msgColor, str );
				if ( Player.GameReplicationInfo.bTeamGame )
				{
					cury += h;
					if ( keyTeamTalk ~= KeyNotBoundString )
						RefreshMultiplayerKeys();
					str = UseString $ keyTeamTalk $ TeamTalkString;
					gc.GetTextExtent( 0, w, h, str );
					DrawFadedText( gc, (width * 0.5) - (w * 0.5), cury, msgColor, str );
				}
				break;
			case Player.MPMSG_TeamNsf:
				str = msgTeamNsf;
				cury = TopCentralMessage( gc, str, msgColor );
				if ( keyTalk ~= KeyNotBoundString )
					RefreshMultiplayerKeys();
				str = UseString $ keyTalk $ TalkString;
				gc.GetTextExtent( 0, w, h, str );
				cury += h;
				DrawFadedText( gc, (width * 0.5) - (w * 0.5), cury, msgColor, str );
				if ( Player.GameReplicationInfo.bTeamGame )
				{
					cury += h;
					if ( keyTeamTalk ~= KeyNotBoundString )
						RefreshMultiplayerKeys();
					str = UseString $ keyTeamTalk $ TeamTalkString;
					gc.GetTextExtent( 0, w, h, str );
					DrawFadedText( gc, (width * 0.5) - (w * 0.5), cury, msgColor, str );
				}
				break;
			case Player.MPMSG_TeamHit:
				msgColor = colRed;
				str = msgTeammateHit;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_TeamSpot:
				str = SpottedTeamString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_FirstPoison:
				str = YouArePoisonedString;
				cury = TopCentralMessage( gc, str, msgColor );
				gc.GetTextExtent( 0, w, h, NeutBurnPoisonString );
				x = (width * 0.5) - (w * 0.5);
				DrawFadedText( gc, x, cury, msgColor, NeutBurnPoisonString );
				break;
			case Player.MPMSG_FirstBurn:
				str = YouAreBurnedString;
				cury = TopCentralMessage( gc, str, msgColor );
				gc.GetTextExtent( 0, w, h, NeutBurnPoisonString );
				x = (width * 0.5) - (w * 0.5);
				DrawFadedText( gc, x, cury, msgColor, NeutBurnPoisonString );
				break;
			case Player.MPMSG_TurretInv:
				str = TurretInvincibleString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_CameraInv:
				str = CameraInvincibleString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_CloseKills:
				if ( Player.mpMsgOptionalParam > 1 )
					str = OnlyString $ Player.mpMsgOptionalParam $ KillsToGoString;
				else
					str = OnlyString $ Player.mpMsgOptionalParam $ KillToGoString;
				if ( Player.mpMsgOptionalString ~= "Tied" )	// Should only happen in a team game
					str = str $ TiedMatchString;
				else
					str = str $ Player.mpMsgOptionalString $ WillWinMatchString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_TimeNearEnd:
				if ( Player.mpMsgOptionalParam > 1 )
					str = LessThanXString1 $ Player.mpMsgOptionalParam $ LessThanXString2;
				else
					str = LessThanMinuteString;

				if ( Player.mpMsgOptionalString ~= "Tied" )	// Should only happen in a team game
					str = str $ TiedMatchString;
				else
					str = str $ Player.mpMsgOptionalString $ LeadsMatchString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_LostLegs:
				str = LostLegsString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_DropItem:
				if ( keyDropItem ~= KeyNotBoundString )
					RefreshMultiplayerKeys();
				str = DropItem1String $ keyDropItem $ DropItem2String;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_KilledTeammate:
				msgColor = colRed;
				TopCentralMessage( gc, YouKilledTeammateString, msgColor );
				break;
			case Player.MPMSG_TeamLAM:
				str = TeamLAMString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_TeamComputer:
				str = TeamComputerString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_NoCloakWeapon:
				str = NoCloakWeaponString;
				TopCentralMessage( gc, str, msgColor );
				break;
			case Player.MPMSG_TeamHackTurret:
				str = TeamHackTurretString;
				TopCentralMessage( gc, str, msgColor );
				break;
		}
		gc.SetTextColor(colWhite);
	}
	if ( Player.Level.Timeseconds < targetPlayerTime )
	{
		gc.SetFont(Font'FontMenuSmall');
		gc.GetTextExtent(0, w, h, targetPlayerName $ targetPlayerHealthString $ targetPlayerLocationString);
		gc.SetTextColor(targetPlayerColor);
		//x = width * targetPlayerXMul - (w*0.5);
		x = 100; // fixed
		if ( x < 1) x = 1;
		y = height * targetPlayerYMul;
		gc.DrawText( x, y, w, h, targetPlayerName $ targetPlayerHealthString $ targetPlayerLocationString);
		if (( targetOutOfRange ) && ( targetRangeTime > Player.Level.Timeseconds ))
		{
			gc.GetTextExtent(0, w, h, OutOfRangeString);
			x = (width * 0.5) - (w*0.5);
			y = (height * 0.5) - (h * 3.0);
			gc.DrawText( x, y, w, h, OutOfRangeString );
		}
		gc.SetTextColor(colWhite);
	}
	weap = DeusExWeapon(Player.inHand);
	if (( weap != None ) && ( weap.AmmoLeftInClip() == 0 ) && (weap.NumClips() == 0) )
	{
		if ( weap.IsA('CBPWeaponLAM') ||
			  weap.IsA('CBPWeaponGasGrenade') || 
			  weap.IsA('CBPWeaponEMP') ||
			  weap.IsA('WeaponShuriken') ||
			  weap.IsA('WeaponLAW') )
		{
		}
		else
		{
			if ( Player.Level.Timeseconds < OutOfAmmoTime )
			{
				gc.SetFont(Font'FontMenuTitle');
				gc.GetTextExtent( 0, w, h, OutOfAmmoString );
				gc.SetTextColor(colRed);
				x = (width*0.5) - (w*0.5);
				y = (height*0.5) - (h*5.0);
				gc.DrawText( x, y, w, h, OutOfAmmoString );
			}
			if ( Player.Level.Timeseconds-OutOfAmmoTime > 0.33 )
				OutOfAmmoTime = Player.Level.Timeseconds + 1.0;
		}
	}
}

function int GetVisionTargetStatus(Actor Target)
{
   local DeusExPlayer PlayerTarget;
   local bool bTeamGame;

   if (Target == None)
      return VISIONNEUTRAL;
   
   if (player.Level.NetMode == NM_Standalone)
      return VISIONNEUTRAL;

   if (target.IsA('DeusExPlayer'))
   {     
      if (target == player)
         return VISIONNEUTRAL;
      
      bTeamGame = player.GameReplicationInfo.bTeamGame;
      // In deathmatch, all players are hostile.
      if (!bTeamGame)
         return VISIONENEMY;
      
      PlayerTarget = DeusExPlayer(Target);
      
      if (class'CBPGame'.static.ArePlayersAllied(PlayerTarget, Player))
         return VISIONALLY;
      else
         return VISIONENEMY;
   }
   else if ( (target.IsA('AutoTurretGun')) || (target.IsA('AutoTurret')) )
   {
      if (target.IsA('AutoTurretGun'))
         return GetVisionTargetStatus(target.Owner);
      else if ((AutoTurret(Target).bDisabled))
         return VISIONNEUTRAL;
      else if (AutoTurret(Target).safetarget == Player) 
         return VISIONALLY;
      else if (Player.GameReplicationInfo.bTeamGame && (AutoTurret(Target).team == -1))
         return VISIONNEUTRAL;
      else if ( (!Player.GameReplicationInfo.bTeamGame) || (Player.PlayerReplicationInfo.Team != AutoTurret(Target).team) )
          return VISIONENEMY;
      else if (Player.PlayerReplicationInfo.Team == AutoTurret(Target).team)
         return VISIONALLY;
      else
         return VISIONNEUTRAL;
   }
   //else if (target.IsA('SecurityCamera'))
   //{
   //   if ( !SecurityCamera(target).bActive )
   //      return VISIONNEUTRAL;
   //   else if ( SecurityCamera(target).team == -1 )
   //      return VISIONNEUTRAL;
   //   else if (((Player.DXGame.IsA('TeamDMGame')) && (SecurityCamera(target).team==player.PlayerReplicationInfo.team)) ||
   //      ( (Player.DXGame.IsA('DeathMatchGame')) && (SecurityCamera(target).team==player.PlayerReplicationInfo.PlayerID)))
   //      return VISIONALLY;
   //   else
   //      return VISIONENEMY;
   //}
   else
      return VISIONNEUTRAL;
}

defaultproperties
{
}
