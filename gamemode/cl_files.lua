--
-- Loads client lua
--

local Files = {
	"shared",
}

for k,v in pairs(Files) do
	include( v..".lua" )
end