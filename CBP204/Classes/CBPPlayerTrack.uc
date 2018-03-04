class CBPPlayerTrack extends Actor;

var CBPPlayer MyPlayer;
var CBPPlayer AttachedPlayer;
var float TimeSinceCloak;

function Tick (float VAE)
{
	MyPlayer = CBPPlayer(GetPlayerPawn());
	if ((AttachedPlayer == None) || (MyPlayer == None) || (AttachedPlayer == MyPlayer))
	{
		Destroy();
	}
	else
	{
		//HandleNintendoEffect();
		HandlePlayerCloak(AttachedPlayer, VAE);
	}
}

//function HandleNintendoEffect()
//{
//	if (AttachedPlayer.NintendoImmunityTimeLeft > 0.00)
//	{
//		AttachedPlayer.DrawInvulnShield();
//		if (AttachedPlayer.invulnSph != None)
//		{
//			AttachedPlayer.invulnSph.LifeSpan = AttachedPlayer.NintendoImmunityTimeLeft;
//		}
//	}
//	else
//	{
//		if (AttachedPlayer.invulnSph != None)
//		{
//			AttachedPlayer.invulnSph.Destroy();
//			AttachedPlayer.invulnSph = None;
//		}
//	}
//}

function HandlePlayerCloak(DeusExPlayer OtherPlayer, float DeltaTime)
{
   local DeusExPlayer MyPlayer;
   local bool bAllied;

   MyPlayer = DeusExPlayer(GetPlayerPawn());

   TimeSinceCloak += DeltaTime;

   if (OtherPlayer == None)
      return;

   if (MyPlayer == None)
      return;

   if (OtherPlayer.Style != STY_Translucent)
   {
      TimeSinceCloak = 0;
      //OtherPlayer.CreateShadow();
      //if (OtherPlayer.IsA('JCDentonMale'))
      //{
      //   OtherPlayer.MultiSkins[6] = OtherPlayer.Default.MultiSkins[6];
      //   OtherPlayer.MultiSkins[7] = OtherPlayer.Default.MultiSkins[7];
      //}
      return;
   }

   if (OtherPlayer == MyPlayer)
      return;

   //if (OtherPlayer.IsA('JCDentonMale'))
   //{
   //   OtherPlayer.MultiSkins[6] = Texture'BlackMaskTex';
   //   OtherPlayer.MultiSkins[7] = Texture'BlackMaskTex';
   //}

   bAllied = False;

   if (MyPlayer.GameReplicationInfo.bTeamGame && class'CBPGame'.static.ArePlayersAllied(OtherPlayer,MyPlayer))
      bAllied = True;

   //OtherPlayer.KillShadow();

   if (!bAllied)
   {
      //DEUS_EX AMSD Do a gradual cloak fade.
      OtherPlayer.ScaleGlow = OtherPlayer.Default.ScaleGlow * (0.01 / TimeSinceCloak);
      if (OtherPlayer.ScaleGlow <= 0.02)
         OtherPlayer.ScaleGlow = 0;
   }
   else
      OtherPlayer.ScaleGlow = 0.25;

   return;
}

defaultproperties
{
    TimeSinceCloak=10.00
    bHidden=True
    Style=STY_None
    bUnlit=True
    CollisionRadius=0.00
    CollisionHeight=0.00
}
