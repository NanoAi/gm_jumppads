
TOOL.Category = "HighVoltage"
TOOL.Name = "Jumppad spawner"

TOOL.ClientConVar[ "model" ] = "models/HighVoltage/UT2K4/PickUps/Jump_pad.mdl"
TOOL.ClientConVar[ "keygroup" ] = 0
TOOL.ClientConVar[ "keygroup2" ] = 0
TOOL.ClientConVar[ "hightadd" ] = 1
TOOL.ClientConVar[ "r" ] = 255
TOOL.ClientConVar[ "g" ] = 170
TOOL.ClientConVar[ "b" ] = 0
TOOL.ClientConVar[ "a" ] = 255
TOOL.ClientConVar[ "nofalldamage" ] = "0"
TOOL.ClientConVar[ "enabled" ] = "1"
TOOL.ClientConVar[ "updatepos" ] = "0"
TOOL.ClientConVar[ "soundname" ] = "HV_Jump_pad_launch.wav"
TOOL.ClientConVar[ "effect" ] = "hv_jumppadfx"
CreateConVar("sbox_maxjumppads", "10", FCVAR_ARCHIVE, "Maximum jumppads a single player can create. Warning!: Too many jumppads can cause emitter errors")

if CLIENT then
	language.Add( "tool.jumppad.name", "Jumppad spawner" )
	language.Add( "tool.jumppad.0", "Left click to spawn, right click to spawn it welded." )
	language.Add( "tool.jumppad.1", "Left click to set the landing position, right click to set an entity as landing position." )
	language.Add( "tool.jumppad.desc", "Spawn jumppads and then set their landing position" )
	language.Add( "tool.jumppad.hightadd", "Extra height" )
	language.Add( "tool.jumppad.hightadd.help", "This is roughly the time you are in the air before hitting the target." )
	language.Add( "tool.jumppad.color", "The color of the effect" )
	language.Add( "tool.jumppad.falldmg", "Disable fall damage." )
	language.Add( "tool.jumppad.falldmg.help", "This prevents the next fall damage on the player, even if they land without damage." )
	language.Add( "tool.jumppad.enabled", "Start enabled" )
	language.Add( "tool.jumppad.enabled.help", "Jumpads can be toggled from the context menu or by keypress" )
	language.Add( "tool.jumppad.key", "Toggle key" )
	language.Add( "tool.jumppad.key2", "Trigger key" )
	language.Add( "tool.jumppad.key.help", "Toggle key will turn the jumppad on or off." )
	language.Add( "tool.jumppad.key2.help", "Trigger key will act like a button when something is launched." )
	language.Add( "tool.jumppad.model", "Jumppad model" )
	language.Add( "tool.jumppad.effect", "Effect" )
	language.Add( "tool.jumppad.updatepos", "Update position" )
	language.Add( "tool.jumppad.updatepos.help", "Should the tool allow you to change the landing position when you select an existing jumppad." )
	
	language.Add( "Cleaned_Jumppads", "Cleaned up all Jumppads" )
	language.Add( "Cleanup_Jumppads", "Jumppads" )
	language.Add( "Undone_Jumppad", " Undone Jumppad" )
	language.Add( "SBoxLimit_Jumppads", "You've hit the Jumppads limit" )
	language.Add( "max_jumppads", "Max Jumppads" )
	
	language.Add( "jumppad_off", "Disable Jumppad" )
	language.Add( "jumppad_on", "Enable Jumppad" )
	language.Add( "jumppad_hidepath", "Hide launch path" )
	language.Add( "jumppad_showpath", "Show launch path" )
	
	language.Add( "jumppadsounds.default", "Default" )
	language.Add( "jumppadsounds.nothing", "Nothing" )
	language.Add( "jumppadsounds.gunship", "Gunship" )
	language.Add( "jumppadsounds.cannisterlaunch", "Cannister launch" )
	language.Add( "jumppadsounds.combinemine", "Combine mine" )
	language.Add( "jumppadsounds.rolermine", "Rolermine" )
	language.Add( "jumppadsounds.striderfire", "Strider fire" )
	language.Add( "jumppadsounds.airboatenergy", "Airboat energy" )
	language.Add( "jumppadsounds.ar2altfire", "AR2 alt fire" )
	language.Add( "jumppadsounds.crossbow", "Crossbow" )
	language.Add( "jumppadsounds.physcannon", "PhysCannon" )
	
	language.Add( "jumppadeffects.dots", "Default" )
	language.Add( "jumppadeffects.streaks", "Streaks" )
	language.Add( "jumppadeffects.bubbles", "Bubbly" )
end

cleanup.Register( "jumppads" )

function TOOL:LeftClick( trace )
	
	if self:GetStage() == 0 then
		if ( IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
		if ( CLIENT ) then return true end
		if ( !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
		
		local ply = self:GetOwner()
		
		local model = 		self:GetClientInfo( "model" )
		local key = 		self:GetClientNumber( "keygroup" )
		local key2 = 		self:GetClientNumber( "keygroup2" )
		local hightadd = 	self:GetClientNumber( "hightadd" )
		local r = 			self:GetClientNumber( "r" ) 
		local g = 			self:GetClientNumber( "g" )
		local b = 			self:GetClientNumber( "b" )
		local a = 			self:GetClientNumber( "a" )
		local color = Vector(r,g,b)/255
		local nofalldmg =self:GetClientNumber( "nofalldamage" ) == 1
		local enabled = 	self:GetClientNumber( "enabled" )	== 1
		local updatepos = 	self:GetClientNumber( "updatepos" )	== 1
		local soundname  = 	self:GetClientInfo( "soundname" )
		local effectname  = 	self:GetClientInfo( "effect" )
		
		-- If we shot a jumppad change its shit
		if ( IsValid( trace.Entity ) and trace.Entity:GetClass() == "hv_jumppad" && trace.Entity:GetPlayer() == ply ) then
			
			numpad.Remove( trace.Entity.NumDown )
			if key != 0 then
				trace.Entity.NumDown = numpad.OnDown( ply, key, "JumpToggle", jumppad )
			end
			trace.Entity:SetKey(key2)
			trace.Entity:SetHeightAdd( hightadd )
			trace.Entity:SetEnabled( enabled )
			trace.Entity:SetNoFallDamage( nofalldmg )
			trace.Entity:SetEffectColor( color )
			trace.Entity:SetSoundName(soundname)
			trace.Entity:SetEffectName(effectname)
			
			if updatepos then
--				self.CurJumppad = trace.Entity
				self.Weapon:SetNWEntity( "CurJumppad", trace.Entity )
				self:SetStage(1)
			end
			return true, NULL, true
			
		end
		
		if ( !self:GetSWEP():CheckLimit( "jumppads" ) ) then return false end

		if ( !util.IsValidModel( model ) ) then return false end
		if ( !util.IsValidProp( model ) ) then return false end

		local Ang = trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90

		local jumppad = MakeJumppad( ply, model, Ang, trace.HitPos, key, key2, hightadd, enabled, nofalldmg, color, soundname, effectname )
		
		local min = jumppad:GetCollisionBounds()
		jumppad:SetPos( trace.HitPos - trace.HitNormal * min.z )

		undo.Create( "Jumppad" )
			undo.AddEntity( jumppad )
			undo.SetPlayer( ply )
		undo.Finish()

		ply:AddCleanup( "jumppads", jumppad )
		
--		self.CurJumppad = jumppad
		self.Weapon:SetNWEntity( "CurJumppad", jumppad )
		self:SetStage(1)
		return true, jumppad
	else
		self:SetStage(0)
		if !IsValid(self.Weapon:GetNWEntity( "CurJumppad" )) then return false end
--		self.CurJumppad:SetTargetPos(trace.HitPos)
--		self.CurJumppad = nil
		self.Weapon:GetNWEntity( "CurJumppad" ):SetTargetPos(trace.HitPos)
		self.Weapon:SetNWEntity( "CurJumppad", nil )
		return true
	end

end

function TOOL:RightClick( trace )
	if self:GetStage() == 0 then
		local bool, jumppad, set_key = self:LeftClick( trace, true )
		if ( CLIENT ) then return bool end

		if ( set_key ) then return true end
		if ( !IsValid( jumppad ) ) then return false end
		if ( !IsValid( trace.Entity ) && !trace.Entity:IsWorld() ) then return false end

		local weld = constraint.Weld( jumppad, trace.Entity, 0, trace.PhysicsBone, 0, 0, true )
		trace.Entity:DeleteOnRemove( weld )
		jumppad:DeleteOnRemove( weld )

	//	jumppad:GetPhysicsObject():EnableCollisions( false )
	//	jumppad.nocollide = true
		
		return true
	else
		self:SetStage(0)
		if !IsValid(self.Weapon:GetNWEntity( "CurJumppad" )) then return false end
		if IsValid( trace.Entity ) and !trace.Entity:IsWorld() then
--			self.CurJumppad:SetTargetEnt(trace.Entity)
			self.Weapon:GetNWEntity( "CurJumppad" ):SetTargetEnt(trace.Entity)
		else
--			self.CurJumppad:SetTargetPos(trace.HitPos)
			self.Weapon:GetNWEntity( "CurJumppad" ):SetTargetPos(trace.HitPos)
		end
--		self.CurJumppad = nil
		self.Weapon:SetNWEntity( "CurJumppad", nil )
		return true
	end
end

---[[
if ( CLIENT ) then 
	local mat = Material( "vgui/circle" )
	local mat2 = Material( "sprites/ut2k4/flashflare1" )
	local col = Color( 255, 170, 0, 255 )
	local height = 1
	local getcol = CurTime() + .1


	local function getvel(pos, pos2, time)	-- target, starting point, time to get there
		local diff = pos - pos2 --subtract the vectors
		local velx = diff.x/time -- x velocity
		local vely = diff.y/time -- y velocity
		local velz = (diff.z - 0.5*(-GetConVarNumber( "sv_gravity"))*(time^2))/time --  x = x0 + vt + 0.5at^2 conversion
		
		return Vector(velx, vely, velz)
	end	
		
	local function LaunchArc(pos, pos2, time, t)	-- target, starting point, time to get there, fraction of jump
		local v = getvel(pos, pos2, time).z
		local a = (-GetConVarNumber( "sv_gravity"))
		local z = v*t + 0.5*a*t^2
		local diff = pos - pos2
		local x = diff.x*(t/time)
		local y = diff.y*(t/time)
		
		return pos2 + Vector(x, y, z)
	end
	
	local function tehcol(num)
		return num == 1 and Color( 240, 240, 240 ) or col
	end
	
	local function DrawJumpPadTarget(start, height, color, target, normal)
		local size = (math.sin(CurTime()*3)*8)+32
		--render.SetColorMaterial()
		render.SetMaterial(mat)
		--render.DrawSphere( trace.HitPos, 10, 20, 20, Color(170,255,0,255) )
		render.DrawQuadEasy( target + normal, normal, size, size, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/1.35, size/1.35, color, ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/2, size/2, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/3.5, size/3.5, color, ( CurTime() * 50 ) % 360 )
		render.DrawQuadEasy( target + normal, normal, size/8, size/8, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
		
		--render.DrawLine( start, target + normal, color, true )
		local size = 9--(math.sin(CurTime()*3)*4)+12
		local segs = math.Clamp( math.Round(target:Distance(start)/40), 8, 80)
		local count = 0
		local scroll = (CurTime() * -4)
		--render.SetColorMaterial()	-- rope or trail material
		render.SetMaterial(mat2)
		render.StartBeam( segs + 2 )
		render.AddBeam( start, size, scroll, tehcol(count%2) )
		local lastpos = start
		for i = 0, segs, 1 do
			count = count + 1
			local frac = i/segs
			local pos = LaunchArc(target, start, height, height*frac)
			
			local len = lastpos:Distance(pos)/12
			scroll = scroll + len
			lastpos = pos
			render.AddBeam( pos, size, scroll, tehcol(count%2) )
		end
		count = count + 1
		scroll = scroll + (lastpos:Distance(target))/12
		render.AddBeam( target, size, scroll, tehcol(count%2) )
		render.EndBeam()
	end
	
	hook.Add("PostDrawTranslucentRenderables", "DrawJumppadLAndingPos",function()
		local ply = LocalPlayer()
		if (ply:Alive()) and (ply:GetActiveWeapon()) and (ply:GetActiveWeapon().GetMode) and (ply:GetActiveWeapon():GetMode() == "jumppad") and (ply:GetActiveWeapon():GetStage() == 1) then
			if ( getcol < CurTime() ) then
				local tool = 		ply:GetActiveWeapon():GetToolObject()
				local r = 			tool:GetClientNumber( "r" ) 
				local g = 			tool:GetClientNumber( "g" )
				local b = 			tool:GetClientNumber( "b" )
				local a = 			tool:GetClientNumber( "a" )
				height 	= 			tool:GetClientNumber( "hightadd" )
				col = Color(r,g,b,255)
			end
			local jumppad = LocalPlayer():GetActiveWeapon():GetToolObject().Weapon:GetNWEntity( "CurJumppad" )
			if !IsValid(jumppad) then return end
			start = jumppad:GetPos()
			local trace = LocalPlayer():GetEyeTrace()
			DrawJumpPadTarget(start, height, col, trace.HitPos, trace.HitNormal)
			--[[
			local size = (math.sin(CurTime()*3)*8)+32
			--render.SetColorMaterial()
			render.SetMaterial(mat)
			--render.DrawSphere( trace.HitPos, 10, 20, 20, Color(170,255,0,255) )
			render.DrawQuadEasy( trace.HitPos + trace.HitNormal, trace.HitNormal, size, size, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
			render.DrawQuadEasy( trace.HitPos + trace.HitNormal, trace.HitNormal, size/1.35, size/1.35, col, ( CurTime() * 50 ) % 360 )
			render.DrawQuadEasy( trace.HitPos + trace.HitNormal, trace.HitNormal, size/2, size/2, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
			render.DrawQuadEasy( trace.HitPos + trace.HitNormal, trace.HitNormal, size/3.5, size/3.5, col, ( CurTime() * 50 ) % 360 )
			render.DrawQuadEasy( trace.HitPos + trace.HitNormal, trace.HitNormal, size/8, size/8, Color( 240, 240, 240 ), ( CurTime() * 50 ) % 360 )
			
			render.DrawLine( ply:GetActiveWeapon():GetPos(), trace.HitPos + trace.HitNormal, col, true )
			--]]
			
		end
	end) 
end
--]]
if ( SERVER ) then

	function MakeJumppad( ply, model, Ang, Pos, key, key2, z_modifier, enabled, nofalldmg, effect_col, soundname, effectname, targetent, target_name, targetpos, TargetType )

		if ( IsValid( ply ) && !ply:CheckLimit( "jumppads" ) ) then return false end
	
		local jumppad = ents.Create( "hv_jumppad" )
		if ( !IsValid( jumppad ) ) then return false end
		jumppad:SetModel( model )

		jumppad:SetAngles( Ang )
		jumppad:SetPos( Pos )
		jumppad:Spawn()
		jumppad:Activate()
		
		if key != 0 then
			jumppad.NumDown = numpad.OnDown( ply, key, "JumpToggle", jumppad )
		end
		jumppad:SetKey(key2)
		
		-- only set these vars if defined, because the duplicator automaticly copies networkvars
		if ply then
			jumppad:SetPlayer( ply )
		end
		if z_modifier then
			jumppad:SetHeightAdd( z_modifier )
		end
		if enabled then
			jumppad:SetEnabled( enabled )
		end
		if nofalldmg then
			jumppad:SetNoFallDamage( nofalldmg )
		end
		if effect_col then
			jumppad:SetEffectColor( effect_col )
		end
		if soundname then
			jumppad:SetSoundName(soundname)
		end
		if effectname then
			jumppad:SetEffectName(effectname)
		end
		if targetent then
			jumppad:SetTargetEnt(targetent)
		end
		if target_name then
			jumppad:SetTargetName(target_name)
		end
		if targetpos then
			jumppad:SetTargetPos(targetpos)
		end
		if TargetType then
			jumppad:SetTargetType(TargetType)
		end

		local ttable = {
			key	= key,
			key2 = key2,
			ply	= ply
--			hightadd = hightadd,
--			enabled = enabled,
--			nofalldmg = nofalldmg,
--			color = color,
--			soundname = soundname,
--			effectname = effectname
		}

		table.Merge( jumppad:GetTable(), ttable )
		
		if ( IsValid( ply ) ) then
			ply:AddCount( "jumppads", jumppad )
		end
		
		DoPropSpawnedEffect( jumppad )

		return jumppad
		
	end

	--duplicator.RegisterEntityClass( "hv_jumppad", MakeJumppad, "model", "Ang", "Pos", "key", "key2", "hightadd", "enabled", "nofalldmg", "color", "soundname", "effectname" )
	duplicator.RegisterEntityClass( "hv_jumppad", MakeJumppad, "Model", "Ang", "Pos", "key", "key2" )

	local function Toggle( ply, ent, sting )
		
		if type( ent ) == "string" then return false end	-- I don't know why this happens sometimes
		if !IsValid( ent ) then return false end
		
		if ( numpad.FromButton() ) then

			ent:SetEnabled(!ent:GetEnabled())
			return

		end

		return ent:SetEnabled(!ent:GetEnabled())
		
	end
	numpad.Register( "JumpToggle", Toggle )
	
	
	function CC_Jumppad_Randomize( pl, command, arguments )
		
		local m = {}
		for k, v in SortedPairs( list.Get( "JumpPadModels" ) ) do
			table.insert( m, k )
		end
		pl:ConCommand( "jumppad_model "..table.Random(m) )
		
		local col = HSVToColor( math.random(1,360), math.Clamp(math.Rand(0.5,1.5),0.5,1), math.Clamp(math.Rand(0.75,1.5),0.5,1))
		pl:ConCommand( "jumppad_r "..col.r )
		pl:ConCommand( "jumppad_g "..col.g )
		pl:ConCommand( "jumppad_b "..col.b )
		pl:ConCommand( "jumppad_a "..col.a )
		
		local s = {}
		for k, v in SortedPairs( list.Get( "LaunchSounds" ) ) do
			table.insert( s, v.jumppad_soundname )
		end
		pl:ConCommand( "jumppad_soundname "..table.Random(s) )
		
		local e = {}
		for k, v in SortedPairs( list.Get( "JumpPadEffects" ) ) do
			table.insert( e, v.jumppad_effect )
		end
		pl:ConCommand( "jumppad_effect "..table.Random(e) )
		
		pl:ConCommand( "jumppad_hightadd "..math.Rand(0.75,3) )

	end
	
	concommand.Add( "jumppad_randomize", CC_Jumppad_Randomize )
end

function TOOL:UpdateGhostButton( ent, player )

	if ( !IsValid( ent ) ) then return end

	local tr = util.GetPlayerTrace( player )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	
	if ( trace.Entity && trace.Entity:GetClass() == "hv_jumppad" || trace.Entity:IsPlayer() || self:GetStage() == 1 ) then
	
		ent:SetNoDraw( true )
		return
		
	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:GetCollisionBounds()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )

	ent:SetNoDraw( false )

end

function TOOL:Think()

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != self:GetClientInfo( "model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostButton( self.GhostEntity, self:GetOwner() )
	
	if self:GetStage() == 1 and (self.nextjumppadupdate or 0) < CurTime() then
		if CLIENT then
			
		end
		self.nextjumppadupdate = CurTime() + .1
		local jumppad = self.Weapon:GetNWEntity( "CurJumppad" )
		if !IsValid(jumppad) or !jumppad.SetTargetPos then self:SetStage(0) return false end
		jumppad:SetTargetPos(self:GetOwner():GetEyeTrace().HitPos)
		
		local hightadd = 	self:GetClientNumber( "hightadd" )
		local r = 			self:GetClientNumber( "r" ) 
		local g = 			self:GetClientNumber( "g" )
		local b = 			self:GetClientNumber( "b" )
		local a = 			self:GetClientNumber( "a" )
		local color = Vector(r,g,b)/255
		local nofalldmg =self:GetClientNumber( "nofalldamage" ) == 1
		local enabled = 	self:GetClientNumber( "enabled" )	== 1
		local soundname = 	self:GetClientInfo( "soundname" )
		local effectname = 	self:GetClientInfo( "effect" )
		jumppad:SetHeightAdd( hightadd )
		jumppad:SetEnabled( enabled )
		jumppad:SetNoFallDamage( nofalldmg )
		jumppad:SetEffectColor( color )
		jumppad:SetSoundName(soundname)
		jumppad:SetEffectName(effectname)
	end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description	= "#tool.jumppad.desc" } )
	-- presets
	CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "jumppad", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
	-- hightadd
//	CPanel:NumSlider( "#tool.jumppad.hightadd", "jumppad_hightadd", .5, 4, 2 )
	CPanel:AddControl( "Slider", { Label = "#tool.jumppad.hightadd", Command = "jumppad_hightadd", Type = "Float", Min = 0.01, Max = 4, Help = true } )
	-- effect color
	CPanel:AddControl( "Color", { Label = "#tool.jumppad.color", Red = "jumppad_r", Green = "jumppad_g", Blue = "jumppad_b", Alpha = "jumppad_a" } )
	-- start enabled
	CPanel:AddControl( "CheckBox", { Label = "#tool.jumppad.falldmg", Command = "jumppad_nofalldamage", Help = true } )
	-- disable fall damage
	CPanel:AddControl( "CheckBox", { Label = "#tool.jumppad.enabled", Command = "jumppad_enabled", Help = true } )
	-- numpad toggle
--	CPanel:AddControl( "Numpad", { Label = "#tool.jumppad.key", Command = "jumppad_keygroup" } )
	CPanel:AddControl( "Numpad", { Label = "#tool.jumppad.key", Command = "jumppad_keygroup", Label2 = "#tool.jumppad.key2", Command2 = "jumppad_keygroup2" } )
	CPanel:ControlHelp( "#tool.jumppad.key.help" )
	CPanel:ControlHelp( "#tool.jumppad.key2.help" )
	-- model select
	CPanel:AddControl( "PropSelect", { Label = "#tool.jumppad.model", ConVar = "jumppad_model", Height = 2, Models = list.Get( "JumpPadModels" ) } )
	-- launch sound
	CPanel:AddControl( "ComboBox", { Label = "#tool.thruster.sound", Options = list.Get( "LaunchSounds" ) } )
	-- jumppad effect
	CPanel:AddControl( "ComboBox", { Label = "#tool.jumppad.effect", Options = list.Get( "JumpPadEffects" ) } )
	-- update position
	CPanel:AddControl( "CheckBox", { Label = "#tool.jumppad.updatepos", Command = "jumppad_updatepos", Help = true } )
	-- Random settings
	CPanel:AddControl( "Button", { Text = "#tool.faceposer.randomize", Command = "jumppad_randomize" } )
end

list.Set( "JumpPadModels", "models/HighVoltage/UT2K4/PickUps/Jump_pad.mdl", {} )
list.Set( "JumpPadModels", "models/props_junk/sawblade001a.mdl", {} )
list.Set( "JumpPadModels", "models/props_combine/combine_mine01.mdl", {} )
list.Set( "JumpPadModels", "models/hunter/plates/plate1x1.mdl", {} )
list.Set( "JumpPadModels", "models/props_phx/mechanics/medgear.mdl", {} )
list.Set( "JumpPadModels", "models/props_junk/MetalBucket02a.mdl", {} )

list.Set( "LaunchSounds", "#jumppadsounds.default", { jumppad_soundname = "HV_Jump_pad_launch.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.nothing", { jumppad_soundname = "" } )
list.Set( "LaunchSounds", "#jumppadsounds.gunship", { jumppad_soundname = "npc/combine_gunship/attack_start2.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.cannisterlaunch", { jumppad_soundname = "npc/env_headcrabcanister/launch.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.combinemine", { jumppad_soundname = "npc/roller/mine/rmine_blip3.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.rolermine", { jumppad_soundname = "npc/roller/mine/rmine_explode_shock1.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.striderfire", { jumppad_soundname = "npc/strider/fire.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.airboatenergy", { jumppad_soundname = "Airboat.FireGunHeavy" } )
list.Set( "LaunchSounds", "#jumppadsounds.ar2altfire", { jumppad_soundname = "weapons/ar2/npc_ar2_altfire.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.crossbow", { jumppad_soundname = "weapons/crossbow/fire1.wav" } )
list.Set( "LaunchSounds", "#jumppadsounds.physcannon", { jumppad_soundname = "Weapon_PhysCannon.Launch" } )

list.Set( "JumpPadEffects", "#jumppadeffects.dots", { jumppad_effect = "hv_jumppadfx" } )
list.Set( "JumpPadEffects", "#jumppadeffects.streaks", { jumppad_effect = "hv_jumppadfx2" } )
list.Set( "JumpPadEffects", "#jumppadeffects.bubbles", { jumppad_effect = "hv_jumppadfx3" } )

properties.Add( "jumppad_off", {
	MenuLabel = "#jumppad_off",
	Order = 5500,
	MenuIcon = "icon16/cross.png",
	
	Filter = function( self, ent, ply ) 
		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "hv_jumppad" ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "Jumppad", ent ) ) then return false end

		return ent:GetEnabled() 

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
		
	end,

	Receive = function( self, length, player )
	
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

		ent:SetEnabled( false )

	end	

} )

properties.Add( "jumppad_on", {
	MenuLabel = "#jumppad_on",
	Order = 5500,
	MenuIcon = "icon16/accept.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "hv_jumppad" ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "Jumppad", ent ) ) then return false end

		return !ent:GetEnabled() 

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
		
	end,

	Receive = function( self, length, player )
	
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

		ent:SetEnabled( true )

	end	

} )

properties.Add( "jumppad_hidepath", {
	MenuLabel = "#jumppad_hidepath",
	Order = 5501,
	MenuIcon = "icon16/chart_curve_delete.png",
	
	Filter = function( self, ent, ply ) 
		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "hv_jumppad" ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "Jumppad", ent ) ) then return false end

		return ent:GetDrawPath() 

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
		
	end,

	Receive = function( self, length, player )
	
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

		ent:SetDrawPath( false )

	end	

} )

properties.Add( "jumppad_showpath", {
	MenuLabel = "#jumppad_showpath",
	Order = 5501,
	MenuIcon = "icon16/chart_curve_add.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "hv_jumppad" ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "Jumppad", ent ) ) then return false end

		return !ent:GetDrawPath() 

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
		
	end,

	Receive = function( self, length, player )
	
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

		ent:SetDrawPath( true )

	end	

} )

