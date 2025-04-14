AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "Just a regular ACF RPG"
SWEP.Category               = "Other"

SWEP.IconOffset				= Vector(4, -4, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/c_rpg.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("weapons/rpg/rocketfire1.wav")
SWEP.WorldModel             = "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType               = "pistol"

SWEP.Weight                 = 1

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.125
SWEP.RecoilMod              = 0.1

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 1

// you can get this data by typing "acf_sweps_getDataFromAmmo" in console while looking at a GLATGM ammo box
// calibers lower than 100mm do not suffer from horrible inaccuracy

// copy paste values that the command puts in console to replace these to make your own custom thing

SWEP.ACFHEATStandoff = 0.016283185824267
SWEP.ACFHEATBreakupDist = 0.35898786146991
SWEP.ACFHEATJetMass = 8.6639858153785
SWEP.Caliber = 380
SWEP.FillerMass = 32.928183785914
SWEP.ACFHEATBreakupTime = 6.1857630030215e-05
SWEP.ACFType = "GLATGM"
SWEP.LimitVel = 100
SWEP.ACFHEATCartMass = 64.360832275829
SWEP.ACFHEATBoomFillerMass = 14.598161478422
SWEP.ACFHEATRoundVolume = 69181.011824701
SWEP.ACFHEATLinerMass = 15.052530734696
SWEP.ACFHEATJetMinVel = 3277.5412738015
SWEP.ACFHEATJetMaxVel = 5803.4532085137
SWEP.ACFProjMass = 63.283423075281
SWEP.ACFHEATPropMass = 1.0774092005486
SWEP.ACFMuzzleVel = 191.32185745702
SWEP.Tracer = 0
SWEP.ACFHEATCasingMass = 15.302708554672

// END OF COPY PASTE DATA

SWEP.dropMultiplier = 5
SWEP.ACFMuzzleVel = 10
SWEP.LimitVel = 25
SWEP.BurnDuration = 0.5

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0

SWEP.AimTable = {}
SWEP.AimTable[1] = {IronPos = Vector(-3.83,-8,-0.4),IronAng = Angle(2.9,-0.5,0), PitchAdjust = -1.55,Text = "100yd"} -- 100yd
SWEP.AimTable[2] = {IronPos = Vector(-3.79,-8,-1.9),IronAng = Angle(6.9,-0.4,0), PitchAdjust = -4.2,Text = "200yd"} -- 200yd
SWEP.AimTable[3] = {IronPos = Vector(-3.77,-8,-3.64),IronAng = Angle(11.6,-0.35,0), PitchAdjust = -6.6,Text = "300yd"} -- 300yd

SWEP.SprintAng				= Angle(-5,-10,0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.UseHands				= false

SWEP.AimFocused				= 0.75
SWEP.AimUnfocused			= 5

SWEP.CustomAnim				= true
SWEP.AimAnim				= ACT_VM_DEPLOY
SWEP.IdleAnim				= ACT_VM_UNDEPLOY

SWEP.SprintAng				= Angle(-10,-10,0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0,0,1)
SWEP.OffsetWorldModelAng	= Angle(10,0,180)

SWEP.FakeFire				= true	-- This shakes the aim bloom so you can't just quickshot to victory
SWEP.MoveBloom				= 2

SWEP.Scope					= true
SWEP.HasDropCalc			= false
SWEP.Zoom					= 2
SWEP.Recovery				= 2

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
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

		--self:ShootBullet(Ply:GetShootPos(),(Dir:Angle() + Angle(self.AimTable[self:GetNW2Int("aimsetting",1)].PitchAdjust,0,0)):Forward())

		local BulletData = {
			MuzzleVel 		= self.ACFMuzzleVel, 
			Caliber 		= self.Caliber, 
			Pos 			= Ply:GetShootPos() + Aim * 35 + Right * 10, 
			ProjMass 		= self.ACFProjMass, 
			PropMass 		= self.ACFHEATPropMass,
			Flight 			= Dir,
			Speed 			= self.MuzzleVel,
			Filter 			= {},
			DragCoef 		= ((3.1416 * (self.Caliber / 2) ^ 2) / 10000) / self.ACFProjMass,
			CartMass 		= self.ACFHEATCartMass,
			Type 			= self.ACFType,
			FillerMass 		= self.FillerMass,
			BoomFillerMass 	= self.ACFHEATBoomFillerMass,
			CasingMass 		= self.ACFHEATCasingMass,
			DetonatorAngle 	= self.ACFHEATDetAngle,
			Standoff 		= self.ACFHEATStandoff,
			LinerMass 		= self.ACFHEATLinerMass,

			JetMass 		= self.ACFHEATJetMass,
			JetMinVel 		= self.ACFHEATJetMinVel,
			JetMaxVel 		= self.ACFHEATJetMaxVel,
			RoundVolume 	= self.ACFHEATRoundVolume,
			BreakupDist 	= self.ACFHEATBreakupDist,
			BreakupTime 	= self.ACFHEATBreakupTime,

			LimitVel 		= self.LimitVel,
			BurnDuration 	= self.BurnDuration,
			DropMult        = self.dropMultiplier,

			Diameter 		= Caliber,
			Ricochet 		= 1000, // this is the ricochet angle in degrees, we dont want these to ricochet
		}

		local missile = MakeACF_SWEPATGM(self, BulletData)
	else
		self:Recoil(Punch)
	end
	

	self:PostShot(1)

	
end

local FiremodeSound = Sound("Weapon_SMG1.Special2")
function SWEP:SecondaryAttack()
	local Owner = self:GetOwner()
	if Owner:KeyDown(IN_USE) and (CurTime() > self.NextAttack2Toggle) then

		if SERVER then
			local cursetting = self:GetNW2Int("aimsetting",1)
			if (cursetting + 1) > #self.AimTable then cursetting = 1 else cursetting = cursetting + 1 end
			self:SetNW2Int("aimsetting",cursetting)
			self:GetOwner():PrintMessage(4,self.AimTable[cursetting].Text)
		else
			self:EmitSound(FiremodeSound)
		end

		self.NextAttack2Toggle = CurTime() + 0.25
		return true
		
	end

	return true
end

if CLIENT then
	function SWEP:GetViewAim()
		return self.AimTable[self:GetNW2Int("aimsetting",1)]
	end
end
