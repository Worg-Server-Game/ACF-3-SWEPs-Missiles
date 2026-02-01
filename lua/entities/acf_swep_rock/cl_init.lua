include("shared.lua")

local modelexample = ClientsideModel( "models/thrusters/jetpack.mdl" )
modelexample:SetNoDraw( true )

function ENT:Draw()
	self:DrawModel()
end