AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "handgun"
SWEP.Category               = "Other"

SWEP.IconOffset				= Vector(4,4,0)
SWEP.IconAngOffset			= Angle(0,180,0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/v_pistol.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound(")acf_base/weapons/ac_fire4.mp3")
SWEP.WorldModel             = "models/weapons/w_pistol.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 15
SWEP.Primary.DefaultClip    = 15
SWEP.Primary.Ammo           = "XBowBolt"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.3

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 500 -- mm diameter of bullet
SWEP.ACFProjMass            = 50 -- kg of projectile
SWEP.ACFType                = "APCR"
SWEP.ACFMuzzleVel           = 100 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-5.77,-4,0.92)
--SWEP.IronSightAng           = Angle()

SWEP.Scope					= false
SWEP.Zoom					= 1.2
SWEP.HasDropCalc			= true
SWEP.Recovery				= 0.1

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 3

SWEP.UseHands				= false

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

		self:ShootBullet(Ply:GetShootPos(),Dir)

		local inradius = ents.FindInSphere(Ply:GetPos() + Aim * 50, 100)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	
end

function SWEP:Reload()
	self:SetNWBool("iron",false)
	if self:Ammo1() > 0 then
		self:DefaultReload( ACT_VM_RELOAD )
		self:EmitSound(Reload)
	end
end
