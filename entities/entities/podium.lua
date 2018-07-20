ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.WinnerLocations = {
	[1] = Vector()
	[2] = Vector()
	[3] = Vector()
}

function ENT:Initialize()
	
	self:SetModel( "models/grapplegunners/podium.mdl" )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	
end

function ENT:Draw()
	
	self:DrawModel( true )
	
end

function ENT:GetWinnerCount()
	
	return #self.WinnerLocations
	
end

function ENT:GetWinPos( Place )
	
	if Place <= self:GetWinnerCount() then
	
		return self.WinnerLocations[ Place ], self:GetAngles()
		
	end
	
	return Vector(), self:GetAngles()
	
end