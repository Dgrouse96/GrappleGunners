-- Create widget object
Widget_DamageIndicator = Widget()

local Indicator = Material( "grapplegunners/hud/damageindicator.png" )

Widget_DamageIndicator.Indicators = {}


function Widget_DamageIndicator:Think()
	
	local ply = LocalPlayer()
	if !IsValid( ply ) then return end
	if !ply:Alive() then return end
	
	for k,v in pairs( self.Indicators ) do
		
		local Ang = DirectionVector( ply:EyePos(), v.Location ):Angle().y - ply:EyeAngles().y + 180
		local Radians = Ang * 0.0174533
		
		v.Data.x = 960 + math.sin( Radians ) * 256
		v.Data.y = 540 + math.cos( Radians ) * 256
		v.Data.r = Ang+180
		
		local TimeAlpha = inverselerpclamp( CurTime() - v.Start, 2, 0 )
		v.Data.c.a = TimeAlpha*255
		
		if TimeAlpha <= 0 then
			
			table.remove( self.Indicators, k )
			
		end
		
	end
	
end


function Widget_DamageIndicator:Draw()
	
	local ply = LocalPlayer()
	if !IsValid( ply ) then return end
	if !ply:Alive() then return end
	
	SetMat( Indicator )
	
	for k,v in pairs( self.Indicators ) do
		
		SetCol( v.Data.c )
		DTRectSimpleR( v.Data )
	
	end
	
end


hook.Add( "TookDamage", "DamageIndicator", function( ply, Amount )
	
	if Amount <= 0 then return end
	
	for k,v in pairs( Widget_DamageIndicator.Indicators ) do
		
		if CurTime() < v.Start + 0.2 then
		
			if ply:GetPos():Distance( v.Location ) < 10 then return end
			
		end
		
	end
	
	table.insert( Widget_DamageIndicator.Indicators, {
		
		Start = CurTime(),
		Location = ply:GetPos(),
		Data = {
			
			x = 0,
			y = 0,
			w = 256,
			h = 64,
			r = 0,
			c = Color(255,255,255,255),
			
		},
		
	} )
	
end )