AddCSLuaFile()

SWEP.Base                   = "weapon_base"
SWEP.PrintName              = "Rock."
SWEP.Category               = "Other"

SWEP.IconOffset				= Vector(4,4,0)
SWEP.IconAngOffset			= Angle(0,180,0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/v_grenade.mdl"
SWEP.ViewModelFlip          = false

SWEP.WorldModel             = "models/props_foliage/rock_forest01d.mdl"
SWEP.HoldType               = "grenade"

SWEP.Weight                 = 1

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.UseHands				= true
SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "none"

SWEP.Charging 				= false
SWEP.LastCharging 			= false
SWEP.chargelevel 			= -2
SWEP.Ready 		 			= true

function SWEP:PrimaryAttack()
	if not self.Ready then return end
	self.Charging = true

	if self.chargelevel < 30 then
		self.chargelevel = self.chargelevel + 0.25 * math.sin( self.chargelevel / 7 ) + 0.25
	elseif self.chargelevel < 35 then
		self.chargelevel = self.chargelevel + 0.02
	elseif self.chargelevel < 40 then
		self.chargelevel = self.chargelevel - 3 * math.sin( self.chargelevel / 6.4 )
	end
end

function SWEP:Reload()
	return false
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Think()
	if not self.Charging and self.LastCharging then
		if SERVER then
			MakeACF_Rock(self:GetOwner(), math.max(self.chargelevel, 1))
		end
		self.LastCharging = false
		self.chargelevel = -2
		self.Ready = false
		timer.Simple(0.25, function()
			self.Ready = true
		end)
	end

	if self.Charging then
		self.Charging = false
		self.LastCharging = true
	end
end

if CLIENT then
	function SWEP:DoDrawCrosshair(x,y)
		local width  = 150
		local height = 25

		local chargelevel = self.chargelevel
		local shake = 0

		if chargelevel > 32 then
			shake = 1
		end
		if chargelevel > 34 then
			shake = 2
		end
		if chargelevel > 35 then
			shake = 5
		end
		if chargelevel > 36 then
			shake = 2
		end

		shakex = math.random(-shake, shake)
		shakey = math.random(-shake / 2, shake / 2)

		if chargelevel < 34 then
			surface.SetDrawColor(255, 255, 255)
		else
			surface.SetDrawColor(255, 25, 25)
		end
		surface.DrawOutlinedRect(x - width / 2 + shakex, y + 45 + shakey, width, height, 1)

		local percentage

		if chargelevel < 34 then
			percentage = math.min(chargelevel / 30, 1)
			surface.SetDrawColor(150, 150, 150)
		else
			percentage = math.max((chargelevel - 5) / 30, 1)
			surface.SetDrawColor(255, 120, 120)
		end

		surface.DrawRect(x - width / 2 + 1 + shakex, y + 45 + 1 + shakey, width * percentage - 2, height - 2)

		return false
	end
end

--[[
if CLIENT then
	local RockScaling = ClientsideModel( "models/props_foliage/rock_forest01d.mdl" )
	RockScaling:SetNoDraw(true)

	function SWEP:Draw()
		if self:GetOwner():GetActiveWeapon() != self then return end

		if LocalPlayer() == self:GetOwner() then
			RockScaling:SetPos(self:GetOwner():GetAttachment( 11 ):GetPos())
			RockScaling:Draw()
			RockScaling:SetScale( self.chargelevel )
		end
	end
end
]]