AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF MP5"



SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound("Weapon_MP5Navy.Single")
SWEP.WorldModel             = "models/weapons/w_smg_mp5.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 2
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.3
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "Pistol"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.075
SWEP.FiremodeSetting		= 2

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 9 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.00814 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-5.34,-6,1.91)
SWEP.IronSightAng           = Angle(1,0,0)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3.5

SWEP:SetupACFBullet()

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

		if self:Clip1() % 3 == 1 then self:SetNW2Float("Tracer",self.Tracer) else self:SetNW2Float("Tracer",0) end

		self:ShootBullet(Ply:GetShootPos(),Dir)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	if Ply:IsPlayer() then Ply:LagCompensation(false) end
end
