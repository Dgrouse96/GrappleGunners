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
