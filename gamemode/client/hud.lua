--
-- HUD Object (Holds Widgets)
--

HUD = {}
HUD.__index = HUD

-- Create a new HUD
function HUD:new( Hidden )
	
	local NewHud = {
		
		Hidden = Hidden or false,
		Widgets = {},
		
	}
	
	setmetatable( NewHud, HUD )
	return NewHud
	
end

function HUD:GetHidden()
	
	return self.Hidden
	
end

-- Add a widget
function HUD:AddWidget( Name, Widget )
	
	Widget.Parent = self
	self.Widgets[ Name ] = Widget
	
	-- Won't draw if HUD is hidden
	Widget:Run()
	
end

function HUD:SetHidden( State )
	
	self.Hidden = State
	
	for Name, Widget in pairs( self.Widgets ) do
			
		Widget:SetHidden( State )
			
	end
	
end

function HUD:Kill()
	
	self:SetHidden( true )
	self = nil
	
end

setmetatable( HUD, { __call = HUD.new } )