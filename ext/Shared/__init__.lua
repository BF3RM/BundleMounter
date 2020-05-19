class 'BundleMounterShared'

function BundleMounterShared:__init()
	print("Initializing BundleMounterShared")
	self:RegisterEvents()
	self:RegisterVars()
end

function BundleMounterShared:RegisterEvents()
	print("registering events")
	self.m_ReadInstanceEvent = Events:Subscribe('BundleMounter:LoadBundles', self, self.LoadBundles)
	self.m_LevelLoadEvent = Events:Subscribe("Level:LoadResources", self, self.OnLoadResources)
	Hooks:Install('ResourceManager:LoadBundles',1, self, self.OnLoadBundles)
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
end

function BundleMounterShared:OnPartitionLoaded(p_Partition)
	if p_Partition == nil then
		return
	end
	
	local s_Instances = p_Partition.instances
	for _, l_Instance in ipairs(s_Instances) do
		if l_Instance == nil then
			print('Instance is null?')
			break
		end
		if(l_Instance.typeInfo.name == "RegistryContainer" and not string.match(p_Partition.name, self.m_PrimaryLevel)) then
			print("Adding registry")
			ResourceManager:AddRegistry(l_Instance, ResourceCompartment.ResourceCompartment_Game)
		end
	end
end

function BundleMounterShared:RegisterVars()
	self.m_Bundles = {}
	self.m_PrimaryLevel = nil

end


function BundleMounterShared:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)
	if(p_Bundles[1] == "gameconfigurations/game" or p_Bundles[1] == "UI/Flow/Bundle/LoadingBundleMp") then
		print("Loading")
		Events:Dispatch('BundleMounter:RegisterBundles')
	end
	print("LoadBundles")
	Events:Dispatch('BundleMounter:GetBundles', true)
	print("LEGO")
	 if #p_Bundles == 1 and IsPrimaryLevel(p_Bundles[1]) then
	 	self.m_PrimaryLevel = p_Bundles[1]
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
	if(self.m_Bundles ~= nil) then
		print("Loading bundles: " .. dump( self.m_Bundles ))
	end

	for l_Superbundle, l_Bundles in ipairs(self.m_Bundles) do
		print(l_Superbundle .. " | " .. l_Bundles)
	end

	for l_Superbundle, l_BundleArray in pairs(self.m_Bundles) do
		print("Mounting superbundle " .. l_Superbundle)
		ResourceManager:MountSuperBundle(l_Superbundle)
	end
end

function BundleMounterShared:LoadBundles(p_SuperBundle, p_Bundles) 
	print("Loading: ")
	print(p_SuperBundle)
	if(self.m_Bundles == nil) then
		self.m_Bundles = {}
	end
	-- TODO:
	-- Make sure the primary bundle is loaded before secondary.
	-- Meaning that Levels\coop_003\coop_003 MUST be loaded before Levels\coop_003\WhateverBundle

	if(inTable(p_Bundles, p_SuperBundle) or split(p_SuperBundle, "/")[2] == nil) then
		-- print("We already have the core bundle")
	else 
		table.insert(p_Bundles, p_SuperBundle)
	end
	print("Added bundles:" .. p_SuperBundle .. ": " .. dump(p_Bundles))
	for _, s_Bundle in pairs(p_Bundles) do
		table.insert(self.m_Bundles[p_SuperBundle:lower()], s_Bundle)
	end
end

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

