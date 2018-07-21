ACH_ColdKiller = Achievement( "Cold Killer", "coldkiller" )
ACH_ColdKiller.Description = "Kill 100 people"
ACH_ColdKiller.WinAt = 100

ACH_SerialKiller = Achievement( "Serial Killer", "serialkiller" )
ACH_SerialKiller.Description = "Kill 1000 people"
ACH_SerialKiller.WinAt = 1000

ACH_MassMurder = Achievement( "Mass Murderer", "massmurder" )
ACH_MassMurder.Description = "Kill 10000 people"
ACH_MassMurder.WinAt = 10000

function AddKillAchievemnts( ply )
	
	ACH_ColdKiller:Increment( ply, "Amount", 1 )
	ACH_SerialKiller:Increment( ply, "Amount", 1 )
	ACH_MassMurder:Increment( ply, "Amount", 1 )
	
end