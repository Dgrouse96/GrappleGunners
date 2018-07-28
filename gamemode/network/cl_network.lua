--
-- NetString Wrapper
--

-- Send data to sever if request exists
function sendRequest( name, t )
	
	if !t then t = {} end
	
	net.Start( "gg_Request" )

		net.WriteString( name )
		net.WriteTable( t )

	net.SendToServer()

end

-- Receive types --

net.Receive( "gg_Table", function()

	local name = net.ReadString()
	local t = net.ReadTable()
	
	hook.Run( name, t )

end )

net.Receive( "gg_Message", function()

	local name = net.ReadString()

	hook.Run( name )

end )

net.Receive( "gg_Float", function()

	local name = net.ReadString()
	local f = net.ReadFloat()

	hook.Run( name, f )

end )

net.Receive( "gg_Entity", function()

	local name = net.ReadString()
	local e = net.ReadEntity()

	hook.Run( name, e )

end )

net.Receive( "gg_Args", function()
	
	local name = net.ReadString()
	local t = net.ReadTable()

	hook.Run( name, unpack( t ) )

end )
