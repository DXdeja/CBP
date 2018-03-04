class CBPCrosshair extends Crosshair;

function NewSetCrosshair( bool bShow )
{
	if (bShow) SetBackground(Texture'CrossSquare');
	else SetBackground(none);
}

defaultproperties
{
}
