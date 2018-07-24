ACH_ColdKiller = Achievement( "Cold Killer", "coldkiller" )
ACH_ColdKiller.Description = "Kill a total of 100 people"
ACH_ColdKiller.WinAt = 100

ACH_SerialKiller = Achievement( "Serial Killer", "serialkiller" )
ACH_SerialKiller.Description = "Kill a total of 1000 people"
ACH_SerialKiller.WinAt = 1000

ACH_MassMurder = Achievement( "Mass Murderer", "massmurder" )
ACH_MassMurder.Description = "Kill a total of 10000 people"
ACH_MassMurder.WinAt = 10000

S_Kills:BindOnUpdate( "KillAchievements", function( ply )

	local TotalKills = S_Kills:GetTotalKills( ply )

	ACH_ColdKiller:Set( ply, "Amount", TotalKills )
	ACH_SerialKiller:Set( ply, "Amount", TotalKills )
	ACH_MassMurder:Set( ply, "Amount", TotalKills )

end )
