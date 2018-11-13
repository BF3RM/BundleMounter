class 'BundleMounterShared'

local m_vuExtensions = require "__shared/VUExtensions"

function BundleMounterShared:__init()
	print("Initializing BundleMounterShared")
	self:RegisterEvents()
	self:RegisterVars()
end

function BundleMounterShared:RegisterEvents()
	print("registering events")
	self.m_ReadInstanceEvent = Events:Subscribe('BundleMounter:LoadBundle', self, self.LoadBundle)
	self.m_LevelLoadEvent = Events:Subscribe("Level:LoadResources", self, self.OnLoadResources)
	self.m_PartitionLoadedEvent = Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
	Hooks:Install('ResourceManager:LoadBundles',1, self, self.OnLoadBundles)
	Hooks:Install('ClientEntityFactory:Create', 9, self, self.OnEntityCreate)
end
function BundleMounterShared:OnEntityCreate(p_Hook, p_Data, p_Transform)
	if p_Data == nil then
		print("Didnt get no data")
	else
		--print(p_Data.typeInfo.name)
	end
end
function BundleMounterShared:RegisterVars()
	self.m_Bundles = {}
	self.m_Registries = {}
	self.m_MeshVariationEntries = {}
end


function BundleMounterShared:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)
	 if #p_Bundles == 1 and IsPrimaryLevel(p_Bundles[1]) then
 		print("Modifying bundles")
		local s_Bundles = {}
		for l_Superbundle, l_BundleArray in pairs(self.m_Bundles) do
			s_Bundles = TableConcat(s_Bundles, l_BundleArray)
		end
        s_Bundles[#s_Bundles + 1] = p_Bundles[1]
        
        print(s_Bundles)
        p_Hook:Pass(s_Bundles, p_Compartment)
    end
end

function BundleMounterShared:OnLoadResources(p_Dedicated)
	print("Loading shit yo")
	if(self.m_Bundles ~= nil) then
		print("Loading bundles: " .. dump( self.m_Bundles ))
	end

	for l_Superbundle, l_Bundles in ipairs(self.m_Bundles) do
		print(l_Superbundle .. " | " .. l_Bundles)
	end

	for l_Superbundle, l_BundleArray in pairs(self.m_Bundles) do
		ResourceManager:MountSuperBundle(l_Superbundle)
	end
end


function BundleMounterShared:LoadBundle(p_SuperBundle, p_Bundles) 
	print("Loading: ")
	print(p_SuperBundle)
	print(p_Bundles)
	if(self.m_Bundles == nil) then
		self.m_Bundles = {}
	end
	-- TODO:
	-- Make sure the primary bundle is loaded before secondary.
	-- Meaning that Levels\coop_003\coop_003 MUST be loaded before Levels\coop_003\WhateverBundle

	if(inTable(p_Bundles, p_SuperBundle) or split(p_SuperBundle, "/")[2] == nil) then
		print("We already have the core one")
	else 
		table.insert(p_Bundles, p_SuperBundle)
	end
	print("Added bundles:" .. p_SuperBundle .. ": " .. dump(p_Bundles))
	self.m_Bundles[p_SuperBundle:lower()] = p_Bundles
end



function BundleMounterShared:OnPartitionLoaded(p_Partition)
	if p_Partition == nil then
		return
	end
	
	local s_Instances = p_Partition.instances


	for _, p_Instance in ipairs(s_Instances) do
		if p_Instance == nil then
			print('Instance is null?')
			break
		end
		--print(p_Instance.typeInfo.name .. " | " .. tostring(p_Guid))
		if p_Instance.typeInfo.name == "LevelData" then
			local s_Instance = LevelData(p_Instance)
			print("Found LevelData: " .. s_Instance.name)

			if self.m_Bundles ~= nil and self.m_Bundles[s_Instance.name:lower()] == nil then
				print("Primary level")
				print("Adding the referenced shit")
				self.m_PrimaryLevelName = split(s_Instance.name, "/")[2]
				self:ApplyRegistry(m_vuExtensions:PrepareInstanceForEdit(p_Partition, s_Instance.registryContainer))
			else
				if s_Instance.registryContainer ~= nil then

					print("adding the registry from " .. s_Instance.name)
					self.m_Registries[s_Instance.name] = RegistryContainer(s_Instance.registryContainer)
					print("Added the registry from " .. s_Instance.name)
				end
			end
		end

		if p_Instance.typeInfo.name == "SubWorldData" then
			local s_Instance = SubWorldData(p_Instance)
			print("Found SubWorldData: " .. s_Instance.name)

			if self.m_PrimaryLevelName ~= nil and string.match(s_Instance.name, self.m_PrimaryLevelName) then
				return
			end
			if s_Instance.registryContainer ~= nil then
				print("Adding the registry from " .. s_Instance.name)
				self.m_Registries[s_Instance.name] = RegistryContainer(s_Instance.registryContainer) 
				print("Added the registry from " .. s_Instance.name)
			end
		end
	end
end


function BundleMounterShared:ApplyRegistry(p_Registry)
	print("Starting to add registry entries.")
	for l_RegistryName, l_Registry in pairs(self.m_Registries) do
		print("Loading registry entries from " .. l_RegistryName)

		--Crashing
		--EntityRegistry
		--[[
		local s_EntityCount = l_Registry:GetEntityRegistryCount()
		print("Loading " .. s_EntityCount .. " entities")
		for i = 0, s_EntityCount - 1, 1 do
			local s_RegistryEntry = l_Registry:GetEntityRegistryAt(i)
			if(s_RegistryEntry ~= nil) then
				print(s_RegistryEntry.typeInfo.name)
				p_Registry:AddEntityRegistry(s_RegistryEntry)
			end
		end
		]]
		--AssetRegistry
		local s_AssetCount = #l_Registry.assetRegistry
		print("Loading " .. s_AssetCount .. " assets")
		for i = 1, s_AssetCount, 1 do

			if(l_Registry.assetRegistry:get(i) == nil) then
				print("[FATAL!] null refrence")
			end

			local s_RegistryEntry = Asset(l_Registry.assetRegistry:get(i))

			if(s_RegistryEntry ~= nil) then
				--print(i)
				p_Registry.assetRegistry:add(s_RegistryEntry)
			end
		end

		--BlueprintRegistry
		local s_BlueprintRegistryCount = #l_Registry.blueprintRegistry
		print("Loading " .. s_BlueprintRegistryCount .. " blueprints")
		for i = 1, s_BlueprintRegistryCount, 1 do
			if(l_Registry.blueprintRegistry:get(i) == nil) then
				print("[FATAL!] null refrence")
			end
			local s_RegistryEntry = l_Registry.blueprintRegistry:get(i)
			if(s_RegistryEntry ~= nil) then
				--print(i)
				p_Registry.blueprintRegistry:add(s_RegistryEntry)
			end
		end

		--
		--ReferenceObjectRegistry
		
		local s_ReferenceObjectRegistryCount = #l_Registry.referenceObjectRegistry
		print("Loading " .. s_ReferenceObjectRegistryCount .. " referenceObjects")
		for i = 0, s_ReferenceObjectRegistryCount - 1, 1 do
			local s_RegistryEntry = l_Registry.referenceObjectRegistry:get(i)
			if(s_RegistryEntry ~= nil) then
				p_Registry.referenceObjectRegistry:add(s_RegistryEntry)
			end
		end
		
	end
	print("Errything is loaded yo!")

end

-- util 
function IsPrimaryLevel( p_Bundle )
	local s_Path = split(p_Bundle, "/")
	if s_Path[2] == s_Path[3] then
		return true
	end

	return false
end
function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

function dump(o)
	if(o == nil) then
		print("tried to load jack shit")
	end
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
	  if s ~= 1 or cap ~= "" then
	 table.insert(Table,cap)
	  end
	  last_end = e+1
	  s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
	  cap = pString:sub(last_end)
	  table.insert(Table, cap)
   end
   return Table
end

g_BundleMounterShared = BundleMounterShared()

