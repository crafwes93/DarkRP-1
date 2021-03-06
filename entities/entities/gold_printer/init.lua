AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.SeizeReward = 3750

local PrintMore
function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(255,255,255,255)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	timer.Simple(math.random(30, 60), PrintMore, self)
	self:SetNWInt("PrintA",0)
end

function ENT:OnTakeDamage(dmg)
	if self.burningup then return end

	self.damage = self.damage - dmg:GetDamage()
	if self.damage <= 0 then
		self:Destruct()
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	Notify(self.dt.owning_ent, 1, 4, "Your Golden Printer has exploded!")
end

function ENT:BurstIntoFlames()
	if self.Cooler and self.Cooler:GetNWInt("charges") > 0 then
		Notify(self:GetNWEntity("owning_ent"), 1, 4, "Your money printer's cooler has used up a charge.\nRemaining charges: "..self.Cooler:GetNWInt("charges"))
		self.Cooler:SetNWInt("charges", self.Cooler:GetNWInt("charges") - 1)
	else
		Notify(self.dt.owning_ent, 0, 4, "Your Golden Printer is overheating!")
		self.burningup = true
        self:SetColor(237,28,36,255)
		local burntime = math.random(8, 18)
		self:Ignite(burntime, 0)
		timer.Simple(burntime, self.Fireball, self)
	end
end

function ENT:Fireball()
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v.IsMoneyPrinter then v:Ignite(math.random(5, 22), 0) end
	end
	self:Remove()
end

PrintMore = function(ent)
	if ValidEntity(ent) then
		ent.sparking = true
		timer.Simple(3, ent.CreateMoneybag, ent)
	end
end

function ENT:Use(activator)

if(activator:IsPlayer()) then
activator:AddMoney(self:GetNWInt("PrintA"));
self:SetNWInt("PrintA",0)
end

end

function ENT:CreateMoneybag()
	if not ValidEntity(self) then return end
	if self:IsOnFire() then return end
	local MoneyPos = self:GetPos()
	local X = 10
	local Y = 2250
	if math.random(1, X) == 1 then self:BurstIntoFlames() end
	local amount = self:GetNWInt("PrintA") + Y
	self:SetNWInt("PrintA",amount)
	
	self.sparking = false
	timer.Simple(math.random(250, 350), PrintMore, self)
end

function ENT:Think()
	if not self.sparking then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("selection_ring", effectdata)
end

function ENT:OnRemove()
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos())
		effectdata:SetScale(1)
		effectdata:SetMagnitude(1)
	util.Effect( "selection_ring", effectdata, true, true )
end

function ENT:Touch( hitEnt )
	if hitEnt.IsCooler and not self.Cooler then
		self.Cooler = hitEnt
		self.OldAngles = self.Entity:GetAngles()
		self.Entity:SetAngles(Vector(0, 0, 0))

		hitEnt:SetPos(self.Entity:GetPos() + Vector(1.9534912109375, 9.9049682617188, 6.304988861084))
		hitEnt:SetAngles(self.Entity:GetAngles() + Vector(0, 90, 0))
		constraint.Weld(hitEnt, self.Entity, 0, 0, 0, true)

		self.Entity:SetAngles(self.OldAngles)

		local phys = hitEnt:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMass(1)
		end
	elseif hitEnt.IsCollector and not self.Collector then
		self.Collector = hitEnt
		self.OldAngles = self.Entity:GetAngles()
		self.Entity:SetAngles(Vector(0, 0, 0))

		hitEnt:SetPos(self.Entity:GetPos() + Vector(-4.62841796875, -6.8973388671875, 14.61595916748))
		hitEnt:SetAngles(self.Entity:GetAngles() + Vector(89.261619508266, 6.043903529644, -19.906075708568))
		constraint.Weld(hitEnt, self.Entity, 0, 0, 0, true)

		self.Entity:SetAngles(self.OldAngles)

		local phys = hitEnt:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMass(1)
		end
	end
end