--
-- Gametypes, basically runtime gamemodes
--


-- Kill any existing gametypes
if !GameTypeRegistry then GameTypeRegistry = {} end
ClearObjects( GameTypeRegistry )

-- For working with multiple game types
CurrentGameType = nil


-- Declare GameType object
GameType = {}
GameType.__index = GameType


-- Call function
function GameType:new( ID )

	NewGameType = {

		Name = "",
		Description = "",
		ID = ID,
		InPlay = false,
		Hooks = {},
		States = {},
		Scores = {},
		SortedPlayers = function()
			
			local tab = table.Copy( player.GetAll() )
			table.sort( tab, function( a, b ) return a:Frags() > b:Frags() end )
			return tab
			
		end
		
	}

	setmetatable( NewGameType, GameType )
	GameTypeRegistry[ ID ] = NewGameType

	return NewGameType

end


-- Allows self to be used as a hook identifier
function GameType:IsValid()

	return true

end


-- ID search, returns gametype
function GetGameTypeByID( ID )

	return GameTypeRegistry[ ID ]

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
function GameType:SetState( NewState, Replicate, ... )

	if !self:GetState( NewState ) then return end

	if SERVER then

		if Replicate then

			sendTable( "NewGameState", { self.ID, NewState, ... } )

		end

	end

	local LastState = CurrentState

	-- Leave last state
	if self:GetState() then

		if self:GetState().Leave then

			self:GetState():Leave()

		end

		self:GetState():RemoveHooks()

	end

	-- Enter new state
	if self:GetState( NewState ).Enter then

		self:GetState( NewState ):Enter( ... )

	end

	self:GetState( NewState ):AddHooks()


	-- Fires when a state changes, useful for auto state switching
	if self.StateChanged then

		self:StateChanged( NewState, LastState )

	end

	CurrentState = NewState

end


-- Server replicates state to clients
hook.Add( "NewGameState", "NewGameState", function( T )

	GetGameTypeByID( T[1] ):SetState( T[2], _, unpack( T, 3 ) )

end )


-- Sets the next state
function GameType:SetNextState( ID, ... )

	self.NextState = ID
	self.NextStateArgs = ...
end


-- Switches to the next state
function GameType:DoNextState( Replicate )

	self:SetState( self.NextState, Replicate, self.NextStateArgs )

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


function GameType:AddScoreColumn( Name, Column, Getter )
	
	if !Column then Column = #self.Scores + 1 end
	
	self.Scores[ Column ] = {
		Name = Name,
		Getter = Getter,
	}
	
end


-- Start the Game Type
function GameType:Play()

	if CurrentGameType then

		CurrentGameType:Stop()

	end

	self.InPlay = true
	self:AddHooks()

	if self.Init then

		self:Init()

	end
	
	CurrentGameType = self

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

if SERVER then

	function StartGameType( GT ) -- USE THIS FOR SWITCHING GAMETYPES
		
		if isnumber( GT ) then
		
			GT = GetGameTypeByID( GT )
			
		end
		
		sendFloat( "StartGameType", GT.ID )
		PlayTime:SetGameTypeRep( _, GT.ID )
		
		GT:Play()
		
	end

else
	
	hook.Add( "StartGameType", "ClientRep", function( f )
	
		GetGameTypeByID( f ):Play()
	
	end )
	
end