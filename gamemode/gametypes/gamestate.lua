-- Declare GameState object
GameState = {}
GameState.__index = GameState


-- Call function
function GameState:new( Data )
	
	local NewState = Data
	
	if !NewState then
	
		NewState = {
			
			Hooks = {},
			
		}
		
	end
	
	setmetatable( NewState, GameState )
	return NewState
	
end


-- Returns true parent game type is in play
function GameState:ParentInPlay()
	
	if self.Parent and self.Parent.InPlay then return true
	
	return end
	
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


-- Removes hooks
function GameState:RemoveHooks()

	for name, _ in pairs( self.Hooks ) do
		
		hook.Remove( name, self )
		
	end
	
end


-- Destroy this table
function GameState:Kill()
	
	table.Empty( self )
	self = nil
	
end


setmetatable( GameState, { __call = GameState.new } )