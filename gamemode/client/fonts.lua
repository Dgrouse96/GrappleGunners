--
-- Fonts
--

local Fonts = {

	["EnergyWidget"]={
		font = "CPMono_v07 Bold",
		size = sres(50),
		antialias = true,
		shadow = true
	},
	
	["ShotgunAmmo"]={
		font = "CPMono_v07 Bold",
		size = sres(20),
		antialias = true,
		shadow = true
	},
	
	["DamageNotify"]={
		font = "CPMono_v07 Bold",
		size = sres(40),
		antialias = true,
		shadow = false
	},
	
	["KillNotify"]={
		font = "Hemi Head Rg",
		size = sres(30),
		antialias = true,
		shadow = false
	},
	
	["ScoreboardTitle"]={
		font = "Hemi Head Rg",
		size = 60,
		antialias = true,
		shadow = true,
	},
	
	["ScoreboardText1"]={
		font = "Hemi Head Rg",
		size = 36,
		antialias = true,
		shadow = true,
	},
	
	["ScoreboardText2"]={
		font = "Hemi Head Rg",
		size = 20,
		antialias = true,
		shadow = true,
	},
	
	["ScoreboardLeader"]={
		font = "Hemi Head Rg",
		size = 27,
		antialias = true,
		shadow = true,
	},
	
	["Scoreboard2nd"]={
		font = "Hemi Head Rg",
		size = 25,
		antialias = true,
		shadow = true,
	},
	
	["Scoreboard3rd"]={
		font = "Hemi Head Rg",
		size = 23,
		antialias = true,
		shadow = true,
	},
	
	["StatsHeader"]={
		font = "Hemi Head Rg",
		size = 40,
		antialias = true,
		shadow = true,
	},
	
	["StatsSubHeader"]={
		font = "Hemi Head Rg",
		size = 30,
		antialias = true,
		shadow = true,
	},
	
	["StatsSubHeader2"]={
		font = "Hemi Head Rg",
		size = 20,
		antialias = true,
		shadow = true,
	},
	
	["StatsCategory"]={
		font = "Hemi Head Rg",
		size = 24,
		antialias = true,
		shadow = true,
	},
	
	["StatsStat"]={
		font = "Hemi Head Rg",
		size = 18,
		antialias = true,
		shadow = true,
	},
	
	["Achievment"]={
		font = "Hemi Head Rg",
		size = 25,
		antialias = true,
		shadow = true,
	},
	
	["AchievmentDesc"]={
		font = "Hemi Head Rg",
		size = 13,
		antialias = true,
		shadow = true,
	},
	
	["AchievmentProgress"]={
		font = "Hemi Head Rg",
		size = 18,
		antialias = true,
		shadow = true,
	},
	
	["MapVoteHeader"]={
		font = "Hemi Head Rg",
		size = 70,
		antialias = true,
		shadow = false,
	},
	
	["MapVoteName"]={
		font = "Hemi Head Rg",
		size = 40,
		antialias = true,
		shadow = false,
	},
	
	["MapVoteGame"]={
		font = "Hemi Head Rg",
		size = 32,
		antialias = true,
		shadow = false,
	},
	
	["MapVoteDesc"]={
		font = "Hemi Head Rg",
		size = 20,
		antialias = true,
		shadow = true,
	},
	
}

function RefreshFont( font )

	if Fonts[ font ] then
	
		surface.CreateFont( font, Fonts[font] )
		
	else
	
		print( "Invalid font!" )
		
	end
	
end

function RefreshAllFonts()

	for k,v in pairs( Fonts ) do
		
		surface.CreateFont( k,v )
		
	end
	
end

hook.Add( "Initialize", "RefreshFonts", RefreshAllFonts )
hook.Add( "OnReloaded", "RefreshFonts", RefreshAllFonts )
hook.Add( "UpdateScreenRes", "RefreshFonts", RefreshAllFonts )
