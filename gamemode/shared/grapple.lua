--
-- Predicted Grapple Movement
--

-- Trace to find hook location, trace line before trace sphere
local function HookTrace( ply, debugtime )
	
	local trace = {
		start = ply:EyePos(), 
		endpos = ply:EyePos()+ply:EyeAngles():Forward()*1000,
		mask = MASK_SOLID_BRUSHONLY,
		radius = 200
	}
	
	local linetrace = util.TraceLine( trace )
	
	if linetrace.Hit then 
	
		if debugtime then
			
			debugoverlay.Line( trace.start, linetrace.HitPos, debugtime, Color(255,120,0) )
			debugoverlay.Cross( linetrace.HitPos, 4, debugtime, Color(255,0,0) )
			
		end
	
		return linetrace
	
	else
	
		return util.spheretrace( trace, true, debugtime )
	
	end
	
end

-- Calculate New Velocity
local function CalcGrapple( ply, mv, cmd, trace )
	
	/*
	local Direction = mv:GetVelocity()
	local Normal = trace.HitPos-mv:GetOrigin()
	Normal:Normalize()
	
	local Reflection = FindReflectionAngle( Direction, Normal )
	mv:SetVelocity( Reflection )
	*/
	
end

-- Sensitive Prediction stuff
function GM:SetupMove( ply, mv, cmd )
	
	if !ply.TickData then ply.TickData = {} end
	local TD = ply.TickData[ cmd:TickCount() ]
	local LTD = ply.TickData[ cmd:TickCount()-1 ]
	
	if !IsFirstTimePredicted() then
		
		if TD then
			
			mv:SetVelocity( TD.Velocity )
			
		end
		
		return
	
	end
	
	if cmd:KeyDown( IN_ATTACK2 ) then
		
		local trace
		
		-- If last tick show's we're grappling, lets continue grappling
		if LTD and LTD.Trace then
			
			trace = LTD.Trace
			CalcGrapple( ply, mv, cmd, trace )
			
			TD = {
				Velocity = mv:GetVelocity(),
				Trace = trace,
			}
			
			
		else
			
			-- Check if we can start to grapple
			trace = HookTrace( ply, 0.5 )
			
			if trace and trace.Hit then
				
				CalcGrapple( ply, mv, cmd, trace )
				
				TD = {
					Velocity = mv:GetVelocity(),
					Trace = trace,
				}
				
			end
			
		end
		
		ply.TickData[ cmd:TickCount() ] = TD

	end
	
end