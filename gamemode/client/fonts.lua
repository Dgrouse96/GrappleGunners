local Fonts = {
	["ComboFont"]={
		font = "Bebas Neue Regular",
		size = sres(50),
		antialias = true,
		shadow = true
	},
	["LOSNames"]={
		font = "Bebas Neue Regular",
		size = sres(40),
		antialias = true,
		shadow = true
	},
	["Hitmarkers"]={
		font = "Bebas Neue Regular",
		size = sres(40),
		antialias = true,
		shadow = true
	},
	["SB:Title"]={
		font = "Bebas Neue Book",
		size = sres(70),
		antialias = true,
		shadow = true
	},
	["SB:Name"]={
		font = "Bebas Neue Regular",
		size = sres(30),
		antialias = true,
		shadow = true
	},
	["SB:MiniGameName"]={
		font = "Bebas Neue Regular",
		size = sres(26),
		antialias = true,
		shadow = true
	},
	["SB:Detail"]={
		font = "Bebas Neue Regular",
		size = sres(18),
		antialias = true,
		shadow = true
	},
	["SB:Rank"]={
		font = "Bebas Neue Regular",
		size = sres(18),
		antialias = true,
		shadow = true
	},
	["NotifyTitle"]={
		font = "Bebas Neue Regular",
		size = sres(85),
		antialias = true,
		shadow = true
	},
	["NotifyDetail"]={
		font = "Bebas Neue Regular",
		size = sres(30),
		antialias = true,
		shadow = true
	},
	["TrickFont"]={
		font = "Bebas Neue Regular",
		size = sres(30),
		antialias = true,
	},
	["ScoreFont"]={
		font = "Bebas Neue Regular",
		size = sres(45),
		antialias = true,
	},
	["FinalScore"]={
		font = "Bebas Neue Bold",
		size = sres(50),
		antialias = true,
	},
	["PointMeter"]={
		font = "Bebas Neue Bold",
		size = sres(30),
		antialias = true,
	},
	["ObjectiveDistance"]={
		font = "Bebas Neue Bold",
		size = sres(12),
		antialias = true,
	},
	
	["DGPresents"]={
		font = "Bebas Neue Regular",
		size = sres(100),
		antialias = true,
	},
	["TitleText"]={
		font = "Bebas Neue Regular",
		size = sres(300),
		antialias = true,
	},
}

function RefreshFont( font )
	if Fonts[font] then
		surface.CreateFont( font,Fonts[font] )
	else
		print( "Invalid font!" )
	end
end

function RefreshAllFonts()
	for k,v in pairs(Fonts) do
		surface.CreateFont( k,v )
	end
end
hook.Add("Initialize","RefreshFonts",RefreshAllFonts)
hook.Add("OnReloaded","RefreshFonts",RefreshAllFonts)
hook.Add("UpdateScreenRes","RefreshFonts",RefreshAllFonts)
