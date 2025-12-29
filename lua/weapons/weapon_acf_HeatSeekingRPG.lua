AddCSLuaFile()

include("weapon_acf_HL2RPG.lua")

local ACF        			= ACF

SWEP.Base               	= "weapon_acf_hl2rpg"
SWEP.PrintName          	= "ACF Anti Aircraft Rocket Launcher"
SWEP.Category           	= "ACF-3 SWEPs"
SWEP.Author             	= "Duck called Aaronimus"

SWEP.IconOffset				= Vector(4,-4,0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands           	= true
SWEP.ViewModel          	= "models/weapons/c_rpg.mdl"
SWEP.ViewModelFlip      	= false
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("weapons/rpg/rocketfire1.wav")
SWEP.WorldModel         	= "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType           	= "rpg"

SWEP.Weight             	= 1

SWEP.Slot               	= 4
SWEP.SlotPos            	= 0

SWEP.Spawnable          	= true
SWEP.AdminOnly          	= false

SWEP.m_WeaponDeploySpeed	= 1
SWEP.Spread             	= 0.125
SWEP.RecoilMod          	= 0.1

SWEP.Primary.ClipSize   	= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo       	= "RPG_round"
SWEP.Primary.Automatic  	= false
SWEP.Primary.Delay      	= 1

// you can get this data by typing "acf_sweps_getDataFromAmmo" in console while looking at a GLATGM ammo box
// calibers lower than 100mm do not suffer from horrible inaccuracy

// copy paste values that the command puts in console to replace these to make your own custom thing

SWEP.ACFHEATStandoff = 0.0059731615869846
SWEP.ACFHEATBreakupDist = 0.048520055885002
SWEP.ACFHEATJetMass = 0.048556865958908
SWEP.Caliber = 70.0000378
SWEP.FillerMass = 2.3675996129365
SWEP.ACFHEATBreakupTime = 1.1994035199933e-05
SWEP.ACFType = "HEAT"
SWEP.LimitVel = 75
SWEP.ACFHEATBoomFillerMass = 1.0496358284019
SWEP.ACFHEATRoundVolume = 4079.3624663942
SWEP.ACFHEATLinerMass = 0.094361520891806
SWEP.ACFHEATJetMinVel = 2102.4564270258
SWEP.ACFHEATJetMaxVel = 4045.3487984824
SWEP.ACFHEATCartMass = 11.002605809159
SWEP.ACFHEATPropMass = 1.4624129596508
SWEP.ACFProjMass = 9.5401928495085
SWEP.ACFMuzzleVel = 574.0842954945
SWEP.Tracer = 0
SWEP.ACFHEATCasingMass = 7.0782317156802


// END OF COPY PASTE DATA

SWEP.ACFMuzzleVel 			= 50
SWEP.LimitVel 				= 2500
SWEP.BurnDuration 			= 0.5
SWEP.dropMultiplier 		= 1
SWEP.Agility 				= 15
SWEP.EnableGuidance 		= true

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

SWEP.lockedTarget = nil

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()
	if not Ply:IsOnGround() then return end
	if Ply:GetVelocity():Length() > 20 then return end


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
			DropMult        = self.dropMultiplier,
			Agility 		= self.Agility,

			LimitVel 		= self.LimitVel,
			BurnDuration 	= self.BurnDuration,

			Diameter 		= Caliber,
			Ricochet 		= 1000, // this is the ricochet angle in degrees, we dont want these to ricochet
		}

		local missile = MakeACF_SWEPATGM(self, BulletData, self.EnableGuidance, true, self.lockedTarget)
		
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

if SERVER then
	function SWEP:Think()
		local Targets = ACF.GetEntitiesInCone(self:GetPos(), self:GetOwner():GetForward(), 15)
		local targetfinal = nil
		local smallestAngle = 90

		for target in pairs(Targets) do
			if not target then continue end

			local angleToTarget = (target:GetPos() - self:GetOwner():GetPos()):GetNormal():Dot(self:GetOwner():GetForward())

			if angleToTarget < smallestAngle then
				smallestAngle = angleToTarget
				targetfinal = target
			end
		end

		self:SetNW2Entity( "LockedTarget", targetfinal )
		self.lockedTarget = targetfinal
	end
end

if CLIENT then
	function SWEP:Think()
		self.lockedTarget = self:GetNW2Entity( "LockedTarget" )
	end

	local SY = ScrH()
	local SX = ScrW()

	function SWEP:GetViewAim()
		return self.AimTable[self:GetNW2Int("aimsetting",1)]
	end

	function SWEP:DrawHUD()
		if self:GetOwner():IsOnGround() and self:GetOwner():GetVelocity():Length() <= 20 and (CurTime() - self.LastShot) >= self.Primary.Delay then
			surface.SetTextColor( 0, 255, 0, 255 ) -- Set text color
		elseif self.MissileInFlight then
			surface.SetTextColor( 255, 255, 0, 255) -- Set text color
		else
			surface.SetTextColor( 255, 0, 0, 255) -- Set text color
		end

		surface.SetTextPos( SX / 2 + 50, SY / 2 + 50 ) -- Set text position, top left corner
		surface.SetFont( "HL2MPTypeDeath" ) -- Set the font
		surface.DrawText( "3" ) -- Draw the text
	end

	function SWEP:DoDrawCrosshair(x,y)
		local AimMod = self:GetAimMod()
		local Spread = self.Spread
		local SpreadAmt = Spread * AimMod
		if self.CrosshairScale then SpreadAmt = math.max(self.CrosshairScale * AimMod,self.Spread) end
		local ViewSpread = Vector(100,0,0)
		ViewSpread:Rotate(Angle(SpreadAmt,0,0))
		ViewSpread:Rotate(EyeAngles())

		local locksize = 25
		local xT
		local yT

		if self.lockedTarget and IsValid(self.lockedTarget) then
			xT = self.lockedTarget:GetPos():ToScreen().x
			yT = self.lockedTarget:GetPos():ToScreen().y
		else
			xT = x
			yT = y
		end

		surface.SetDrawColor(255,255,255)
		surface.DrawLine(xT + locksize, yT + locksize, xT + locksize, yT + locksize * 0.75)
		surface.DrawLine(xT + locksize, yT - locksize, xT + locksize, yT - locksize * 0.75)
		surface.DrawLine(xT - locksize, yT + locksize, xT - locksize, yT + locksize * 0.75)
		surface.DrawLine(xT - locksize, yT - locksize, xT - locksize, yT - locksize * 0.75)

		surface.DrawLine(xT + locksize, yT + locksize, xT + locksize * 0.75, yT + locksize)
		surface.DrawLine(xT + locksize, yT - locksize, xT + locksize * 0.75, yT - locksize)
		surface.DrawLine(xT - locksize, yT + locksize, xT - locksize * 0.75, yT + locksize)
		surface.DrawLine(xT - locksize, yT - locksize, xT - locksize * 0.75, yT - locksize)

		return true
	end
end
