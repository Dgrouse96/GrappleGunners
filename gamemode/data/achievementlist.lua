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
-- Damage Combo
--

ACH_Havoc = Achievement( "Havoc", "havoc" )
ACH_Havoc.Description = "Deal an 800 damage combo"
ACH_Havoc.WinAt = 800

ACH_Anarchy = Achievement( "Anarchy", "anarchy" )
ACH_Anarchy.Description = "Deal a 1500 damage combo"
ACH_Anarchy.WinAt = 1500

ACH_Mayhem = Achievement( "Mayhem", "mayhem" )
ACH_Mayhem.Description = "Deal a 3000 damage combo"
ACH_Mayhem.WinAt = 3000

S_DamageCombo:BindOnUpdate( "DamageAchievements", function( ply )

	local Amount = S_DamageCombo:GetData( ply, "Amount" )

	ACH_Havoc:Set( ply, "Amount", Amount )
	ACH_Anarchy:Set( ply, "Amount", Amount )
	ACH_Mayhem:Set( ply, "Amount", Amount )

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
