AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.WinnerLocations = {
	[1] = Vector(),
	[2] = Vector(),
	[3] = Vector(),
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
		
		local Pos = self.WinnerLocations[ Place ] + self:GetPos()
		return Pos, self:GetAngles()
		
	end
	
	return Vector(), self:GetAngles()
	
end