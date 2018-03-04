class CBPPlayerReplicationInfo extends PlayerReplicationInfo;

var bool bIsDead;

replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		bIsDead;
}

defaultproperties
{
    NetUpdateFrequency=2.00
}
