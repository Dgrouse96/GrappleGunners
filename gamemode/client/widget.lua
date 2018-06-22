--
-- Widget Object
--

Widget = {}
Widget.__index = Widget

-- Create a new widget
function Widget:new( Init, Draw, Think, Hidden )
	
	local NewWidget = {
		
		Init = Init,
		Draw = Draw,
		Think = Think,
		Hidden = Hidden or false,
		Parent = {},
		Data = {},
	}
	
	setmetatable( NewWidget, Widget )
	return NewWidget
	
end

-- If we want to add our function together
function Widget:Setup( Init, Draw, Think, Hidden )
	
	self.Init = Init or self.Init
	self.Draw = Draw or self.Draw
	self.Think = Think or self.Think
	self.Hidden = Hidden or self.Hidden
	
end

function Widget:IsValid()

	return true
	
end

function Widget:AddData( Index, Data )
	
	self.Data[ Index ] = Table
	
end

function Widget:GetData( Index )
	
	return self.Data[ Index ]
	
end

-- Hide/Draw widgets
function Widget:SetHidden( State )
	
	self.Hidden = State
	
	if State then
	
		self:Run()
	
	else
	
		self:UnHide()
		
	end
	
end

function Widget:GetHidden()
	
	return self.Hidden
	
end

function Widget:Run()
	
	if !self.Parent.Hidden then
	
		self.Hidden = false
		
		if self.Init then
		
			self.Init()
			
		end
		
		if self.Draw then 
			
			hook.Add( "HUDPaint", self, self.Draw )
			
		end
		
		if self.Think then
		
			hook.Add( "Think", self, self.Think )
			
		end
		
	end
	
end

function Widget:Hide()
		
	self.Hidden = true
	
	hook.Remove( "HUDPaint", self )
	hook.Remove( "Think", self )
	
end

function Widget:Kill()
	
	self:Hide()
	self = nil
	
end

setmetatable( Widget, { __call = Widget.new } )