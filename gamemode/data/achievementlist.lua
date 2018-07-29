--
-- Kill achievements
--

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

	local TotalKills = S_Kills:GetTotal( ply )

	ACH_ColdKiller:Set( ply, "Amount", TotalKills )
	ACH_SerialKiller:Set( ply, "Amount", TotalKills )
	ACH_MassMurder:Set( ply, "Amount", TotalKills )

end )

--
-- Win Achievements
--

ACH_Winner = Achievement( "Winner", "winner" )
ACH_Winner.Description = "Win a game"
ACH_Winner.WinAt = 1

ACH_Warrior = Achievement( "Warrior", "warrior" )
ACH_Warrior.Description = "Win a total of 10 games"
ACH_Warrior.WinAt = 10

ACH_Champion = Achievement( "Champion", "champion" )
ACH_Champion.Description = "Win a total of 100 games"
ACH_Champion.WinAt = 100

S_Wins:BindOnUpdate( "WinAchievements", function( ply )

	local TotalWins = S_Wins:GetTotal( ply )

	ACH_Winner:Set( ply, "Amount", TotalWins )
	ACH_Warrior:Set( ply, "Amount", TotalWins )
	ACH_Champion:Set( ply, "Amount", TotalWins )

end )


--
-- When they enable aimbot
--

ACH_Hacker = Achievement( "Hacker", "hacker" )
ACH_Hacker.Description = "Enable the secret hacks"

function ACH_Hacker:WinCheck( ply )
	
	return ply.IsHacking
	
end

if SERVER then

	AddRequest( "ImAHacker", function( ply )

		ply.IsHacking = true
		ACH_Hacker:Update( ply )

	end )

end
