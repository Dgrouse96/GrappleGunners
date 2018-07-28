--
-- Widget Object
--

DermaRegistry = DermaRegistry or {}
ClearObjects( DermaRegistry )

local DermaID = 0

Derma = {}
Derma.__index = Derma

-- Create a new widget
function Derma:new( Hidden )
	
	DermaID = DermaID + 1
	
	local NewDerma = {
		
		Hidden = Hidden or false,
		Parent = {},
		Data = {},
		ID = DermaID
		
	}
	
	setmetatable( NewDerma, Derma )
	DermaRegistry[ DermaID ] = NewDerma
	
	return NewDerma
	
end

-- If we want to add our function together
function Derma:Setup( Init, Death, Hidden )
	
	self.Init = Init or self.Init
	self.Death = Death or self.Death
	self.Hidden = Hidden or self.Hidden
	
end

function Derma:IsValid()

	return true
	
end

function Derma:AddData( Index, Data )
	
	self.Data[ Index ] = Data
	
end

function Derma:GetData( Index )
	
	return self.Data[ Index ]
	
end

-- Hide/Draw widgets
function Derma:SetHidden( State, DontChange )
	
	if !DontChange then
	
		self.Hidden = State
		
	end
	
	if State then
		
		self:Hide()
	
	else
	
		self:UnHide()
		
	end
	
end

function Derma:GetHidden()
	
	return self.Hidden
	
end

function Derma:UnHide()
	
	if !self.Parent.Hidden then
		
		if self.Init then
		
			self:Init()
			
		end
		
	end
	
end

function Derma:Hide()
	
	if self.Death then
	
		self:Death()
		
	end
	
end

function Derma:Kill()
	
	self:Hide()
	self = nil
	
end

setmetatable( Derma, { __call = Derma.new } )