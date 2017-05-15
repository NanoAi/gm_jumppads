

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
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	if !self.Emitter then return end
	local particle = self.Emitter:Add( "sprites/UT2K4/FlashFlare1", self.pos + VectorRand()*10 )
	if particle then
		particle:SetVelocity(self.angle:Forward()*100)
		particle:SetDieTime( 1 )
		particle:SetStartAlpha( 255 )
		particle:SetStartSize( 3.5 )
		particle:SetEndAlpha( 1 )
		particle:SetEndSize( 2.5 )
		particle:SetColor( self.color[1], self.color[2], self.color[3] )
		//particle:VelocityDecay( false )
		particle:SetAngles( Angle(77,154,45) )
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



