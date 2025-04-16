AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local ACF        = ACF
local Missiles   = ACF.ActiveMissiles
local Ballistics = ACF.Ballistics
local AmmoTypes  = ACF.Classes.AmmoTypes
local Damage     = ACF.Damage
local Clock      = ACF.Utilities.Clock
local TraceData  = { start = true, endpos = true, filter = true }
local ZERO       = Vector()

local function CheckViewCone(Missile, HitPos)
	local Position = Missile.Position
	local Forward  = Missile.Velocity:GetNormalized()
	local Direction = (HitPos - Position):GetNormalized()

	return Direction:Dot(Forward) >= Missile.ViewCone
end

local function ClampAngle(Object, Limit)
	local Pitch, Yaw, Roll = Object:Unpack()

	return Angle(
		math.Clamp(Pitch, -Limit, Limit),
		math.Clamp(Yaw, -Limit, Limit),
		math.Clamp(Roll, -Limit, Limit)
	)
end

local function DetonateMissile(Missile, Inflictor)
	local CanExplode = hook.Run("ACF_PreExplodeMissile", Missile, Missile.BulletData)

	if not CanExplode then return end

	if IsValid(Inflictor) and Inflictor:IsPlayer() then
		Missile.Inflictor = Inflictor
	end

	Missile:Detonate()
end

function MakeACF_SWEPATGM(Gun, BulletData)

	local Entity = ents.Create("acf_swep_missile")

		timer.Simple(60, function()
				if not IsValid(Entity) then return end

				Entity:Remove()
		end)

	if not IsValid(Entity) then return end

	local Velocity = math.Clamp(BulletData.MuzzleVel / ACF.Scale, 200, 1600)
	local Caliber  = BulletData.Caliber
	local Owner    = Gun.Owner

	Entity:SetAngles(Gun:GetAngles())
	Entity:SetPos(BulletData.Pos)
	Entity:CPPISetOwner(Owner)
	Entity:SetPlayer(Owner)
	Entity:Spawn()

	if Caliber >= 140 then
		Entity:SetModel("models/missiles/glatgm/mgm51.mdl")
		Entity:SetModelScale(Caliber / 150, 0)
	elseif Caliber >= 120 then
		Entity:SetModel("models/missiles/glatgm/9m112.mdl")
		Entity:SetModelScale(Caliber / 125, 0)
	else
		Entity:SetModel("models/missiles/glatgm/9m117.mdl")
		Entity:SetModelScale(Caliber * 0.01, 0)
	end

	Entity:PhysicsInit(SOLID_VPHYSICS)
	Entity:SetMoveType(MOVETYPE_VPHYSICS)

	ParticleEffectAttach("Rocket Motor GLATGM", 4, Entity, 1)

	Entity.Owner        = Gun.Owner
	Entity.Name         = Caliber .. "mm SWEP Launched Missile"
	Entity.ShortName    = Caliber .. "mmSLATGM"
	Entity.EntType      = "SWEP Launched Anti-Tank Guided Missile"
	Entity.Caliber      = Caliber
	Entity.Weapon       = Gun
	Entity.BulletData   = table.Copy(BulletData)
	Entity.ForcedArmor  = 5 -- All missiles should get 5mm
	Entity.ForcedMass   = BulletData.CartMass
	Entity.UseGuidance  = true
	Entity.ViewCone     = math.cos(math.rad(50)) -- Number inside is on degrees
	Entity.KillTime     = CurTime() + 20
	Entity.GuideDelay   = CurTime() + 0.25 -- Missile won't be guided for the first quarter of a second
	Entity.LastThink    = CurTime()
	Entity.Filter       = Entity.BulletData.Filter
	Entity.Agility      = 50 -- Magic multiplier that controls the agility of the missile
	Entity.IsSubcaliber = false -- just set this to false because its a handheld and the rockets are gonna be small
	Entity.LaunchVel    = math.Round(Velocity * 0.2, 2) * 39.37
	Entity.DiffVel      = math.Round(Velocity * 0.5, 2) * 39.37 - Entity.LaunchVel
	Entity.AccelLength  = BulletData.BurnDuration
	Entity.AccelTime    = Entity.LastThink + Entity.AccelLength
	Entity.Speed        = Entity.LaunchVel
	Entity.SpiralRadius = 10
	Entity.SpiralSpeed  = 1
	Entity.SpiralAngle  = 0
	Entity.Position     = BulletData.Pos
	Entity.Velocity     = BulletData.Flight:GetNormalized() * Entity.LaunchVel
	Entity.Inaccuracy   = 0
	Entity.Diameter     = Caliber
	Entity.DropMult     = BulletData.DropMult

	Entity.BulletData.Diameter 	= Caliber
	Entity.BulletData.Speed 	= Entity.Speed

	Entity.Filter[#Entity.Filter + 1] = Entity

	local PhysObj = Entity:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:EnableGravity(false)
		PhysObj:EnableMotion(false)
		PhysObj:SetMass(Entity.ForcedMass)
	end

	ACF.Activate(Entity)

	Missiles[Entity] = true -- no clue what this line does, just copied from ACF-3-Missiles, doesnt seem useful

	hook.Run("ACF_OnLaunchMissile", Entity)

	return Entity
end

function ENT:ACF_Activate(Recalc)
	local PhysObj = self.ACF.PhysObj
	local Area    = PhysObj:GetSurfaceArea() * ACF.InchToCmSq
	local Armor   = self.ForcedArmor
	local Health  = Area / ACF.Threshold
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Area      = Area
	self.ACF.Ductility = 0
	self.ACF.Health    = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour    = Armor * (0.5 + Percent * 0.5)
	self.ACF.MaxArmour = Armor * ACF.ArmorMod
	self.ACF.Mass      = self.ForcedMass
	self.ACF.Type      = "Prop"
end

function ENT:ACF_OnDamage(DmgResult, DmgInfo)
	if self.Detonated then
		return {
			Damage = 0,
			Overkill = 1,
			Loss = 0,
			Kill = false
		}
	end

	local HitRes = Damage.doPropDamage(self, DmgResult, DmgInfo) -- Calling the standard prop damage function
	local Owner  = DmgInfo:GetAttacker()

	-- If the missile was destroyed, then we detonate it.
	if HitRes.Kill then
		DetonateMissile(self, Owner)

		return HitRes
	elseif HitRes.Overkill > 0 then
		local Ratio = self.ACF.Health / self.ACF.MaxHealth

		-- We give it a chance to explode when it gets penetrated aswell.
		if math.random() > 0.75 * Ratio then
			DetonateMissile(self, Owner)

			return HitRes
		end

		-- Turning off the missile's guidance.
		if self.UseGuidance and math.random() > 0.5 * Ratio then
			self.UseGuidance = nil
		end
	end

	return HitRes -- This function needs to return HitRes
end

function ENT:GetComputer()
	if not self.UseGuidance then return end

	local Weapon = self.Weapon

	if not IsValid(Weapon) then return end

	local Computer = Weapon.Computer

	if not IsValid(Computer) then return end
	if Computer.Disabled then return end
	if not Computer.IsComputer then return end
	if Computer.HitPos == ZERO then return end

	return Computer
end

function ENT:Think()
	if self.Detonated then return end

	local Time = Clock.CurTime

	if Time >= self.KillTime then
		return self:Detonate()
	end

	local DeltaTime = Time - self.LastThink
	local CanGuide  = self.GuideDelay <= Time
	local Computer  = self:GetComputer()
	local CanSee    = IsValid(Computer) and CheckViewCone(self, Computer.HitPos)
	local Position  = self.Position
	local NextDir, NextAng

	self.Speed = self.LaunchVel + self.DiffVel * math.Clamp(1 - (self.AccelTime - Time) / self.AccelLength, 0, 1)

	if CanGuide and CanSee then
		local Origin      = Computer:LocalToWorld(Computer.Offset)
		local Distance    = Origin:Distance(Position) + self.Speed * 0.15
		local Target      = Origin + Computer.TraceDir * Distance
		local Expected    = (Target - Position):GetNormalized():Angle()
		local Current     = self.Velocity:GetNormalized():Angle()
		local _, LocalAng = WorldToLocal(Target, Expected, Position, Current)
		local Clamped     = ClampAngle(LocalAng, self.Agility * DeltaTime)
		local _, WorldAng = LocalToWorld(Vector(), Clamped, Position, Current)

		NextAng = WorldAng
		NextDir = WorldAng:Forward()

		self.Inaccuracy = 0
	else
		local Spread = self.Inaccuracy * DeltaTime * 0.005
		local Added  = VectorRand() * Spread

		NextDir = (self.Velocity:GetNormalized() + Vector(0,0, -0.0003 * (self.DropMult or 1)) + Added):GetNormalized()
		NextAng = NextDir:Angle()

		self.Inaccuracy = self.Inaccuracy + DeltaTime * 1
	end

	self.Position = self.Position + NextDir * self.Speed * DeltaTime
	self.Velocity = (self.Position - Position) / DeltaTime

	TraceData.start  = Position
	TraceData.endpos = self.Position
	TraceData.filter = self.Filter

	local Result = ACF.trace(TraceData)

	if Result.Hit then
		self.Position = Result.HitPos

		return self:Detonate()
	end

	self:SetPos(self.Position)
	self:SetAngles(NextAng)
	self:NextThink(Time)

	self.LastThink = Time

	return true
end

function ENT:Detonate()
	if self.Detonated then return end

	local PhysObj       = self:GetPhysicsObject()
	local BulletData    = self.BulletData
	local Ammo          = AmmoTypes.Get(BulletData.Type)
	self:SetNotSolid(true)
	self:SetNoDraw(true)
	self.Detonated = true
	Missiles[self] = nil

	BulletData.Filter   = self.Filter
	BulletData.Pos      = self.Position
	BulletData.Flight   = self.Velocity:GetNormalized() * self.Speed
	BulletData.DetonatorAngle = 91

	if IsValid(PhysObj) then
		PhysObj:EnableMotion(false)
	end

	timer.Simple(1, function()
		if IsValid(self) then self:Remove() end
	end)

	local Bullet = Ballistics.CreateBullet(BulletData)

	return true
end

function ENT:OnRemove()
	Missiles[self] = nil

	WireLib.Remove(self)
end
