--
-- Used with sniper
--

EFFECT.Mat = Material("grapplegunners/fx/snipermist")

function EFFECT:Init( Data )

	self.Position = Data:GetStart()
	self.WeaponEnt = Data:GetEntity()
	self.Attachment = Data:GetAttachment()

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = Data:GetOrigin()

	self.Alpha = 255
	self.Life = 0

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
end

function EFFECT:Think()

	self.Life = self.Life + FrameTime() * 1
	self.Alpha = 255 * ( 1 - self.Life ) * 0.1

	return ( self.Life < 1 )
	
end


function EFFECT:Render()
	
	if ( self.Alpha < 1 ) then return end
	
	local Length = self.StartPos:Distance( self.EndPos )
	local UV = Length * 0.002
	local Width = math.Clamp( 25 * self.Life, 1, 30 )
	
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, Width, 0, UV, Color( 255, 255, 255, self.Alpha ) )
	
end