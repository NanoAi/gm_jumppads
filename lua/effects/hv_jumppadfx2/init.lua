

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
	self.gravity = -GetConVarNumber( "sv_gravity")
	self.pDieTime = self.velocity:Length()/1000
	
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
		local particle = self.Emitter:Add( "sprites/UT2K4/FlashFlare1", self.pos - (self.velocity:GetNormal()*20) + Vector(math.Rand(-10,10), math.Rand(-10,10),math.Rand(-10,10)))--VectorRand()*10 )
		if particle then
			particle:SetVelocity(self.velocity/80)
			particle.velocity = self.velocity/1
		--	particle:SetGravity( Vector(0,0,self.gravity*0) )
			particle.g = self.gravity/(self.pDieTime<1 and (self.pDieTime*8) or 1)
			particle:SetStartLength( 30 )
--			particle:SetAirResistance(-50)
			particle:SetStartLength( 100 )
			particle:SetDieTime( math.Clamp(self.pDieTime,1,1.6) )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 5 )
			particle:SetEndAlpha( 1 )
			particle:SetEndSize( 1 )
			particle:SetNextThink( CurTime() ) -- Makes sure the think hook is used on all particles of the particle emitter
			particle:SetThinkFunction( function( pa )
				local frac = pa:GetLifeTime()/pa:GetDieTime()
			--	MsgN(Lerp(frac,0,pa.g))
				--pa:SetVelocity(pa.velocity/Lerp(frac,4,1))
				//pa:SetGravity(Vector(0,0,Lerp(frac-1,pa.g,0))) --
				pa:SetGravity(Vector(pa.velocity.x,pa.velocity.y,Lerp(frac,pa.velocity.z,pa.g))) --
--				pa:SetColor( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) ) -- Randomize it
				pa:SetNextThink( CurTime() ) -- Makes sure the think hook is actually ran.
			end )
			particle:SetColor( self.color[1], self.color[2], self.color[3] )
			//particle:VelocityDecay( false )
			particle:SetAngles( Angle(77,154,45) )
		end
		self.nextthink = CurTime()+0.05
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



