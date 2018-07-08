--
-- Pose Object - Designed to not produce garbage
--


-- Grab pose if string
local function GetPose( Pose )
	
	if isstring( Pose ) then
		
		return POSES[ Pose ]
		
	end
	
	return Pose
	
end


-- Declare pose object
Pose = {}
Pose.__index = Pose


-- Call function
function Pose:new()
	
	local NewPose = {}
	
	setmetatable( NewPose, Pose )
	return NewPose
	
end


-- Reset the pose, keep pointer
function Pose:Reset( NewPose )
	
	NewPose = GetPose( NewPose )
	
	if istable( NewPose ) then
	
		for k,v in pairs( NewPose ) do
			
			if !self[k] then self[k] = {} end
			
			-- Set individual values to keep pointer
			self[k].p = v.p
			self[k].a = v.a
			
		end
		
	end
	
end


-- Force all current data to 0
function Pose:Zero()
	
	for k,v in pairs( self ) do
		
		self[k].p = Vector()
		self[k].a = Angle()
		
	end
	
end


-- Replace bones of this pose
function Pose:Replace( OtherPose )
	
	OtherPose = GetPose( OtherPose )
	
	for k,v in pairs( OtherPose ) do
		
		self[k] = v
		
	end
	
end


-- Add another pose into this pose
function Pose:Add( OtherPose )
	
	OtherPose = GetPose( OtherPose )
	
	for k,v in pairs( OtherPose ) do
		
		if self[k] then
			
			self[k].p = self[k].p + v.p 
			self[k].a = self[k].a + v.a 
			
		end
		
	end
	
end


-- Lerp another pose into this pose
function Pose:Blend( Alpha, OtherPose )
	
	OtherPose = GetPose( OtherPose )
	
	for k,v in pairs( OtherPose ) do
		
		if self[k] then
			
			self[k].p = LerpVector( Alpha, self[k].p, v.p )
			self[k].a = LerpAngle( Alpha, self[k].a, v.a )
			
		end
		
	end
	
end


function Pose:Blend2( Alpha, BlendAlpha, Pose1, Pose2 )
	
	Pose1 = GetPose( Pose1 )
	Pose2 = GetPose( Pose2 )
	
	for k,v in pairs( Pose1 ) do
		
		if self[k] and Pose2[k] then
			
			self[k].p = LerpVector( Alpha, self[k].p, LerpVector( BlendAlpha, v.p, Pose2[k].p ) )
			self[k].a = LerpAngle( Alpha, self[k].a, LerpAngle( BlendAlpha, v.a, Pose2[k].a ) )
			
		end
		
	end
	
end


-- Destroy this table
function Pose:Kill()
	
	table.Empty( self )
	self = nil
	
end


setmetatable( Pose, { __call = Pose.new } )


--
-- Player-Based Pose
--
local PLY = FindMetaTable( "Player" )


-- Initializes and retrieves pose
function PLY:GetPose()
	
	if !self.AnimPose then
		
		self.AnimPose = Pose()
		
	end
	
	return self.AnimPose
	
end


-- Sets their bones to this pose
function PLY:ApplyPose()
	
	for k,v in pairs( self.AnimPose ) do
		
		self:ManipulateBonePosition( k, v.p )
		self:ManipulateBoneAngles( k, v.a )
		
	end
	
end


-- Grab latest instance of Pose meta table
local function ReloadFix()

	for k,ply in pairs( player.GetAll() ) do
		
		if ply.AnimPose then
			
			ply.AnimPose:Kill()
			ply.AnimPose = nil
			
		end
		
	end
	
end
hook.Add( "OnReloaded", "PoseObjectReset", ReloadFix )