S_Kills = Stats( "kills" )

function S_Kills:GetTotalKills( ply )

  local Count = 0

  for k,v in pairs( self:GetPlayerData( ply ) ) do

    if isnumber( v ) then Count = Count + v end

  end

  return Count

end
