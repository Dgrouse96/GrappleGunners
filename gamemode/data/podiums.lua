--
-- Shitty interface for creating podiums
--

-- Map specific data (only save if server)
local Podiums = GData( "podiums/" .. game.GetMap(), SERVER )

concommand.Add( "podium_spawn", function( ply, cmd, args )
	
	local Index = tonumber( args[1] )
	if !Index then Index = Podiums:Length() + 1 end
	
	if !Podiums:GetData()[ Index ] then Podiums:GetData()[ Index ] = {} end
	
	if CLIENT then return end
	
	local Data = Podiums:GetData()[ Index ]
	local Pos = ply:GetEyeTrace().HitPos
	local Ang = Angle()
	
	if Data.Podium then
		
		Pos,Ang = unpack( Data.Podium )
		
	end
	
	local Podium = ents.Create( "podium" )
	Podium:SetPos( Pos )
	Podium:SetAngles( Ang )
	Podium:Spawn()
	
	if !ply:HasWeapon( "weapon_physgun" ) then
		
		ply:Give( "weapon_physgun" )
		
	end
	
end )



concommand.Add( "podium_set", function( ply, cmd, args )
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	local Ent = ply:GetEyeTrace().Entity
	
	if IsValid( Ent ) and Ent:GetClass() == "podium" then
		
		Podiums:GetData()[ Index ].Podium = { Ent:GetPos(), Ent:GetAngles() }
		Podiums:Save()
		
	else
	
		print( "No podium found" )
		
	end
	
end )



concommand.Add( "podium_cam", function( ply, cmd, args )
	
	if !Podiums:GetData()[ Index ] then print( "Create a podium first" ) return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	if !Podiums:GetData()[ Index ].Cams then Podiums:GetData()[ Index ].Cams = {} end
	
	local CamIndex = tonumber( args[2] ) or #Podiums:GetData()[ Index ].Cams + 1
	
	Podiums:GetData()[ Index ].Cams[ CamIndex ] = { ply:EyePos(), ply:EyeAngles() }
	
end )


concommand.Add( "podium_camremove", function( ply, cmd, args )
	
	if !Podiums:GetData()[ Index ] then print( "Create a podium first" ) return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	local CamIndex = tonumber( args[2] ) or #Podiums:GetData()[ Index ].Cams
	
	if Podiums:GetData()[ Index ].Cams then
		
		if Podiums:GetData()[ Index ].Cams[ CamIndex ] then
			
			table.remove( Podiums:GetData()[ Index ].Cams, CamIndex )
			print( "Removed cam: " .. CamIndex )
			return
			
		end
		
	end
	
	print( "No cameras found" )
	
end )


if CLIENT then return end

function RemoveAllPodiums()
	
	for k,v in pairs( ents.FindByClass( "podium" ) ) do
		
		v:Remove()
		
	end
	
end

RemoveAllPodiums()