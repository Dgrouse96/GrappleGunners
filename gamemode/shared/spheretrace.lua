--
-- Trace with spheres
--

-- Cache spheres for later traces
local Radii = { 
	//[25] = "models/hunter/misc/sphere025x025.mdl",
	//[75] = "models/hunter/misc/sphere075x075.mdl",
	//[100] = "models/hunter/misc/sphere1x1.mdl",
	[200] = "models/hunter/misc/sphere2x2.mdl",
}

-- How many samples to find hit location ( Iterations = Res^2 )
local FinderRes = 10

-- Angle to find surface
local FinderAngle = 165

local Spheres = {}

local function SpawnSpheres()
	
	if SERVER then
		
		-- Remove any existing spheres
		local OldSpheres = ents.FindByClass( "spheretrace" )
		
		for k,v in pairs( OldSpheres ) do
		
			v:Remove()
		
		end
		
		-- Spawn spheres, store references
		for rad,model in pairs( Radii ) do
		
			sphere = ents.Create( "spheretrace" )
			sphere:SetModel( model )
			sphere:DrawShadow( false )
			
			Spheres[rad] = sphere
			
		end
		
		-- We don't have the new spheres
		for k,ply in pairs( player.GetAll() ) do
			
			ply.HasSphereReferences = nil
			
		end
	
	else
		
		-- Ask for sphere references (Reload requires a delay for ents to spawn)
		timer.Simple( 1, function() sendRequest( "ReqSphereRef", {} ) end )
		
	end
		
end

hook.Add( "InitPostEntity", "SpawnSpheres", SpawnSpheres )
hook.Add( "OnReloaded", "RespawnSpheres", SpawnSpheres )


if SERVER then

	-- Send sphere references when asked
	AddRequest( "ReqSphereRef", function( ply )
		
		if ply.HasSphereReferences then return end
		
		sendTable( "SphereRef", Spheres, ply )
		ply.HasSphereReferences = true
		
	end )
	
else

	-- Set sphere references
	hook.Add( "SphereRef", "InitSphereRef", function( t ) Spheres = t end )
	
end


-- Trace a sphere!
util.spheretrace = function( tracedata, findhitpos, debugtime )
	
	local sphere = Spheres[ tracedata.radius ]
	if !sphere then return end
	
	local trace = util.TraceEntity( tracedata, sphere )
	
	-- HitPos is Sphere's pos -_-' (not impact pos)
	if findhitpos then
		
		if trace and trace.Hit then
			
			local Direction = -trace.HitNormal
			local AngleSize = FinderAngle/FinderRes
			
			if debugtime then
			
				debugoverlay.Cross( trace.HitPos, 4, debugtime, Color(0,255,0) )
				
			end
			
			-- Find the impact pos in a uniform spiral pattern
			local CurrentX = FinderRes/2
			local CurrentY = FinderRes/2
			local StepSize = 0
			local StepsLeft = 1 // Steps to take before turn
			
			-- Use less traces by searching up first because most grapples will be above the player!
			-- 0:Right 1:Down 2:Left 3:Up
			local StepDirection = 3
			
			for i=1, FinderRes^2 do
				
				-- Get angles to rotate trace
				local Pitch = AngleSize * ( CurrentY - FinderRes/2 )
				local Yaw   = AngleSize * ( CurrentX - FinderRes/2 )

				-- Matrix works better than Vector:Rotate()
				local M = Matrix()
				M:Rotate( Direction:Angle() )
				M:Rotate( Angle( Pitch, Yaw, 0 ) )
				
				-- Longer trace distance means less itteration and less accuracy (radius/4 is true radius)
				local Dir = M:GetForward() * ( tracedata.radius/2 )
				
				-- Attempt to find surface
				local finder = util.TraceLine( {
					start = trace.HitPos,
					endpos = trace.HitPos + Dir,
					mask = tracedata.mask,
				} )
				
				if debugtime then 
					
					debugoverlay.Line( trace.HitPos, trace.HitPos + Dir, debugtime/(i/4+0.75), Color(0,0,255) )
				
				end
				
				-- If surface swap hitpos
				if finder and finder.Hit then
				
					trace.HitPos = finder.HitPos
					
					if debugtime then
					
						debugoverlay.Cross( trace.HitPos, 4, debugtime, Color(255,0,0) )
						
					end
					
					return trace
					
				end
				
				-- Create spiral pattern for next iteration
				
				-- Change step direction
				if StepsLeft <= 0 then
        
					if StepDirection == 1 || StepDirection == 3 then
					
						StepSize = StepSize + 1
						
					end
					
					if StepDirection >= 3 then
					
						StepDirection = 0
						
					else
					
						StepDirection = StepDirection + 1
						
					end
					
					StepsLeft = StepSize
					
				end
			
				-- Move based on step direction
				if StepDirection == 0 then
				
					CurrentX = CurrentX + 1
					
				elseif StepDirection == 1 then
				
					CurrentY = CurrentY + 1
					
				elseif StepDirection == 2 then
				
					CurrentX = CurrentX - 1
					
				elseif StepDirection == 3 then
				
					CurrentY = CurrentY - 1
					
				end
				
				-- Count down until direction change
				StepsLeft = StepsLeft - 1
				
			end
			
			return
			
		end
		
	end
	
	return trace
	
end

/*

local function testtrace() 
	
	local ply = player.GetAll()[1]
	local sphere = util.spheretrace( {
		start = ply:EyePos(), 
		endpos = ply:EyePos()+ply:EyeAngles():Forward()*1000,
		mask = MASK_SOLID_BRUSHONLY,
		radius = 200
	}, true, 1.5 )
	
	if sphere and sphere.Hit then
		
		
		
	end
	
end

*/