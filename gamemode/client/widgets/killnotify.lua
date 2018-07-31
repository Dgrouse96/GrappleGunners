-- Create widget object
Widget_KillNotify = Widget( true )

Widget_KillNotify.LastKilled = ""
Widget_KillNotify.Place = ""
Widget_KillNotify.PlaceCol = table.Copy( COL_WHITE )
Widget_KillNotify.KillTime = 0

local PlaceColours = {
	
	Color( 80,100,255 ), -- 1st
	Color( 80,255,80 ), -- 2nd
	Color( 255,80,80 ), -- 3rd
}


Widget_KillNotify.Text = {
	
	t = "",
	x = 960,
	y = 200,
	f = "KillNotify",
	ax = 1,
	ay = 1,
	c = table.Copy( COL_WHITE ),
	
}

Widget_KillNotify.Text2 = {
	
	t = "",
	x = 960,
	y = 230,
	f = "KillNotify",
	ax = 1,
	ay = 1,
	c = table.Copy( COL_WHITE ),
	
}

Widget_KillNotify.PText = {

	t = "",
	x = 960,
	y = 230,
	f = "KillNotify",
	ax = 1,
	ay = 1,
	c = table.Copy( COL_WHITE ),
	
}


function Widget_KillNotify:Think()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	self.PText.c = self.PlaceCol
	
	self.Text.t = "You Killed " .. self.LastKilled
	self.Text2.t = "  place with " .. ply:Frags()
	self.PText.t = self.Place
	
	local Time = CurTime() - self.KillTime
	
	TextAlpha = inverselerpclamp( Time, 4, 0 ) * 1000
	
	self.Text.c.a = TextAlpha
	self.Text2.c.a = TextAlpha
	self.PText.c.a = TextAlpha
	
	if self.Place == "" then self.Text2.c.a = 0 end
	
	surface.SetFont( "KillNotify" )
	local Off1 = surface.GetTextSize( self.Text2.t )
	local Off2 = surface.GetTextSize( self.PText.t )
	
	self.Text2.x = 960 + Off2/2
	self.PText.x = 960 - Off1/2
	
	if TextAlpha <= 0 then
		
		self.Amount = 0
		self:SetHidden( true )
		
	end
	
end


function Widget_KillNotify:Draw()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	--SetCol( self.Text )
	DTextShadow( self.Text, 1 )
	DTextShadow( self.Text2, 1 )
	DTextShadow( self.PText, 1 )
	
end


function Widget_KillNotify:KilledPlayer( ply )
	
	if !IsValid( ply ) then return end
	
	self.LastKilled = ply:Name()
	
	timer.Create( "DamageNotifyPlace", 0.1, 1, function()
	
		if CurrentGameType then
			
			local Key = table.KeyFromValue( CurrentGameType:SortedPlayers(), LocalPlayer() )
			
			if Key then
			
				self.KillTime = CurTime()
				self.Place = string.PlaceSuffix( Key )
				self.PlaceCol = PlaceColours[ Key ] or table.Copy( COL_WHITE )
				self:SetHidden( false )
				
			end
		
		end
	
	end )
		
end

hook.Add( "KilledPlayer", "WidgetKillNotify", function( ply ) Widget_KillNotify:KilledPlayer( ply ) end )