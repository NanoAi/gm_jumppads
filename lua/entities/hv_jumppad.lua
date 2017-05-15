
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "JumpPad"
ENT.Author			= "HighVoltage"
ENT.Contact			= ""
ENT.Purpose			= "To help you get to that spot you can't reach"
ENT.Instructions	= "Where ever you spawn the jumppad will be the destination you will be launched to. Right click on the entity in the context menu to edit its properties"
ENT.Category		= "HighVoltage"

ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.Editable			= true
 
function ENT:Initialize()
	if ( CLIENT ) then 
		hook.Add("PostDrawTranslucentRenderables", self, function()
			local ply = LocalPlayer()
		--	if (ply:Alive()) and (ply:GetActiveWeapon()) and (ply:GetActiveWeapon().GetMode) and (ply:GetActiveWeapon():GetMode() == "jumppad") and ply:GetActiveWeapon():GetNWEntity( "CurJumppad" ) != self then
			if self:GetDrawPath() and ply == self:GetPlayer() then
				start = self:GetPos()
				local targetpos = self:GetPos()//Vector(0,0,0)
				local ent = nil
				if self:GetTargetType() == "string" and ents.FindByName(self:GetTargetName())[1] and ents.FindByName(self:GetTargetName())[1]:IsValid() then
					targetpos = ents.FindByName(self:GetTargetName())[1]:GetPos()
				elseif self:GetTargetType() == "Entity" and IsValid(self:GetTargetEnt()) then
					targetpos = self:GetTargetEnt():GetPos()
					ent = self:GetTargetEnt()
				elseif self:GetTargetType() == "Vector" then
					targetpos = self:GetTargetPos()
				else
					targetpos = self:GetTargetPos()-- There should always be a old targetpos we can revert to
					--ErrorNoHalt('Your trying to set a "'..self:GetTargetType()..'" as the target, instead of a vector, valid entity, or entity name.\n')
				end
				local c = self:GetEffectColor()*255
				local color = Color(c.r,c.g,c.b,255)
				self:DrawJumpPadTarget(start, self:GetHeightAdd(), color, targetpos, Vector(0,0,1), ent)
			end
		end)

	return 
	end
	
	//self:SetModel( self:GetWorldModel() )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetTrigger( true )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
--[[	if !self:CreatedByMap() then
		self:SetTargetPos(self:GetPos())
		self:SetNoFallDamage(false)
	end--]]
	if self:HasSpawnFlags(1) then
		self:SetMoveType( MOVETYPE_NONE )
	end
	self:SetEnabled( !self:HasSpawnFlags(2) )
	
	if WireLib and WireLib.CreateInputs then	-- safe bet?
		self.Outputs = Wire_CreateOutputs(self, { "Out" })
		self.Inputs = WireLib.CreateSpecialInputs(self, {"Red", 	"Green", 	"Blue", 	"RGB", 	"Height_Add", 	"NoFallDmg", "Sound", "On", "Target_Pos", "Target_Ent", "Target_Name"}, 
														{"NORMAL", 	"NORMAL", 	"NORMAL", 	"VECTOR", 	"NORMAL", 	"NORMAL", 	"STRING", "NORMAL", "VECTOR", 	"ENTITY", 	"STRING"})
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float",	0, "HeightAdd", 	{ KeyName = "z_modifier", 		Edit = { type = "Float", 		min = 0, max = 4, order = 1 } }  );
	self:NetworkVar( "Vector",	0, "EffectColor", 	{ KeyName = "effect_col", 		Edit = { type = "VectorColor", 	order = 2 } }  );
	self:NetworkVar( "Bool",	0, "Enabled", 		{ KeyName = "enabled", 			Edit = { type = "Boolean", 		order = 3 } }  );
	self:NetworkVar( "Bool",	1, "NoFallDamage", 	{ KeyName = "nofalldmg", 		Edit = { type = "Boolean", 		order = 4 } }  );
	self:NetworkVar( "Bool",	2, "DrawPath", 		{ KeyName = "drawpath", 		Edit = { type = "Boolean", 		order = 5 } }  );
	self:NetworkVar( "String",	0, "EffectName", 	{ KeyName = "effectname"}  );--, 	Edit = { type = "Generic", 		order = 4 } }  );
--	self:NetworkVar( "String",	0, "WorldModel", 	{ KeyName = "model"}  );--, 	Edit = { type = "Generic", 		order = 4 } }  );
	self:NetworkVar( "Entity",	0, "TargetEnt", 	{ KeyName = "targetent"}  );--, 		Edit = { type = "EntitySelect", order = 5 } }  );
	self:NetworkVar( "String",	1, "TargetName", 	{ KeyName = "target_name", 		Edit = { type = "Generic", 		order = 6 } }  );
	self:NetworkVar( "Vector",	1, "TargetPos", 	{ KeyName = "targetpos", 		Edit = { type = "VectorPos", 	order = 7 } }  );
	self:NetworkVar( "String",	2, "TargetType"  );
	self:NetworkVar( "String",	3, "SoundName", 	{ KeyName = "soundname"}  );--, 	Edit = { type = "Generic", 		order = 4 } }  );
--	self:NetworkVar( "String",	0, "EffectName", 	{ KeyName = "effectname"}  );--, 	Edit = { type = "Generic", 		order = 4 } }  );
	self:NetworkVar( "Int",		0,	"Key" );
	self:NetworkVar( "Entity",	1, "Player"  );

--	self:NetworkVarNotify( "WorldModel",	self.OnModelChanged );
	self:NetworkVarNotify( "TargetEnt",		self.OnTargetChanged );
	self:NetworkVarNotify( "TargetName",	self.OnTargetChanged );
	self:NetworkVarNotify( "TargetPos",		self.OnTargetChanged );
	self:NetworkVarNotify( "Player",	self.OnPlayerChanged );
	
--[[	-- defaults
	self:SetHeightAdd( 1 )
	self:SetEffectColor( Vector(255, 170, 0)/255 )
	self:SetEnabled( true )
--	self:SetWorldModel("models/HighVoltage/UT2K4/PickUps/Jump_pad.mdl")
	self:SetSoundName("HV_Jump_pad_launch.wav")
	self:SetEffectName("hv_jumppadfx")
//	end--]]
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create( ClassName )
	ent:SetModel( "models/HighVoltage/UT2K4/PickUps/Jump_pad.mdl" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:SetPlayer( ply )
	ent:SetKey(0)
	ent:Spawn()
	ent:Activate()
	
	ent:SetTargetPos(ent:GetPos())
	ent:SetNoFallDamage(false)
	ent:SetHeightAdd( 1 )
	ent:SetEffectColor( Vector(255, 170, 0)/255 )
	ent:SetEnabled( true )
--	ent:SetWorldModel("models/HighVoltage/UT2K4/PickUps/Jump_pad.mdl")
	ent:SetSoundName("HV_Jump_pad_launch.wav")
	ent:SetEffectName("hv_jumppadfx")
	
	ply:AddCleanup( "jumppads", ent )
	
	return ent
	
end

function ENT:OnPlayerChanged(var,old,new)
	self:SetVar( "FounderIndex", new:UniqueID() )
	self:SetNetworkedString( "FounderName", new:Nick() )
end
--[[
function ENT:OnModelChanged(var,old,new)
	if SERVER then
		self:SetModel( self:GetWorldModel() )
		self:PhysicsInit( SOLID_VPHYSICS )
	end
end--]]
-- The most recently changed target type becomes the target
function ENT:OnTargetChanged(var,old,new)
	local _type = type(new)
	if _type == "Player" or _type == "Vehicle" or _type == "Weapon" or _type == "NPC" then _type = "Entity" end
	self:SetTargetType(_type)
end

function ENT:Think()
	if ( CLIENT ) then return end
	if self.LastLaunch and CurTime() > self.LastLaunch + 0.2 then
		self.LastLaunch = nil	-- Should I make this value usable elsewhere and not get rid of it?
		numpad.Deactivate( self:GetPlayer(), self:GetKey(), true )
	end
	self.LastEffect = self.LastEffect or 0
	if CurTime() > self.LastEffect then
		self.LastEffect = CurTime() + 0.1
		if !self:GetEnabled() then return end		// Don't do anything if turned off
		local targetpos = self:GetPos()//Vector(0,0,0)
		if self:GetTargetType() == "string" and ents.FindByName(self:GetTargetName())[1] and ents.FindByName(self:GetTargetName())[1]:IsValid() then
			targetpos = ents.FindByName(self:GetTargetName())[1]:GetPos()
		elseif self:GetTargetType() == "Entity" and IsValid(self:GetTargetEnt()) then
			targetpos = self:GetTargetEnt():GetPos()
		elseif self:GetTargetType() == "Vector" then
			targetpos = self:GetTargetPos()
		else
			targetpos = self:GetTargetPos()-- There should always be a old targetpos we can revert to
			--ErrorNoHalt('Your trying to set a "'..self:GetTargetType()..'" as the target, instead of a vector, valid entity, or entity name.\n')
		end
		local col = self:GetEffectColor()
		--debugoverlay.Cross( targetpos, 4, 0.22, Color(col.r,col.g,col.b), true )
		debugoverlay.Cross( targetpos, 8, 0.22, Color(0,255,0), true )
		
		local ang = self:getvel(targetpos, self:GetPos(), self:GetHeightAdd()):Angle()
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( self:getvel(targetpos, self:GetPos(), self:GetHeightAdd()) )
		effectdata:SetEntity( self )
		--effectdata:SetNormal( col )
		util.Effect( self:GetEffectName(), effectdata ) --"hv_jumppadfx"
	end
end

--Below function credited to CmdrMatthew
function ENT:getvel(pos, pos2, time)	-- target, starting point, time to get there
    local diff = pos - pos2 --subtract the vectors
     
    local velx = diff.x/time -- x velocity
    local vely = diff.y/time -- y velocity
 
    local velz = (diff.z - 0.5*(-GetConVarNumber( "sv_gravity"))*(time^2))/time --  x = x0 + vt + 0.5at^2 conversion
     
    return Vector(velx, vely, velz)
end	
	
function ENT:LaunchArc(pos, pos2, time, t)	-- target, starting point, time to get there, fraction of jump
	local v = self:getvel(pos, pos2, time).z
	local a = (-GetConVarNumber( "sv_gravity"))
	local z = v*t + 0.5*a*t^2
	local diff = pos - pos2
	local x = diff.x*(t/time)
    local y = diff.y*(t/time)
	
	return pos2 + Vector(x, y, z)
end

hook.Add("GetFallDamage", "hv_jumppad", function(target)
	if target.hv_jumppad_launch or target.hv_jumppad_ignorefalldamage then
		return 0
	end
end)

hook.Add("Move", "hv_jumppad", function(ply, data)
	if ply.hv_jumppad_ignorefalldamage then
		local plyOnGround = ply:OnGround()
		if data:GetVelocity().z < -600 and not plyOnGround then
			ply.hv_jumppad_ignorefalldamage = nil
			ply:Fire("ignorefalldamage","",0)
		elseif ply.hv_jumppad_ignorefalldamage < CurTime() and plyOnGround then
			ply.hv_jumppad_ignorefalldamage = nil
		end
	end
end)

function ENT:StartTouch( entity )

	if !self:GetEnabled() then return end		// Don't do anything if turned off
	
	if ( entity:IsValid() ) then//and entity:IsPlayer() ) then

		local targetpos = Vector(0,0,0)
		if self:GetTargetType() == "string" and ents.FindByName(self:GetTargetName())[1]:IsValid() then
			targetpos = ents.FindByName(self:GetTargetName())[1]:GetPos()
		elseif self:GetTargetType() == "Entity" and IsValid(self:GetTargetEnt()) then
			targetpos = self:GetTargetEnt():GetPos()
		elseif self:GetTargetType() == "Vector" then
			targetpos = self:GetTargetPos()
		else
			targetpos = self:GetTargetPos()	-- There should always be a old targetpos we can revert to
			--ErrorNoHalt('Your trying to set a "'..self:GetTargetType()..'" as the target, instead of a vector, valid entity, or entity name.\n')
		end
		
		local entphys = entity:GetPhysicsObject();
		if !entity:IsPlayer() and !entity:IsNPC() and entphys:IsValid() then
			entphys:SetVelocity(self:getvel(targetpos, entity:GetPos(), self:GetHeightAdd()))
		else
			if entity:IsPlayer() then
				if self:GetNoFallDamage() then
					entity.hv_jumppad_ignorefalldamage = CurTime()+1
				end

				entity.hv_jumppad_launch = true

				timer.Simple(0, function()
					if IsValid(entity) and entity.hv_jumppad_launch then 
						entity.hv_jumppad_launch = nil
					end 
				end)
			end
			entity:SetLocalVelocity(self:getvel(targetpos, entity:GetPos(), self:GetHeightAdd()))
//			entity:SetLocalVelocity(self:getvel(self.target:GetPos(), entity:GetPos(), self.HightAdd))
		end

		self:EmitSound( self:GetSoundName() )	--"HV_Jump_pad_launch.wav" )
		self:TriggerOutput("OnLaunch", self)
		numpad.Activate( self:GetPlayer(), self:GetKey(), true )

		self.LastLaunch = CurTime()
		if WireLib then	-- safe bet?
			Wire_TriggerOutput(self, "Out", 1)
		end
	end
end

-- Key values for map entities, leaving it here in case someone wants to map with this
function ENT:KeyValue( key, value )
//	print(bit.band(31,1),bit.band(31,2),bit.band(31,4),bit.band(31,8),bit.band(31,16))
	if ( string.Left( key, 2 ) == "On" ) then
		self:StoreOutput( key, value )
	end
	if ( key == "angles" ) then
		local Sep = string.Explode(" ", value)
		local ang = (Angle(Sep[1], Sep[2], Sep[3]))
		self.angle = ang
	end	
	if ( key == "target" ) then
		self:SetTargetName(value)	-- Support for any map using the old way
	end	
	if ( key == "z_modifier" ) then	-- NetworkVar keyvalues now working?
		self:SetHeightAdd(value)	
	end	
	if ( key == "effect_col" ) then
		local Sep = string.Explode(" ", value)
		local Col = (Vector(Sep[1], Sep[2], Sep[3]))
		self:SetEffectColor(Col)
	end	
	if ( key == "enabled" ) then
		self:SetEnabled(value)
	end	
	if ( key == "model" ) then
		self:SetModel(value)	
	end	
	if ( key == "target_name" ) then
		self:SetTargetName(value)	
	end	
//	if ( key == "spawnflags" ) then
//		if value == "1" then
//			self.Frozen = true
//		end
//	end	
end

-- Inputs for map entities, leaving it here in case someone wants to map with this
function ENT:AcceptInput( inputName, activator, called, data )

	if ( inputName == "ChangeTarget" ) then
		self:SetTargetName(data)
	end	
	if ( inputName == "ChangeZMod" ) then
		self:SetHeightAdd(tonumber(data))
	end	
	if ( inputName == "TurnOn" ) then
		self:SetEnabled( true )
	end	
	if ( inputName == "TurnOff" ) then
		self:SetEnabled( false )
	end	
end

-- Wiremod crap
function ENT:TriggerInput(iname, value)
	if (iname == "Red") then
		local Col = self:GetEffectColor()
		Col.r = math.Clamp(value,0,255)
		self:SetEffectColor(Col)
	elseif (iname == "Green") then
		local Col = self:GetEffectColor()
		Col.g = math.Clamp(value,0,255)
		self:SetEffectColor(Col)
	elseif (iname == "Blue") then
		local Col = self:GetEffectColor()
		Col.b = math.Clamp(value,0,255)
		self:SetEffectColor(Col)
	elseif (iname == "RGB") then
		self:SetEffectColor( Vector( math.Clamp(value[1],0,255), math.Clamp(value[2],0,255), math.Clamp(value[3],0,255) )/255 )
	elseif (iname == "Height_Add") then
		self:SetHeightAdd(value)	
	elseif (iname == "NoFallDmg") then
		self:SetNoFallDamage(tobool(value))	
	elseif (iname == "Sound") then
		self:SetSoundName(value)	
	elseif (iname == "On") then
		self:SetEnabled(tobool(value))	
	elseif (iname == "Target_Pos") then
		self:SetTargetPos(value)	
	elseif (iname == "Target_Ent") then
		self:SetTargetEnt(value)	
	elseif (iname == "Target_Name") then
		self:SetTargetName(value)	
	end
end
--[[
-- Random crap for the toolgun
function ENT:SetPlayer( ply )
	if ( IsValid(ply) ) then
		self:SetVar( "Founder", ply )
		self:SetVar( "FounderIndex", ply:UniqueID() )
	
		self:SetNetworkedString( "FounderName", ply:Nick() )
	end
end

function ENT:GetPlayer()
	return self:GetVar( "Founder", NULL )
end--]]

function ENT:GetPlayerIndex()
	return self:GetVar( "FounderIndex", 0 )
end

function ENT:GetPlayerName()
	local ply = self:GetPlayer()
	if ( IsValid( ply ) ) then
		return ply:Nick()
	end
	return self:GetNetworkedString( "FounderName" )
end

if SERVER then return end

local mat = Material( "vgui/circle" )
local mat2 = Material( "sprites/ut2k4/flashflare1" )

local function tehcol(num,col)
	return num == 1 and Color( 240, 240, 240 ) or col
end

function ENT:DrawJumpPadTarget(start, height, color, target, normal, ent)
	local size = (math.sin(CurTime()*3)*8)+32
	--render.SetColorMaterial()
	--render.DrawLine( start, target + normal, color, true )

	local segs = math.Clamp( math.Round(target:Distance(start)/40), 8, 80)
	local count = 0
	local scroll = (CurTime() * -4)
	--render.SetColorMaterial()	-- rope or trail material
	render.SetMaterial(mat2)
	render.StartBeam( segs + 2 )
	render.AddBeam( start, 3, scroll, tehcol(count%2,color) )
	local lastpos = start
	for i = 0, segs, 1 do
		count = count + 1
		local frac = i/segs
		local pos = self:LaunchArc(target, start, height, height*frac)
		scroll = scroll + (lastpos:Distance(pos))/12
		lastpos = pos
		render.AddBeam( pos, 9, scroll, tehcol(count%2,color) )
		if i == segs - 1 then
			local v = target - pos
			local v2 = v:GetNormal()
			local a = v2:Angle()
			local tr = util.QuickTrace( pos, v2*(pos:Distance(target) +2), LocalPlayer() )
			normal = tr.Hit and tr.HitNormal or v:GetNormal()*-1
		end
	end
	count = count + 1
	scroll = scroll + (lastpos:Distance(target))/12
	render.AddBeam( target, 1, scroll, tehcol(count%2,color) )
	render.EndBeam()
	if ent then
		local s = (math.sin(CurTime()*3)*3)+4
		halo.Add( {ent}, color, s, s, 2 )
	else
		render.SetMaterial(mat)
		--render.DrawSphere( trace.HitPos, 10, 20, 20, Color(170,255,0,255) )
		render.DrawQuadEasy( target + normal, normal, size, size, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/1.35, size/1.35, color, ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/2, size/2, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/3.5, size/3.5, color, ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/8, size/8, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
	end
end
