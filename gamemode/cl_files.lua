--
-- Loads client lua
--

local Files = {
	"shared",
	"shared/spheretrace",
	"network/cl_network"
}

for k,v in pairs(Files) do
	
	include( v..".lua" )
	
end