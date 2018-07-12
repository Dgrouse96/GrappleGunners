-- For working with multiple game types
CurrentGameType = nil
GameTypeRegistry = {}


-- Declare GameType object
GameType = {}
GameType.__index = GameType


-- Call function
function GameType:new( Data )
	
	local NewGameType = Data
	
	if !NewGameType then
	
		NewGameType = {
			
			Name = "",
			Description = "",
			InPlay = false,
			CurrentState = nil,
			NextState = nil
			Hooks = {},
			States = {},
			
		}
		
	end
	
	setmetatable( NewGameType, GameType )
	table.insert( GameTypeRegistry, NewGameType )
	
	return NewGameType
	
end


-- Attach a hook to this game type
function GameType:AddHook( Name, Func )
	
	self.Hooks[ Name ] = Func
	
	if self.InPlay then
	
		hook.Add( Name, self, Func )
		
	end
	
end


-- Add hooks if in play
function GameType:AddHooks()
	
	if self.InPlay then
	
		for Name, Func in pairs( self.Hooks ) do
			
			hook.Add( Name, self, Func )
			
		end
		
	end
	
end


-- Remove hooks from game type
function GameType:RemoveHook( Name )
	
	if self.Hooks[ Name ] then
		
		self.Hooks[ Name ] = nil
		hook.Remove( Name, self )
		
	end
	
end


-- Removes hooks
function GameType:RemoveHooks()

	for name, _ in pairs( self.Hooks ) do
		
		hook.Remove( name, self )
		
	end
	
end


-- Remove all hooks 
function GameType:EmptyHooks()
	
	self:RemoveHooks()
	table.Empty( self.Hooks )
	
end


-- Add a state object
function GameType:AddState( ID, State )
	
	self.States[ ID ] = State
	State.Parent = self
	
end


-- Grab state by ID
function GameType:GetState( ID )
	
	if !ID then
		
		return self.States[ CurrentState ]
		
	end
	
	return self.States[ ID ]
	
end


-- Leaves current state and starts new state
function GameType:SetState( NewState )
	
	if !self:GetState( NewState ) then return end
	
	local LastState = CurrentState
	
	-- Leave last state
	if self:GetState() then
		
		if self:GetState().Leave then
			
			self:GetState():Leave()
			
		end
		
		self:GetState():RemoveHooks()
	
	
	-- Enter new state
	else
		
		if self:GetState( NewState ).Enter then
		
			self:GetState( NewState ):Enter()
			
		end
		
		self:GetState( NewState ):AddHooks()
		
	end
	
	
	-- Fires when a state changes, useful for auto state switching
	if self.StateChanged then
		
		self:StateChanged( NewState, LastState )
		
	end
	
end

function GameType:SetNextState( ID )
	
	self.NextState = ID
	
end


-- Stops all states (usually when a gametype dies)
function GameType:StopAllStates()
	
	for ID,State in pairs( self.States ) do
		
		State:RemoveHooks()
		
		if State.Stop then
			
			State:Stop()
			
		end
		
	end
	
end


-- Start the Game Type
function GameType:Play( State )
	
	if CurrentGameType then
		
		CurrentGameType:Stop()
		
	end
	
	self.InPlay = true
	self:AddHooks()
	
	if self.Init then
		
		self:Init()
		
	end
	
	print( "GAMETYPE LOADED: " .. self.Name )
	
end


-- Stops a Game Type without destroying it
function GameType:Stop()
	
	self:StopAllStates()
	self:RemoveHooks()
	
	if self.Unload then
		
		self:Unload()
		
	end
	
end


-- Destroy this table
function GameType:Kill()
	
	self:EmptyHooks()
	self:StopAllStates()
	table.Empty( self )
	self = nil
	
end


setmetatable( GameType, { __call = GameType.new } )