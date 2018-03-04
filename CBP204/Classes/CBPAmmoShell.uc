class CBPAmmoShell extends CBPAmmo;

defaultproperties
{
    ShellCasingClass=Class'CBPShellCasing2'
    bShowInfo=True
    AmmoAmount=12
    MaxAmmo=96
    ItemName="12 Gauge Buckshot Shells"
    ItemArticle="some"
    PickupViewMesh=LodMesh'DeusExItems.AmmoShell'
    Icon=Texture'DeusExUI.Icons.BeltIconAmmoShells'
    largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoShells'
    largeIconWidth=34
    largeIconHeight=45
    Description="Standard 12 gauge shotgun shell; very effective for close-quarters combat against soft targets, but useless against body armor."
    beltDescription="BUCKSHOT"
    Mesh=LodMesh'DeusExItems.AmmoShell'
    CollisionRadius=9.30
    CollisionHeight=10.21
    bCollideActors=True
}
