AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.Cams = {}
ENT.HasCams = false

ENT.WinnerLocations = {
	[1] = Vector(0,0,95),
	[2] = Vector(77,0,80),
	[3] = Vector(-77,0,75),
}

function ENT:Initialize()
	
	if CLIENT then return end
	
	self:SetModel( "models/grapplegunners/winpodium.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
	
		phys:EnableMotion( false )
		
	end
	
end

function ENT:Draw()
	
	self:DrawModel( true )
	
end

function ENT:GetWinnerCount()
	
	return #self.WinnerLocations
	
end

function ENT:GetWinPos( Place )
	
	if Place <= self:GetWinnerCount() then
		
		local Pos = self:LocalToWorld( self.WinnerLocations[ Place ] )
		return Pos, self:GetAngles()
		
	end
	
	return Vector(), self:GetAngles() + Angle( 0,0,90 )
	
end

--
-- Cameras
--

function ENT:SetCams( Cams, ply, DoAnim )
	
	if !Cams then Cams = self.Cams or {} end
	
	self.Cams = Cams
	self.HasCams = true
	
	if SERVER then
		
		sendArgs( "PodiumCams", { self, Cams, DoAnim }, ply )
		
	end
	
end

hook.Add( "PodiumCams", "Replicate", function( ID, Cams, DoAnim )
	
	if IsValid( ID ) then
	
		ID:SetCams( Cams )
		
		if DoAnim then
		
			ID:CameraAnim()
		
		end
	end
	
end )


function ENT:CameraAnim( ply )
	
	if SERVER then
		
		sendArgs( "PodiumCameraAnim", { self }, ply )
		
		return 
	end
	
	
	DoCameraAnim( self.Cams, 4 )
	
end

hook.Add( "PodiumCameraAnim", "Replicate", function( ID )

	if IsValid( ID ) then
	
		if ID.HasCams then
		
			ID:CameraAnim()
			
		else
			
			sendRequest( "GrabPodiumCams", { ID } )
			
		end
	
	else
	
		print( "Invalid Podium Ent" )
		
	end
	
end )