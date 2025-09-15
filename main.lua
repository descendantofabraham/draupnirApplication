--!native
--[[                                                                    
      .o8                                                           .o8                            .  
     "888                                                          "888                          .o8  
 .oooo888   .ooooo.   .oooo.o  .ooooo.   .ooooo.  ooo. .oo.    .oooo888   .oooo.   ooo. .oo.   .o888oo
d88" `888  d88" `88b d88(  "8 d88" `"Y8 d88" `88b `888P"Y88b  d88" `888  `P  )88b  `888P"Y88b    888  
888   888  888ooo888 `"Y88b.  888       888ooo888  888   888  888   888   .oP"888   888   888    888  
888   888  888    .o o.  )88b 888   .o8 888    .o  888   888  888   888  d8(  888   888   888    888 .
`Y8bod88P" `Y8bod8P" 8""888P" `Y8bod8P" `Y8bod8P" o888o o888o `Y8bod88P" `Y888""8o o888o o888o   "888"                                                                                             
]]
-- Copyright, 2025, descendantdescendantdescendant
-- Preload Globals
local Debug = {}
Debug.__enabled = false -- false = no debug outputs
Debug.__lastTick = tick() -- for the Clock method

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Teams = game:GetService("Teams")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")
local PhysicsService = game:GetService("PhysicsService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Metamethods
local DependenciesFolder = script:FindFirstChild("Dependencies")
local DraupnirModule = {}
local Dependencies = {}
DraupnirModule.__index = setmetatable(DraupnirModule,{})
Dependencies.__index = setmetatable(Dependencies,{})
Dependencies.__array = {
	["ParameterDenoteModule"] = require(DependenciesFolder.ParameterDenoteModule),
	["ScreenpointTranslationModule"] = require(DependenciesFolder.ScreenpointTranslationModule),
	["RayConstructionModule"] = require(DependenciesFolder.RayConstructionModule),
	["SoundControllersModule"] = require(DependenciesFolder.SoundControllersModule),
	["RandomNumberModule"] = require(DependenciesFolder.RandomNumberModule),
	["ImpactFrameModule"] = require(DependenciesFolder.ImpactFrameModule),
	["VisualParticleModule"] = require(DependenciesFolder.VisualParticleModule),
	["BloodModule"] = require(DependenciesFolder.BloodModule),
	
	["Folders"] = {
		Assets = ReplicatedStorage.Assets,
		Modules = ReplicatedStorage.Modules,
		Sounds = ReplicatedStorage.Sounds,
		Particles = ReplicatedStorage.Particles
	},
	
	["Values"] = {
		["busy"] = false,
	},
	
	["Constants"] = {
		["rayoffset"] = CFrame.Angles(math.rad(-90),0,0)
	}
}
Dependencies["DefaultParameters"] = Dependencies.__array.ParameterDenoteModule:DenoteAndReturn()

--Types
type PRIVATE_Configuration = {}
type PRIVATE_Character = Model
type PRIVATE_FullName = string
type PUBLIC_Constructor = {}
type PUBLIC_Result = boolean
type PUBLIC_Busy = boolean
type PUBLIC_Debugging = boolean
type PUBLIC_Tick = number
type PUBLIC_Model = Model
type PUBLIC_Weld = WeldConstraint

-- Fancy type-checking stuff for the "DraupnirModule" class
export type Debug = {
	__lastTick: PUBLIC_Tick,
	__enabled: PUBLIC_Debugging
}

-- More fancy type-checking stuff but for the "DraupnirModule" class
export type DraupnirModule = {
	New: {{model: PUBLIC_Model, weld : PUBLIC_Weld, busy: PUBLIC_Busy}},
	Clock: PUBLIC_Tick,
	DeclareConstants: {},
}

-- Main
function DraupnirModule.New()
	local self = setmetatable({
		ActiveSpears = {},
	}, DraupnirModule)
	
	return self
end

-- Sets all the necessary constants to save some performance.
function DraupnirModule:DeclareConstants()
	local Constants = Dependencies.__array.ParameterDenoteModule:ReturnConstants()
	
	-- Gets all the constants from the constants module and puts them into the Dependencies class.
	for name,value in next, Constants do
		if not Dependencies[name] then
			Dependencies[name] = value
		else
			continue
		end
	end
	return Constants
end

-- Returns the time it took to load the module (when the Clock method is ran).
function DraupnirModule:Clock()
	local clockedTime = {}
	clockedTime[1] = tick() - Debug.__lastTick
	
	-- Debug check
	if Debug.__enabled then
		warn("Module loaded in", tostring(clockedTime[1]), "seconds.")
	end
	
	return clockedTime
end

-- Explodes the last projectile that was successfully shot into a target.
function DraupnirModule:Explode(Character : PRIVATE_Character, ConfigurationTable : PRIVATE_Configuration, localizedName : PRIVATE_FullName)
	-- Assertions for type-checking and null instances.
	assert(Character, "Character was not provided.")
	assert(ConfigurationTable, "ConfigurationTable was not provided.")
	assert(localizedName, "localizedName was not provided.")
	assert(typeof(Character) == "Instance", "Character cannot be utilized.")
	assert(typeof(ConfigurationTable) == "table", "ConfigurationTable cannot be utilized.")
	assert(typeof(localizedName) == "string", "localizedName cannot be utilized.")
	
	-- Halts the code progression if the method is current busy. Weird way of checking if it's true, I know. Purely stylistic.
	if not tostring(Dependencies.__array.Values.busy):match("false") then 
		return 
	end
	
	-- Keep this here. Trying to call this method with no active spears will make the module get really mad.
	if #self.ActiveSpears <= 0 then 
		return 
	end
	
	-- Setting variables and creating constructors
	local IsolatedTable = {}
	local Index = self.ActiveSpears[#self.ActiveSpears] 
	local IsolatedIndex = table.remove(self.ActiveSpears, table.find(self.ActiveSpears,Index)) -- For the whole exploding the latest dart thing, there was another reason behind this that I forgot though
	local NewParticle = Dependencies.__array.VisualParticleModule.New()
	local Pos = Index.model.Position
	local Weld = Index.weld		
	table.insert(IsolatedTable, IsolatedIndex)
	
	-- Setting up particles and redefining variables
	NewParticle:Setup()
	NewParticle.Attachment.WorldCFrame = IsolatedIndex.model.CFrame
	Pos = IsolatedIndex.model.Position
	Weld = IsolatedIndex.weld
	
	-- Creates a new coroutine for the actual explosion part of all of this.
	coroutine.wrap(function()
		local Particle = Index.model.Charge
		local NewSound = Dependencies.__array.SoundControllersModule.NewSound()
		local SoundsFolder = Dependencies.__array.Folders.Sounds[localizedName]
		local ParticlesFolder = Dependencies.__array.Folders.Particles[localizedName].Explosion.Particles
		local NewImpactFrame = Dependencies.__array.ImpactFrameModule.New()	
		Particle:Emit(Dependencies.StickEmitCount)
		NewSound:Setup()
		
		-- Adding all the sounds to the NewSound controller
		NewSound:AddSound("Pulse", SoundsFolder.Pulse:Clone())
		NewSound:AddSound("Swoosh", SoundsFolder.Charge:Clone())
		NewSound:AddSound("ExplosionA", SoundsFolder.Explosion:Clone())
		NewSound:AddSound("ExplosionB", SoundsFolder.Explosion2:Clone())
		NewSound:AddSound("ExplosionB", SoundsFolder.Explosion2:Clone())
		
		-- Setting the position of the attachment so the sound actually comes from the dart.
		NewSound.Attachment.WorldCFrame = CFrame.new(Pos)
		NewSound:PlaySound("Swoosh",.93,1.12)
		NewSound:PlaySound("Pulse",3.2,3.7)
		
		-- Finds the humanoid (if there is one) and damages it.
		if Weld.Part1.Parent:FindFirstChildWhichIsA("Humanoid") then
			local Humanoid = Weld.Part1.Parent:FindFirstChildWhichIsA("Humanoid")
			Humanoid:TakeDamage(math.ceil(ConfigurationTable["%^dm.Impulse"] / Dependencies.ImpulseDivision))
		end

		-- Just to sync up the sounds with the actual explosion, makes it feel alive.	
		task.delay(.35,function()
			NewSound:PlaySound("ExplosionA",1,1.19) -- Playing the explosion sounds we made earlier through the NewSound controller.
			NewSound:PlaySound("ExplosionB",1.19,1.33)
			NewParticle:CopyFolder(ParticlesFolder, Dependencies.DefaultEmitCount)
			NewImpactFrame:StartImpactFrame("%0a+00", Dependencies.ImpactFrameLifespan) -- Fancy impact frame string name, it's ugly but I love it.
			
			-- Finds the humanoid (if there is one) and damages it, then creates some blood from the BloodModule.
			if Weld.Part1.Parent:FindFirstChildWhichIsA("Humanoid") then
				local Humanoid = Weld.Part1.Parent:FindFirstChildWhichIsA("Humanoid")
				task.spawn(function()
					Dependencies.__array.BloodModule.BloodEmissionService(Pos, Character, Instance.new("Attachment"), 3, 1, 2, 0, 8, .25, 1500)
				end)
				Humanoid:TakeDamage(ConfigurationTable["%^dm.Impulse"]) -- Another fancy name for the ConfigTable variables.
			end
			
			-- Gets rid of all the other ParticleEmitters.
			for _,v in next, IsolatedIndex.model:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v:Destroy()
				end
			end
			
			-- Gets rid of the "dart" itself, we don't like memory leaks.
			IsolatedIndex.model:Destroy()
			IsolatedIndex = nil
			table.clear(IsolatedTable)
		end)
	end)();	
end

-- Shoots a projectile.
function DraupnirModule:Throw(Character, UserCFrame, Length, SpearTemplate:Model, Switch:boolean, ConfigurationTable:{})
	-- I don't actually know if having the non-tostring version is necessary, but just incase it gives slightly better performance.
	local unlocalizedName = SpearTemplate.Parent.Parent.Name
	local localizedName = tostring(unlocalizedName) 
	
	-- Determines if we're "throwing" or "exploding".
	if not Switch then
		-- Setting some variabes here and shooting our Ray
		local BeamsFolder = ReplicatedStorage.Beams
		local TranslatedDirection = (UserCFrame.Position - Character.PrimaryPart.Position).Unit
		local CharacterPosition = Character.PrimaryPart.Position
		local RetranslatedRay = Dependencies.__array.RayConstructionModule:ShootRay(CharacterPosition, TranslatedDirection, Length, UserCFrame, Dependencies.DefaultParameters)
		local SpearTemplate : BasePart = SpearTemplate.MainAsset:Clone()
		
		-- Cool VFX stuff
		local ThrownBeam = BeamsFolder.Beam:Clone()
		local GlitchedPillar = BeamsFolder.Pillar:Clone()
		local StartingAttachment = Instance.new('Attachment')
		local EndAttachment = Instance.new('Attachment')
		
		-- Need to make sure we actually have a target to stick our "dart" into.
		if RetranslatedRay then
			if RetranslatedRay.Instance.Parent:FindFirstChildWhichIsA("Humanoid") and RetranslatedRay.Instance.Parent:FindFirstChildWhichIsA("Humanoid").Health <= 0 then return end
			
			-- More sound controllers and impact frames, just for shooting our dart this time.
			local NewSound = Dependencies.__array.SoundControllersModule.NewSound()	
			local NewImpactFrame = Dependencies.__array.ImpactFrameModule.New()	
			local NewBeamTween = TweenService:Create(ThrownBeam, Dependencies.DefaultTweenInfo, {Width1 = 0})
			local NewPillarTween = TweenService:Create(GlitchedPillar, Dependencies.FastTweenInfo, {Transparency = 1})
			
			-- Ray math stuff
			local RayOffset = Dependencies.__array.Constants.rayoffset
			local UntranslatedRayCFrame = CFrame.new(RetranslatedRay.Position,RetranslatedRay.Position-RetranslatedRay.Normal)
			local TranslatedRayCFrame = UntranslatedRayCFrame * RayOffset
			local DedicatedWeld = Instance.new("WeldConstraint")
			local Dictionary = {}
			
			-- Gets our sounds and impact frames going
			NewSound:Setup()
			NewImpactFrame:StartImpactFrame("%0a+01", Dependencies.ImpactFrameLifespan)
			NewSound.Attachment.WorldCFrame = UserCFrame
			
			-- Parents our VFX stuff to their corresponding spots, and positions thems
			GlitchedPillar.Parent = workspace.Debris
			StartingAttachment.Parent = workspace.Terrain
			EndAttachment.Parent = workspace.Terrain
			StartingAttachment.WorldPosition = CharacterPosition
			EndAttachment.WorldPosition = TranslatedRayCFrame.Position
			GlitchedPillar.Position = TranslatedRayCFrame.Position
			ThrownBeam.Parent = StartingAttachment -- These are for the "trails", it doesn't use actual projectiles so I used beams instead of actual trails!
			ThrownBeam.Attachment0 = StartingAttachment
			ThrownBeam.Attachment1 = EndAttachment
			
			-- Adds a couple more sounds and plays them right after.
			NewSound:AddSound("HitA", Dependencies.__array.Folders.Sounds[localizedName].Hit:Clone())
			NewSound:AddSound("HitB", Dependencies.__array.Folders.Sounds[localizedName].Hit2:Clone())
			NewSound:PlaySound("HitA",1.91,2.13)
			NewSound:PlaySound("HitB",.85,.97)
			NewBeamTween:Play()
			NewPillarTween:Play()
			
			-- Sticks and welds our "dart" into whatever it hit, at the right angle (thank you raycasting)
			SpearTemplate.Parent = workspace.Debris.Spears
			SpearTemplate.Anchored = false
			SpearTemplate.CFrame = TranslatedRayCFrame
			DedicatedWeld.Parent = SpearTemplate
			DedicatedWeld.Part0 = SpearTemplate
			DedicatedWeld.Part1 = RetranslatedRay.Instance
			Dictionary = {
				["model"] = SpearTemplate,
				["weld"] = DedicatedWeld,
				["busy"] = false,
			}
			table.insert(self.ActiveSpears, Dictionary)
			
			-- Damages the humanoid slightly (if it finds it), and makes a bit of blood come out
			if RetranslatedRay.Instance and RetranslatedRay.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
				local Humanoid = RetranslatedRay.Instance.Parent:FindFirstChildWhichIsA("Humanoid")
				Dependencies.__array.BloodModule.BloodEmissionService(RetranslatedRay.Position, Character, Instance.new("Attachment"), 1, .3, .4, .2, 4, .1, 500)
				Humanoid:TakeDamage(ConfigurationTable["%^dm.Inject"])
			end
			
			-- We don't like memory leaks!!!
			Debris:AddItem(ThrownBeam, 2)
			Debris:AddItem(StartingAttachment, 2)
			Debris:AddItem(EndAttachment, 2)
			Debris:AddItem(GlitchedPillar, 2)
		end
	end
	
	-- Checks if we're actually "exploding" the dart this time.
	if Switch then
		-- If we are, we call the Explode method.
		self:Explode(Character, ConfigurationTable, localizedName) 
	end
end

return DraupnirModule
