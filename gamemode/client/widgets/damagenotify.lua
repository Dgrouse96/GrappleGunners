-- Create widget object
Widget_DamageNotify = Widget( true )

Widget_DamageNotify.DamageTime = 0
Widget_DamageNotify.Amount = 0

Widget_DamageNotify.Text = {
	
	t = "100",
	x = 960,
	y = 400,
	f = "DamageNotify",
	ax = 1,
	ay = 1,
	c = Color( 220, 0, 0, 255 ),
	
}

function Widget_DamageNotify:Think()
	
	self.Text.t = self.Amount
	
	local Time = CurTime() - self.DamageTime
	
	-- Text Rumble
	RumbleAlpha = inverselerpclamp( Time, 0.5, 0 )
	self.Text.x = 960 + math.Rand( -4, 4 ) * RumbleAlpha
	self.Text.y = 400 + math.Rand( -4, 4 ) * RumbleAlpha
	
	TextAlpha = inverselerpclamp( Time, 4, 0 )
	self.Text.c.a = 400 * TextAlpha
	
	if TextAlpha <= 0 then
		
		self.Amount = 0
		self:SetHidden( true )
		
	end
	
end

function Widget_DamageNotify:Draw()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	--SetCol( self.Text )
	DTextShadow( self.Text, 1 )
	
end

function Widget_DamageNotify:DealDamage( Amount )
	
	if Amount <= 0 then return end
	
	Amount = math.Round( Amount )
	
	self.DamageTime = CurTime()
	self.Amount = self.Amount + Amount
	self:SetHidden( false )
	
end

hook.Add( "DealtDamage", "WidgetDamageNotify", function( _, Amount ) Widget_DamageNotify:DealDamage( Amount ) end )