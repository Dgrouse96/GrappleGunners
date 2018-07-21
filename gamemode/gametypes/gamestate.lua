--
-- Game states, children of gametypes, lovers of women
--


-- Kill any existing gamestates
if !GameStateRegistry then GameStateRegistry = {} end
ClearObjects( GameStateRegistry )

-- Used for registry
local GameStateID = 0


-- Declare GameState object
GameState = {}
GameState.__index = GameState


-- Call function
function GameState:new( Data )

	if !Data then Data = {} end
	
	GameStateID = GameStateID + 1

	Data.Hooks = {}
	Data.ID = GameStateID
	
	setmetatable( Data, GameState )
	GameStateRegistry[ GameStateID ] = Data
	
	return Data
	
end


-- Allows self to be used as a hook identifier
function GameState:IsValid()
	
	return true
	
end


-- Returns true parent game type is in play
function GameState:ParentInPlay()
	
	if self.Parent and self.Parent.InPlay then return true end
	
	return false
	
end


-- Add hooks to gamestate
function GameState:AddHook( Name, Func )
	
	self.Hooks[ Name ] = Func
	
	if self:ParentInPlay() then
	
		hook.Add( Name, self, Func )
		
	end
	
end


-- Remove hooks from gamestate
function GameState:RemoveHook( Name )
	
	if self.Hooks[ Name ] then
		
		self.Hooks[ Name ] = nil
		hook.Remove( Name, self )
		
	end
	
end

-- Adds all hooks
function GameState:AddHooks()
	
	if self:ParentInPlay() then
	
		for Name, Func in pairs( self.Hooks ) do
			
			hook.Add( Name, self, Func )
			
		end
		
	end
	
end


-- Removes hooks
function GameState:RemoveHooks()
	
	if !self.Hooks then return end
	
	for name,_ in pairs( self.Hooks ) do
		
		hook.Remove( name, self )
		
	end
	
end


-- Destroy this table
function GameState:Kill()
	
	self:RemoveHooks()
	table.Empty( self )
	self = nil
	
end


setmetatable( GameState, { __call = GameState.new } )