class CBPGameReplicationInfo extends GameReplicationInfo;

var byte ForceTeam; // part of teambalancer, if this is 0 or 1, we can only choose that team

replication
{
	reliable if (Role == ROLE_Authority)
		ForceTeam;
}

defaultproperties
{
    forceteam=255
    NetPriority=1.10
}
