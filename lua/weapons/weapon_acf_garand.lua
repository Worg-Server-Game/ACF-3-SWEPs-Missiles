AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Garand"

SWEP.IconOffset				= Vector(-16,0,0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/garand/v_garand.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Garand.Shoot")
SWEP.WorldModel             = "models/weapons/garand/w_garand.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 8
SWEP.Primary.DefaultClip    = 8
SWEP.Primary.Ammo           = "357"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2

SWEP.Caliber                = 7.62 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.01 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 850 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-6.95,-2,5.1)
--SWEP.IronSightAng           = Angle()
SWEP.UseHands				= false

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0,0,1.5)
SWEP.OffsetWorldModelAng	= Angle(10,0,180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3
SWEP.Handling				= 1.5

SWEP:SetupACFBullet()

local Ping = Sound("Weapon_Garand.ClipDing")

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()

	if Ply:IsPlayer() then Ply:LagCompensation(true) end
	local AimMod = self:GetAimMod()
	local Punch = self:GetPunch()

	if SERVER then
		local Aim = self:GetForward()
		local Right = self:GetRight()
		local Up = self:GetUp()
		if Ply:IsNPC() then Aim = Ply:GetAimVector() end

		local Cone = math.tan(math.rad(self.Spread * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim + Spread):GetNormalized()

		self:ShootBullet(Ply:GetShootPos(),Dir)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	if self:Clip1() == 0 then self:EmitSound(Ping) end

	if Ply:IsPlayer() then Ply:LagCompensation(false) end
end
