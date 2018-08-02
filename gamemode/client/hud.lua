--
-- HUD Object (Holds Widgets)
--

HUDRegistry = HUDRegistry or {}
ClearObjects( HUDRegistry )

local HUDID = 0

HUD = {}
HUD.__index = HUD

-- Create a new HUD
function HUD:new( Hidden )
	
	HUDID = HUDID + 1
	
	local NewHud = {
		
		Hidden = Hidden or false,
		Widgets = {},
		ID = HUDID,
		
	}
	
	setmetatable( NewHud, HUD )
	HUDRegistry[ HUDID ] = NewHud
	
	return NewHud
	
end

function HUD:GetHidden()
	
	return self.Hidden
	
end

function HUD:AddWidget( Name, Widget )
	
	Widget.Parent = self
	self.Widgets[ Name ] = Widget
	
	-- Won't draw if HUD is hidden
	if !Widget:GetHidden() then
	
		Widget:UnHide()
		
	end
	
end

function HUD:ReparentWidgets()
	
	for Name, Widget in pairs( self.Widgets ) do
		
		Widget.Parent = self
		
		if Widget.Reparent then
			
			Widget:Reparent()
			
		end
		
	end
	
end

function HUD:RemoveWidget( Name )
	
	if self.Widgets[ Name ] then
		
		self.Widgets[ Name ]:Kill()
		self.Widgets[ Name ] = nil
		
	end
	
end

function HUD:SetHidden( State )
	
	self.Hidden = State
	
	for Name, Widget in pairs( self.Widgets ) do
			
		Widget:SetHidden( State, true )
			
	end
	
end

function HUD:Kill()
	
	for k,v in pairs( self.Widgets ) do
	
		v:Kill()
	
	end
	
	self = nil
	
end

setmetatable( HUD, { __call = HUD.new } )