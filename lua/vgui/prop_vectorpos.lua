
--
-- prop_generic is the base for all other properties. 
-- All the business should be done in :Setup using inline functions.
-- So when you derive from this class - you should ideally only override Setup.
--

local PANEL = {}

function PANEL:Init()


end


function PANEL:Setup( vars )

	self:Clear()
	
	local btn2 = self:Add( "DButton" )
	btn2:SetText( "    Cursor pos    " )
	btn2:SizeToContents()
	btn2:Dock( RIGHT )
	
	local btn1 = self:Add( "DButton" )
	btn1:SetText( "    Players pos    " )
	btn1:SizeToContents()
	btn1:Dock( RIGHT )
	
---[[	
	local lbl = self:Add( "DTextEntry" )
	lbl:SetUpdateOnType( true )
	lbl:SetDrawBackground( false )
	lbl:Dock( FILL )
--]]
	-- Return true if we're editing
	-- I'm return true at all times so the position will update when we press the buttons
	self.IsEditing = function( self )
		return true --lbl:IsEditing()
	end
	
	-- Set the value
	self.SetValue = function( self, val )
		lbl:SetText( tostring(val) )
	end

	-- Alert row that value changed
	btn1.DoClick = function()
		self:ValueChanged( tostring(LocalPlayer():GetPos()) )
		lbl:SetText( tostring(LocalPlayer():GetPos()) )
	end
	
	btn2.DoClick = function()
		self:ValueChanged( tostring(LocalPlayer():GetEyeTraceNoCursor().HitPos ))
		lbl:SetText( tostring(LocalPlayer():GetEyeTraceNoCursor().HitPos) )
	end
	
	-- Alert row that value changed
	lbl.OnValueChange = function( lbl, newval )
			
		self:ValueChanged( newval )

	end

end

derma.DefineControl( "DProperty_VectorPos", "", PANEL, "DProperty_Generic" )