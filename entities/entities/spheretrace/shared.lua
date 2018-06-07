ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.SpawnVelocity = Vector(0,0,0)

function ENT:SetSpawnVelocity( v )
	self.SpawnVelocity = v
end

function ENT:Initialize()
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
end