--
-- Drawing Wrapper
--

-- Good for fixed size scaling
function sres(x)

	local RES = ( ScrW()+ScrH() ) / 3000
	
	if x and type( x ) == "number" then
	
		return math.floor( x * RES )
		
	end
	
end

-- Position scaling along X
function sresx(x)

	local RES = ScrW() / 1920
	
	if x and type( x ) == "number" then
	
		return math.floor( x * RES )
		
	end
end

-- Position scaling along Y
function sresy(x)

	local RES = ScrH()/1080
	
	if x and type( x ) == "number" then
	
		return math.floor( x * RES )
		
	end
	
end

function SetMat( s )
	surface.SetMaterial( s )
end

function SetTex( s )
	surface.SetTexture( surface.GetTextureID( s ) )
end

function SetCol( t )
	surface.SetDrawColor( t.r,t.g,t.b,t.a )
end

function DText( t )
	draw.SimpleText( t.t, t.f, sresx(t.x),sresy(t.y), t.c, t.ax, t.ay )
end

function DTextShadow( t,dist )

	if !dist then dist = 2 end
	
	local s = table.Copy( t )
	
	s.x = s.x+dist
	s.y = s.y+dist
	s.c = Color(0,0,0,t.c.a)
	
	DText( s )
	DText( t )
	
end

function DTextSimple( t )
	draw.SimpleText( t.t, t.f,t.x,t.y, t.c, t.ax, t.ay )
end

function DTRectSimple( t )
	surface.DrawTexturedRect(t.x,t.y,t.w,t.h)
end

function DTRectSimpleR( t )
	if !t.r then t.r = 0 end
	surface.DrawTexturedRectRotated(t.x,t.y,t.w,t.h,t.r)
end

function DTRect( t )
	surface.DrawTexturedRect(sresx(t.x),sresy(t.y),sres(t.w),sres(t.h))
end

function DTRectUV( t )
	surface.DrawTexturedRectUV(sresx(t.x),sresy(t.y),sres(t.w),sres(t.h), t.su, t.sv, t.eu, t.ev)
end

function DTRectR( t )
	if !t.r then t.r = 0 end
	surface.DrawTexturedRectRotated(sresx(t.x),sresy(t.y),sres(t.w),sres(t.h),t.r)
end

function DBoxSimple( t )
	surface.DrawRect( t.x,t.y,t.w,t.h )
end

function DBox( t )
	surface.DrawRect( sresx(t.x),sresy(t.y),sres(t.w),sres(t.h) )
end

function DRBox( t )
	draw.RoundedBox( sres(t.r),sresx(t.x),sresy(t.y),sres(t.w),sres(t.h),t.c )
end

function DRBoxS( t )
	draw.RoundedBox( sres(t.r),sresx(t.x),sresy(t.y),sres(t.w),sres(t.h),t.c )
end

-- Check for resolution changes
local Sw,Sh = ScrW(),ScrH()

timer.Create( "CheckResolution", 1, 0, function()

	if Sw != ScrW() or Sh != ScrH() then
	
		Sw,Sh = ScrW(),ScrH()
		hook.Run("UpdateScreenRes",Sw,Sh)
		
	end
	
end)

local AvatarRes = { 16, 32, 64, 84, 128, 184 }

function AvatarResolution( Size )

	for k,v in pairs( AvatarRes ) do
	
		if Size <= v then
		
			return v
			
		end
		
	end
	
	return AvatarRes[ table.Count( AvatarRes ) ]
	
end

local function tm(s)

	if s < 10 then
	
		return "0"..s
		
	else
	
		return s
		
	end
	
end

function string.SortTime( s )

	local s = math.floor( s )
	
	if s < 60 then
	
		return tostring( s )
		
	end
	
	local d = math.floor( s/86400 )
	local h = math.floor( (s-d*86400)/3600 )
	local m = math.floor( (s-h*3600-d*86400)/60 )
	local sc = math.floor( s - m*60 - h*3600 - d*86400 )

	if d > 0 then
	
		return d..":"..tm(h)..":"..tm(m)..":"..tm(sc)
		
	end
	
	if h > 0 then
	
		return tm(h)..":"..tm(m)..":"..tm(sc)
		
	end
	
	if m > 0 then
	
		return tm(m)..":"..tm(sc)
		
	end
	
	return tostring( sc )
end

function string.SortTimeMil( s )

	if s <= 10 then
		local x = math.Round( (s-math.floor(s))*100 )
		return string.SortTime( s )..":"..x
	end
	
	return string.SortTime( s )
end

function Decimal( x )

	local p = ""
	local e = string.Explode(".",x)
	
	if #e <= 1 then
	
		p = ".0"
		
	end
	
	return x..p
	
end

function CommaRound( x )
	return string.Comma( math.Round(x) )
end