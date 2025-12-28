AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Anti-Material Rifle"
SWEP.Category               = "ACF-3 SWEPs"

SWEP.IconOffset				= Vector(4,4,0)
SWEP.IconAngOffset			= Angle(0,180,0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/v_snip_sg550.mdl"
SWEP.ViewModelFlip          = true

SWEP.ShotSound				= Sound("Weapon_SG552.Single")
SWEP.WorldModel             = "models/weapons/w_snip_sg550.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Ammo           = "XBowBolt"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 1.25

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 12.7 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.037 -- kg of projectile
SWEP.ACFType                = "APDS"
SWEP.ACFMuzzleVel           = 1400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(5.775,-4,2)
--SWEP.IronSightAng           = Angle()

SWEP.Scope					= true
SWEP.Zoom					= 8
SWEP.HasDropCalc			= true
SWEP.Recovery				= 0.6

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 3

SWEP.UseHands				= true

SWEP:SetupACFBullet()

local Reload = Sound("acf_base/weapons/sniper_reload.mp3")

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()

	
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

		self:ShootBullet(Ply:GetShootPos(), Dir)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	
end

function SWEP:Reload()
	self:SetNWBool("iron",false)
	if self:Ammo1() > 0 then
		self:DefaultReload( ACT_VM_RELOAD )
	end
end
