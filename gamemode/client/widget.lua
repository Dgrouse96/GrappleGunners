--
-- Widget Object
--

WidgetRegistry = WidgetRegistry or {}
ClearObjects( WidgetRegistry )

local WidgetID = 0

Widget = {}
Widget.__index = Widget

-- Create a new widget
function Widget:new( Hidden )
	
	WidgetID = WidgetID + 1
	
	local NewWidget = {
		
		Hidden = Hidden or false,
		Parent = {},
		Data = {},
		ID = WidgetID,
		
	}
	
	setmetatable( NewWidget, Widget )
	WidgetRegistry[ WidgetID ] = NewWidget
	
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
	
	self.Data[ Index ] = Data
	
end

function Widget:GetData( Index )
	
	return self.Data[ Index ]
	
end

-- Hide/Draw widgets
function Widget:SetHidden( State, DontChange )
	
	if !DontChange then
	
		self.Hidden = State
		
	end
	
	if State then
	
		self:Hide()
	
	else
	
		self:UnHide()
		
	end
	
end

function Widget:GetHidden()
	
	return self.Hidden or self.Parent.Hidden
	
end

function Widget:UnHide()
	
	if !self.Parent.Hidden then
		
		if self.Init then
		
			self:Init()
			
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
	
	hook.Remove( "HUDPaint", self )
	hook.Remove( "Think", self )
	
end

function Widget:Kill()
	
	self:Hide()
	self = nil
	
end

setmetatable( Widget, { __call = Widget.new } )