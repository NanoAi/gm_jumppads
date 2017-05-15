

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.pos = data:GetOrigin()
	self.velocity = data:GetStart()
	self.angle = self.velocity:Angle()-- data:GetAngles()
	self.jumppad = data:GetEntity()
	self.color = self.jumppad:GetEffectColor()*255 or Vector(255, 170, 0)
		
	self.Emitter = ParticleEmitter(self.pos)	
	self.DieTime = CurTime() + 0.3
	
	debugoverlay.Line( self.pos, self.pos+self.angle:Forward()*100, 0.22, Color(255,0,0), true )
	debugoverlay.Cross( self.pos+self.angle:Forward()*100, 4, 0.22, Color(0,255,0), true )
	self.nextthink = CurTime()
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	if !self.Emitter then return end
	if self.nextthink < CurTime() then
		local particle = self.Emitter:Add( "effects/bubble", self.pos + VectorRand()*10 )
		local speed = self.velocity:Length()
		if particle then
			particle:SetVelocity(self.velocity/4)
			particle:SetGravity( Vector(0,0,-GetConVarNumber( "sv_gravity")/16) )
			particle:SetDieTime( 2 )
			particle:SetStartAlpha( 200 )
			particle:SetStartSize( 7 )
			particle:SetEndAlpha( 1 )
			particle:SetEndSize( 2.5 )
			particle:SetColor( self.color[1], self.color[2], self.color[3] )
			//particle:VelocityDecay( false )
			particle:SetAngles( Angle(77,154,45) )
			particle:SetAngleVelocity( AngleRand()*3 )
		end
		self.nextthink = CurTime()+Lerp(math.Clamp((speed-400)/4000,0,1),0.08,0.01)--0.08
	end
	if self.DieTime > CurTime() then
		return true
	else
		self.Emitter:Finish()
		return false
	end
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()	
end



