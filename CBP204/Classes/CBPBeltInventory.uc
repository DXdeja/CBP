// base class for inventory setup
// warning: this does not replace standard inventory linked list !
// it only manages displaying inventory on clients and selecting items from belt
class CBPBeltInventory extends Info;

var const int MaxItems;
var Inventory InventoryItems[10];
var class<Inventory> InventoryBaseClassLimitation[10];
var byte ItemsSplitted[10];

var Texture SolidTex;
var Color BackgroundColor;
var Color BackgrounSelectedColor;
var Color LineColor;
var Color LineSelectedColor;
var Color ItemColor;
var Font InvFont;

var Color colAmmoText;
var Color colAmmoLowText;
var Color colNormalText;

var localized String NotAvailable;
var localized String msgReloading;
var localized String AmmoLabel;
var localized String ClipsLabel;

var int ItemWidth;
var int ItemHeight;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		InventoryItems;

	reliable if (Role == ROLE_Authority)
		ClientSetInhandPending;
}

function bool AddInventory(Inventory Inv)
{
	local int i;

	// find spot
	for (i = 0; i < MaxItems; i++)
	{
		if (ClassIsChildOf(Inv.class, InventoryBaseClassLimitation[i]))
		{
			if (InventoryItems[i] == none)
			{
				// only add if not populated yet
				InventoryItems[i] = Inv;
				//Log("Inventory " $ Inv $ " added at slot: " $ i);
				return true;
			}
		}
	}

	return false;
}

function bool CanPlaceInventory(Inventory inv)
{
	local int i;

	for (i = 0; i < MaxItems; i++)
	{
		if (ClassIsChildOf(Inv.class, InventoryBaseClassLimitation[i]))
		{
			if (InventoryItems[i] == none) return true;
		}
	}

	return false;
}

function RemoveInventory(Inventory Inv)
{
	local int i;

	for (i = 0; i < MaxItems; i++)
	{
		if (InventoryItems[i] == Inv)
		{
			//Log("Inventory " $ Inv $ " removed from slot: " $ i);
			InventoryItems[i] = none;
			return;
		}
	}
}

function SelectInventory(byte num)
{
	if (num == 0) num = 10;
	num--;
	if (num >= MaxItems) return;

	ClientSetInhandPending(InventoryItems[num]);
	CBPPlayer(Owner).PutInHand(InventoryItems[num]);
}

simulated function ClientSetInhandPending(Inventory Inv)
{
	CBPPlayer(Owner).clientInHandPending = Inv;
}

simulated function int GetIndexForInventory(Inventory Inv)
{
	local int i;

	for (i = 0; i < MaxItems; i++)
	{
		if (InventoryItems[i] == Inv) return i;
	}

	return -1;
}

simulated function NextItem()
{
	local CBPPlayer player;
	local int slot, startSlot;

	player = CBPPlayer(Owner);
	slot = -1;

	if (player.ClientInHandPending != none)
		slot = GetIndexForInventory(player.ClientInHandPending);
	else if (player.inHandPending != none)
		slot = GetIndexForInventory(player.inHandPending);
	else if (player.inHand != none)
		slot = GetIndexForInventory(player.inHand);

	if (slot == -1) startSlot = 9;
	else startSlot = slot;

	do
	{
		if (++slot >= 10)
			slot = 0;
	}
	until (InventoryItems[slot] != none || (startSlot == slot));

	player.clientInHandPending = InventoryItems[slot];
	player.PutInHand(InventoryItems[slot]);
}

simulated function PrevItem()
{
	local CBPPlayer player;
	local int slot, startSlot;

	player = CBPPlayer(Owner);
	slot = -1;

	if (player.ClientInHandPending != none)
		slot = GetIndexForInventory(player.ClientInHandPending);
	else if (player.inHandPending != none)
		slot = GetIndexForInventory(player.inHandPending);
	else if (player.inHand != none)
		slot = GetIndexForInventory(player.inHand);

	if (slot == -1)
	{
		slot = 10;
		startSlot = 0;
	}
	else startSlot = slot;
	do
	{
		if (--slot <= -1)
			slot = 9;
	}
	until (InventoryItems[slot] != none || (startSlot == slot));

	player.clientInHandPending = InventoryItems[slot];
	player.PutInHand(InventoryItems[slot]);
}

// called when player dies or goes to spec mode
function Reset()
{
	local int i;

	//log("resetting inventory");

	for (i = 0; i < MaxItems; i++)
		InventoryItems[i] = none;
}

simulated function int GetSelectedIndex()
{
	local int i;

	if (CBPPlayer(Owner).inHand == none) return -1;

	for (i = 0; i < MaxItems; i++)
		if (CBPPlayer(Owner).inHand == InventoryItems[i]) return i;

	return -1;
}

simulated function int GetPendingSelectedIndex()
{
	local int i;

	if (CBPPlayer(Owner).ClientinHandPending == none) return -1;

	for (i = 0; i < MaxItems; i++)
		if (CBPPlayer(Owner).ClientinHandPending == InventoryItems[i]) return i;

	return -1;
}

simulated function int CalculateInventoryWidth()
{
	local int i;
	local int c;

	for (i = 0; i < MaxItems; i++)
		if (ItemsSplitted[i] == 1) c++;

	return (c * 2 + (ItemWidth * MaxItems) + (MaxItems - 1));
}

simulated function DrawOutlinedRect(Canvas canvas, int x, int y, int w, int h, Color fillcol, Color outlinecol)
{
	canvas.SetPos(x, y);
	canvas.DrawColor = fillcol;
	canvas.DrawRect(SolidTex, w, h);
	canvas.DrawColor = outlinecol;
	canvas.SetPos(x, y);
	canvas.DrawRect(SolidTex, 1, h);
	canvas.SetPos(X, Y);
	canvas.DrawRect(SolidTex, w, 1);
	canvas.SetPos(X + w - 1, Y);
	canvas.DrawRect(SolidTex, 1, h);
	canvas.SetPos(X, Y + h - 1);
	canvas.DrawRect(SolidTex, w, 1);
}

simulated function Draw(Canvas canvas)
{
	local int X, Y, i, count;
	local int selected_index, pending_index;
	local DeusExPickup dxp;
	local CBPGrenade gren;
	local string str, str2;
	local float tx, ty;
	local DeusExWeapon dxw;
	local int ammoRemaining;
	local int ammoInClip;
	local int clipsRemaining;

	X = canvas.SizeX - 16 - CalculateInventoryWidth();
	Y = canvas.SizeY - 16 - ItemHeight;

	selected_index = GetSelectedIndex();
	pending_index = GetPendingSelectedIndex();

	canvas.Font = InvFont;

	for (i = 0; i < MaxItems; i++)
	{
		canvas.SetPos(X, Y);

		// draw background
		if (i == selected_index) canvas.DrawColor = BackgrounSelectedColor;
		else canvas.DrawColor = BackgroundColor;
		canvas.DrawRect(SolidTex, ItemWidth, ItemHeight);

		// draw lines
		if ((pending_index == -1 && i == selected_index)
			|| pending_index == i)
			canvas.DrawColor = LineSelectedColor;
		else canvas.DrawColor = LineColor;
		canvas.SetPos(X, Y);
		canvas.DrawRect(SolidTex, 1, ItemHeight);
		canvas.SetPos(X, Y);
		canvas.DrawRect(SolidTex, ItemWidth, 1);
		canvas.SetPos(X + ItemWidth - 1, Y);
		canvas.DrawRect(SolidTex, 1, ItemHeight);
		canvas.SetPos(X, Y + ItemHeight - 1);
		canvas.DrawRect(SolidTex, ItemWidth, 1);

		// draw icon
		if (InventoryItems[i] != none)
		{
			canvas.SetPos(X + 1, Y + 1);
			canvas.DrawColor = ItemColor;
			canvas.DrawTile(InventoryItems[i].Icon, ItemWidth - 2, ItemHeight - 2, 0, 0, ItemWidth - 2, ItemHeight - 2);

			count = 1;
			// draw count
			dxp = DeusExPickup(InventoryItems[i]);
			if (dxp != none && dxp.bCanHaveMultipleCopies && dxp.NumCopies > 1)
				count = dxp.NumCopies;

			gren = CBPGrenade(InventoryItems[i]);
			if (gren != none && gren.AmmoType.AmmoAmount > 1)
				count = gren.AmmoType.AmmoAmount;

			if (count > 1)
			{
				canvas.DrawColor = ItemColor;
				str = "Count:" @ string(count);
				canvas.TextSize(str, tx, ty);
				canvas.SetPos(X + ((ItemWidth - tx) / 2), Y + ItemHeight - ty - 4);
				canvas.DrawText(str);
			}
		}

		// draw number
		canvas.DrawColor = ItemColor;
		canvas.SetPos(X + ItemWidth - 7, Y + 1);
		canvas.DrawText(string(int((i + 1) % 10)));

		X += ItemWidth + 1;

		if (ItemsSplitted[i] == 1)
		{
			canvas.DrawColor = LineColor;
			canvas.SetPos(X, Y);
			Canvas.DrawRect(SolidTex, 1, ItemHeight);
			X += 2;
		}
	}

	// draw ammo info
	dxw = DeusExWeapon(CBPPlayer(Owner).inHand);
	if (dxw != none)
	{
		X = 16;
		Y = canvas.SizeY - 16 - 41;

		// draw background
		DrawOutlinedRect(canvas, X, Y, 80, 41, BackgroundColor, LineColor);

		X += 2;
		Y += 2;

		// draw icon background
		DrawOutlinedRect(canvas, X, Y, 42, 37, BackgrounSelectedColor, LineSelectedColor);

		// draw icon
		canvas.SetPos(X + 1, Y + 1);
		canvas.DrawColor = ItemColor;
		canvas.DrawTile(dxw.Icon, 40, 35, 0, 0, 40, 35);

		// draw texts
		Y -= 2;
		X += 46;

		canvas.SetPos(X + 2, Y);
		canvas.DrawText(AmmoLabel);
		Y += 10;
		DrawOutlinedRect(canvas, X, Y, 30, 10, BackgrounSelectedColor, LineSelectedColor);
		Y += 11;
		DrawOutlinedRect(canvas, X, Y, 30, 10, BackgrounSelectedColor, LineSelectedColor);
		Y += 10;
		canvas.SetPos(X + 2, Y);
		canvas.DrawColor = ItemColor;
		canvas.DrawText(ClipsLabel);

		X += 4;
		Y -= 21;

		// draw text
		if (dxw.AmmoType != None)
			ammoRemaining = dxw.AmmoType.AmmoAmount;
		else
			ammoRemaining = 0;

		if ( ammoRemaining < dxw.LowAmmoWaterMark )
			canvas.DrawColor = colAmmoLowText;
		else
			canvas.DrawColor = colAmmoText;

		// Ammo count drawn differently depending on user's setting
		if (dxw.ReloadCount > 1 )
		{
			// how much ammo is left in the current clip?
			ammoInClip = dxw.AmmoLeftInClip();
			clipsRemaining = dxw.NumClips();

			canvas.SetPos(X, Y);
			if (dxw.IsInState('Reload'))
			{
				canvas.DrawText(msgReloading);
			}
				//gc.DrawText(infoX, 26, 20, 9, msgReloading);
			else
			{
				canvas.DrawText(ammoInClip);
			}
				//gc.DrawText(infoX, 26, 20, 9, ammoInClip);

			// if there are no clips (or a partial clip) remaining, color me red
			if (( clipsRemaining == 0 ) || (( clipsRemaining == 1 ) && ( ammoRemaining < 2 * dxw.ReloadCount )))
				canvas.DrawColor = colAmmoLowText;
			else
				canvas.DrawColor = colAmmoText;

			canvas.SetPos(X, Y + 11);
			if (dxw.IsInState('Reload'))
				canvas.DrawText(msgReloading);
				//gc.DrawText(infoX, 38, 20, 9, msgReloading);
			else
				canvas.DrawText(clipsRemaining);
				//gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
		}
		else
		{
			canvas.SetPos(X, Y + 11);
			canvas.DrawText(NotAvailable);
			//gc.DrawText(infoX, 38, 20, 9, NotAvailable);

			if (dxw.ReloadCount == 0)
			{
				canvas.SetPos(X, Y);
				canvas.DrawText(NotAvailable);
				//gc.DrawText(infoX, 26, 20, 9, NotAvailable);
			}
			else
			{
				canvas.SetPos(X, Y);
				if (dxw.IsInState('Reload'))
					canvas.DrawText(msgReloading);
					//gc.DrawText(infoX, 26, 20, 9, msgReloading);
				else
					canvas.DrawText(ammoRemaining);
					//gc.DrawText(infoX, 26, 20, 9, ammoRemaining);
			}
		}

	}
}

defaultproperties
{
    MaxItems=10
    InventoryBaseClassLimitation(0)=Class'CBPWeapon'
    InventoryBaseClassLimitation(1)=Class'CBPWeapon'
    InventoryBaseClassLimitation(2)=Class'CBPWeapon'
    InventoryBaseClassLimitation(3)=Class'CBPGrenade'
    InventoryBaseClassLimitation(4)=Class'CBPGrenade'
    InventoryBaseClassLimitation(5)=Class'CBPGrenade'
    InventoryBaseClassLimitation(6)=Class'DeusEx.Lockpick'
    InventoryBaseClassLimitation(7)=Class'DeusEx.Multitool'
    InventoryBaseClassLimitation(8)=Class'CBPMedkit'
    InventoryBaseClassLimitation(9)=Class'CBPBioelectricCell'
    ItemsSplitted(2)=1
    ItemsSplitted(5)=1
    SolidTex=Texture'Extension.Solid'
    BackgroundColor=(R=40,G=40,B=40,A=0),
    BackgrounSelectedColor=(R=127,G=127,B=127,A=0),
    LineColor=(R=80,G=80,B=80,A=0),
    LineSelectedColor=(R=200,G=200,B=200,A=0),
    ItemColor=(R=255,G=255,B=255,A=0),
    InvFont=Font'DeusExUI.FontTiny'
    colAmmoText=(R=0,G=255,B=0,A=0),
    colAmmoLowText=(R=255,G=0,B=0,A=0),
    colNormalText=(R=0,G=255,B=0,A=0),
    NotAvailable="N/A"
    msgReloading="---"
    AmmoLabel="AMMO"
    ClipsLabel="CLIPS"
    ItemWidth=44
    ItemHeight=44
    RemoteRole=ROLE_SimulatedProxy
    bOnlyOwnerSee=True
    NetPriority=2.00
}
