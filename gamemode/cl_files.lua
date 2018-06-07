--
-- Loads client lua
--

local Files = {
	"shared",
	"shared/spheretrace",
	"shared/grapple",
	"shared/grapplelib",
	"network/cl_network"
}

for k,v in pairs(Files) do
	
	include( v..".lua" )
	
end