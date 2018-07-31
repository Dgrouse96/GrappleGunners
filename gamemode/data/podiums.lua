--
-- Shitty interface for creating podiums
--

-- Map specific data (only save if server)
local Podiums = GData( "podiums/" .. game.GetMap(), SERVER )
Podiums.Reg = {} -- Non saved podium ent lookup


function SpawnPodium( Index, Pos )
	
	if !Index then Index = math.random( 1, #Podiums:GetData() ) end
	if !Podiums:GetData()[ Index ] then Podiums:GetData()[ Index ] = {} end
	
	local Data = Podiums:GetData()[ Index ]
	local Ang = Angle()
	
	if Data.Podium then
		
		Pos,Ang = unpack( Data.Podium )
		
	end
	
	local Podium = ents.Create( "podium" )
	Podium:SetPos( Pos )
	Podium:SetAngles( Ang )
	Podium:Spawn()
	Podiums.Reg[ Index ] = Podium
	Podium:SetCams( Podiums:GetData()[ Index ].Cams )
	
	return Podium, Index
	
end



concommand.Add( "podium_spawn", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	
	local Index = tonumber( args[1] )
	if !Index then Index = Podiums:Length() + 1 end

	if CLIENT then return end
	
	SpawnPodium( Index, ply:GetEyeTrace().HitPos )
	
	if !ply:HasWeapon( "weapon_physgun" ) then
		
		ply:Give( "weapon_physgun" )
		
	end
	
end )


concommand.Add( "podium_remove", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end

	if CLIENT then return end
	
	if IsValid( Podiums.Reg[ Index ] ) then
	
		Podiums.Reg[ Index ]:Remove()
		
	end
	
	Podiums:GetData()[ Index ] = nil
	Podiums:Save()
	
end )


concommand.Add( "podium_set", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	local Ent = ply:GetEyeTrace().Entity
	
	print( Ent )
	
	if IsValid( Ent ) and Ent:GetClass() == "podium" then
		
		Podiums:GetData()[ Index ].Podium = { Ent:GetPos(), Ent:GetAngles() }
		Podiums.Reg[ Index ] = Ent
		Podiums.Reg[ Index ]:SetCams( Podiums:GetData()[ Index ].Cams )
		Podiums:Save()
		
	else
	
		print( "No podium found" )
		
	end
	
end )



concommand.Add( "podium_cam", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	if !Podiums:GetData()[ Index ] then print( "Create a podium first" ) return end
	if !Podiums:GetData()[ Index ].Cams then Podiums:GetData()[ Index ].Cams = {} end
	
	local CamIndex = tonumber( args[2] ) or #Podiums:GetData()[ Index ].Cams + 1
	
	Podiums:GetData()[ Index ].Cams[ CamIndex ] = { ply:EyePos(), ply:EyeAngles() }
	Podiums:Save()
	
	if IsValid( Podiums.Reg[ Index ] ) then
	
		Podiums.Reg[ Index ]:SetCams( Podiums:GetData()[ Index ].Cams )
		
	end
	
	print( "Create Cam: " .. CamIndex .. " on podium " .. Index )
	
end )



concommand.Add( "podium_camremove", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	if !Podiums:GetData()[ Index ] then print( "Create a podium first" ) return end
	local CamIndex = tonumber( args[2] ) or #Podiums:GetData()[ Index ].Cams
	
	if Podiums:GetData()[ Index ].Cams then
		
		if Podiums:GetData()[ Index ].Cams[ CamIndex ] then
			
			table.remove( Podiums:GetData()[ Index ].Cams, CamIndex )
			print( "Removed cam: " .. CamIndex )
			Podiums:Save()
			
			if IsValid( Podiums.Reg[ Index ] ) then
			
				Podiums.Reg[ Index ]:SetCams( Podiums:GetData()[ Index ].Cams )
				
			end
			
			return
			
		end
		
	end
	
	print( "No cameras found" )
	
end )



concommand.Add( "podium_test", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	
	local Index = tonumber( args[1] )
	if !Index then print( "Please supply index" ) return end
	
	if IsValid( Podiums.Reg[ Index ] ) then
	
		Podiums.Reg[ Index ]:CameraAnim( ply )
		
	else
	
		print( "No podium entity" )
		
	end

end )



concommand.Add( "podium_stoptest", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	if CLIENT then return end
	
	sendMessage( "StopCameraAnim", ply )

end )

if CLIENT then return end

function RemoveAllPodiums()
	
	for k,v in pairs( ents.FindByClass( "podium" ) ) do
		
		v:Remove()
		
	end
	
end
RemoveAllPodiums()

concommand.Add( "podium_clear", function( ply, cmd, args )
	
	if !ply:IsAdmin() then return end
	RemoveAllPodiums()
	
end )


AddRequest( "GrabPodiumCams", function( ply, T )
	
	if !IsValid( T[1] ) then return end
	if T[1]:GetClass() != "podium" then return end
	
	T[1]:SetCams( _, ply, true )
	
end )

hook.Add( "SetupPlayerVisibility", "PodiumVis", function( ply, view )
	
	for k,v in pairs( ents.FindByClass( "podium" ) ) do
	
		AddOriginToPVS( v:GetPos() + Vector( 0,0,100 ) )
		
	end
	
end )