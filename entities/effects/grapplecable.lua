--
-- Physical Grapple Cable
--

EFFECT.Material = Material( "grapplegunners/models/grapplecable" )

function EFFECT:Init( Data )

	self.ply = Data:GetEntity()

	if self.ply and self.ply:Alive() and self.ply.GrappleLocation then

		//self:NewMaterial()
		self:SetModel( "models/grapplegunners/grapplecable.mdl" )
		self:SetMaterial( self.Material )
		self:DrawShadow( true )

	end

	self.First = 0
	self.Life = 0

end

function EFFECT:Think()

	if self.First < 2 then

		self:ResetSequence( 1 )
		self.First = self.First + 1

	end

	if self.ply and self.ply:Alive() and self.ply.GrappleLocation then

		self.Life = self.Life + FrameTime()

		-- Determine Start Location
		local Pos = Vector()

		if self.ply == LocalPlayer() and !self.ply:IsThirdPerson() then

			local M = Matrix()
			M:Rotate( self.ply:EyeAngles() )
			M:Translate( Vector( 10, 10, -40 ) )
			Pos = self.ply:EyePos() + M:GetTranslation()

		else

			local Hand = self.ply:GetBoneMatrix( 16 )

			if Hand then

				Hand:Translate( Vector( 2.5, -1.2, 1 ) )
				Pos = Hand:GetTranslation() + ( self.ply:GetVelocity() * FrameTime() )

			end

		end

		self.StartPos = Pos
		self.EndPos = self.ply.GrappleLocation

		self:SetPos( self.StartPos )
		local Sub = self.EndPos - self.StartPos

		local Len = Sub:Length() * 0.01
		local Extend = math.Clamp( self.Life * 40, 0, Len )

		local Dir = Sub:GetNormal()
		self:SetAngles( Dir:Angle() )

		local M = Matrix()
		M:Scale( Vector( Extend, 1, 1 ) )
		self:EnableMatrix( "RenderMultiply", M )


	else

		return false

	end

	return true

end


function EFFECT:Render()

	self:DrawModel()

	return true

	/*
	if self.ply and self.ply:Alive() and self.ply.GrappleLocation then

		if self.Material then

			local Sub = self.EndPos - self.StartPos
			local Len = Sub:Length() * 0.01
			local Extend = math.Clamp( self.Life * 40, 0, Len )

			self.Material:SetFloat( "$Length", Extend )

		end

	end
	*/

end
