AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Base = "base_gmodentity"


local ACF        = ACF
local Damage     = ACF.Damage
local Objects    = Damage.Objects
local Debug		 = ACF.Debug

function MakeACF_Rock( ply, chargelevel )
	local Entity = ents.Create("acf_swep_rock")
	timer.Simple(15, function()
		if not IsValid(Entity) then return end

		Entity:Remove()
	end)
	if not IsValid(Entity) then return end

	local Owner = ply
	local dir   = Owner:EyeAngles():Forward()

	Entity:SetOwner(ply)
	Entity:SetAngles(Owner:EyeAngles())
	Entity:SetPos(Owner:GetShootPos() + dir * 50)
	Entity:CPPISetOwner(Owner)
	Entity:SetPlayer(Owner)
	Entity:Spawn()

	Entity:SetModel("models/props_foliage/rock_forest01d.mdl")
	Entity:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
	Entity:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
	Entity:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.
	Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	local phys = Entity:GetPhysicsObject() -- Retrieves the physics object of the Entity.
	if not phys:IsValid() then -- Checks if the physics object is valid.
		Entity:remove() return
	end

	phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
	phys:SetVelocity( Owner:GetVelocity() + dir * 500 * (1 + chargelevel / 7) )
	Entity.chargelevel = chargelevel
end

function ENT:PhysicsCollide( colData, collider )
	local Owner = self:GetOwner()
	local other = colData.HitEntity
	local hitSpeed = colData.Speed

	if other and IsValid(other) then
		if other:IsPlayer() then
			if hitSpeed > 250 then
				other:TakeDamage(15 * hitSpeed / 500, Owner, self)
			end
		else
			local DmgInfo = Objects.DamageInfo(self:GetOwner() or self, self)

			local Bullet = {
				Flight = self:GetVelocity(),
				Diameter = 50,
				Type = "APCR",
				ProjMass = self.chargelevel / 35,
				MuzzleVel = 20,
				Speed = hitSpeed,
			}

			Damage.dealDamage(other,  Damage.getBulletDamage(Bullet, colData), DmgInfo)

			if self.chargelevel > 35 then
				for i = 34, self.chargelevel do
					Damage.dealDamage(other,  Damage.getBulletDamage(Bullet, colData), DmgInfo)
				end
			end
		end
	end

	if hitSpeed > 350 then
		self:EmitSound( Sound( "Grenade.ImpactHard" ) )
	elseif hitSpeed > 150 then
		self:EmitSound( Sound( "Concrete.ImpactSoft" ) )
	end
end

function ENT:Think()
	--[[
	TraceData        = {}
	TraceData.start  = self:GetPos()
	TraceData.endpos = self:GetPos() + self:GetVelocity() / 65
	TraceData.filter = {self}

	local Result = ACF.trace(TraceData)

	if Result.Hit then
		self:SetPos(Result.HitPos)
		Result.Speed = self:GetVelocity():Dot( Result.HitNormal ) / self:GetVelocity():GetNormalized():Dot( Result.HitNormal )

		self:PhysicsCollide( Result, nil )
	end
	]]
	--return true
end

function ENT:OnRemove()
	WireLib.Remove(self)
end
