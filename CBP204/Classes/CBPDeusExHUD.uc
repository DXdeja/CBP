class CBPDeusExHUD extends DeusExHUD;

var class<HUDBaseWindow> HitDisplayClass;
var class<Crosshair> CrosshairClass;
var class<CBPAugmentationDisplayWindow> AugDisplayClass;
var CBPPlayer player;

event InitWindow()
{
	local DeusExRootWindow root;

	Super(Window).InitWindow();

	bTickEnabled = true;

	// Get a pointer to the root window
	root = DeusExRootWindow(GetRootWindow());

	// Get a pointer to the player
	player = CBPPlayer(root.parentPawn);

	SetFont(Font'TechMedium');
	SetSensitivity(false);

	//ammo			= HUDAmmoDisplay(NewChild(Class'HUDAmmoDisplay'));
	hit				= HUDHitDisplay(NewChild(HitDisplayClass));
	cross			= Crosshair(NewChild(CrosshairClass));
	//belt			= HUDObjectBelt(NewChild(Class'HUDObjectBelt'));
	activeItems		= HUDActiveItemsDisplay(NewChild(Class'CBPHUDActiveItemsDisplay'));
	damageDisplay	= DamageHUDDisplay(NewChild(Class'DamageHUDDisplay'));
	//compass     	= HUDCompassDisplay(NewChild(Class'HUDCompassDisplay'));
	//hms				= HUDMultiSkills(NewChild(Class'HUDMultiSkills'));

	// Create the InformationWindow
	info = HUDInformationDisplay(NewChild(Class'HUDInformationDisplay', False));

	// Create the log window
	msgLog	= HUDLogDisplay(NewChild(Class'HUDLogDisplay', False));
	msgLog.SetLogTimeout(player.GetLogTimeout());

	frobDisplay = FrobDisplayWindow(NewChild(Class'FrobDisplayWindow'));
	frobDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	augDisplay = AugmentationDisplayWindow(NewChild(AugDisplayClass));
	augDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	//startDisplay = HUDMissionStartTextDisplay(NewChild(Class'HUDMissionStartTextDisplay', False));
//	startDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	// Bark display
	//barkDisplay = HUDBarkDisplay(NewChild(Class'HUDBarkDisplay', False));

	// Received Items Display
	receivedItems = HUDReceivedDisplay(NewChild(Class'HUDReceivedDisplay', False));
}

function UpdateSettings( DeusExPlayer player )
{
	if (belt != none) belt.SetVisibility(player.bObjectBeltVisible);
	if (hit != none) hit.SetVisibility(player.bHitDisplayVisible);
	if (ammo != none) ammo.SetVisibility(player.bAmmoDisplayVisible);
	if (activeItems != none) activeItems.SetVisibility(player.bAugDisplayVisible);
	if (damageDisplay != none) damageDisplay.SetVisibility(player.bHitDisplayVisible);
	if (compass != none) compass.SetVisibility(player.bCompassVisible);
	if (cross != none) cross.SetCrosshair(player.bCrosshairVisible);
}

event Tick(float deltaSeconds)
{
	if (CBPCrosshair(cross) != none)
	{
		if (player.bShowScores) CBPCrosshair(cross).NewSetCrosshair(false);
		else CBPCrosshair(cross).NewSetCrosshair(player.bCrosshairVisible);
	}
}

defaultproperties
{
    HitDisplayClass=Class'DeusEx.HUDHitDisplay'
    CrosshairClass=Class'CBPCrosshair'
    AugDisplayClass=Class'CBPAugmentationDisplayWindow'
}
