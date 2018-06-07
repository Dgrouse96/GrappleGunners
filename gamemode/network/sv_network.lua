--
-- NetString Wrapper
--

-- NetStrings to add
local NetStrings = {
	"gg_Table",
	"gg_Message",
	"gg_Float",
	"gg_Entity",
	"gg_Request",
}

-- Add NetStrings
for k,v in pairs( NetStrings ) do

	util.AddNetworkString( v )
	
end

-- Replicate to Spectators
local function replicate( ply )

	if !ply.Spectators then
	
		net.Send( ply )
		return
		
	end
	
	local T = table.Copy( ply.Spectators )
	table.insert( T, ply )
	net.Send( T )
	
end

-- Send float to client
function sendFloat( name, float, ply, rep )

	net.Start( "gg_Float" )
	net.WriteString( name )
	net.WriteFloat( float )
		
	if rep then
	
		replicate( ply )
		
	else
	
		if ply then
		
			net.Send( ply )
			
		else
		
			net.Broadcast()
			
		end
		
	end
	
end

-- Send message to client (execute hook)
function sendMessage( name, ply, rep )

	net.Start( "gg_Message" )
	net.WriteString( name )
	
	if rep then
	
		replicate( ply )
		
	else
	
		if ply then
		
			net.Send( ply )
			
		else
		
			net.Broadcast()
			
		end
		
	end
	
end

-- Send table to client
function sendTable( name, t, ply, rep )

	net.Start( "gg_Table" )
	net.WriteString( name )
	net.WriteTable( t )
	
	if rep then
	
		replicate( ply )
		
	else
	
		if ply then
		
			net.Send( ply )
			
		else
		
			net.Broadcast()
			
		end
		
	end
	
end

-- Send entity reference to client
function sendEntity( name, ent, ply, rep )

	net.Start( "gg_Entity" )
	net.WriteString( name )
	net.WriteEntity( ent )
	
	if rep then
		
		replicate( ply )
		
	else
		if ply then
		
			net.Send( ply )
			
		else
		
			net.Broadcast()
			
		end
		
	end
	
end


--
-- Requests (client to server)
-- 

local Requests = {}

-- Use this to listen to client data
function AddRequest( Name, Func )

	Requests[Name] = Func
	
end

-- Use this to stop listening to client data
function RemoveRequest( Name )

	Requests[Name] = nil
	
end

-- Executes client's requests
net.Receive( "gg_Request", function( len, ply )

	local name = net.ReadString()
	local t = net.ReadTable()
	
	if Requests[name] and t then
	
		Requests[name]( ply, t )
		
	end
	
end )
