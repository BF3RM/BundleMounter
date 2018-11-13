# BundleMounter
Bundlemounter is a mod for Venice Unleashed that allows you to easily mount bundles and superbundles.

## Usage:

```lua
function MyMod:RegisterEvents()
-- Subscribe to the LoadBundles hook
  Hooks:Install('ResourceManager:LoadBundles',999, self, self.OnLoadBundles) 
end


function MyMod:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)

-- Catch the earliest possible bundle. Both server & client.
  if(p_Bundles[1] == "gameconfigurations/game" or p_Bundles[1] == "UI/Flow/Bundle/LoadingBundleMp") then 
  -- Mount your superbundle and bundles..
  
    Events:Dispatch('BundleMounter:LoadBundle', 'levels/sp_paris/sp_paris', {
      "levels/sp_paris/heat_pc_only",
      "levels/sp_paris/sp_paris",
      "levels/sp_paris/chase",
      "levels/sp_paris/loweroffice",
      "levels/sp_paris/loweroffice_pc"
    })
  end
end

-- And you're done.
```

BundleMounter will automatically register the content into the current level.

## NOTE
Bundlemounter doesn't work on all levels, not sure why. Please create an issue for each of the affected levels.
