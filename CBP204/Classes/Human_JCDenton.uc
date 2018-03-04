class Human_JCDenton extends PT_Human;

//static function GiveInitialInventory(CBPPlayer owner)
//{
//	local CBPWeapon weap;

//	weap = owner.Spawn(class'CBPWeaponAssaultGun', owner);
//	if (weap != None)
//	{
//		weap.Instigator = owner;
//		weap.BecomeItem();
//		weap.GiveAmmo(owner);
//		owner.AddInventory(weap);
//		weap.BringUp();
//		weap.WeaponSet(owner);
//	}
//}

defaultproperties
{
    DrawScale=0.96
    Mesh=LodMesh'DeusExCharacters.GM_Trench'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.JCDentonTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.JCDentonTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.JCDentonTex3'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.JCDentonTex0'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.JCDentonTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.JCDentonTex2'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex4'
    MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex5'
    CarcassType=Class'Carcass_JCDenton'
}
