# BundleMounter
Bundlemounter is a dependency mod for Venice Unleashed that allows you to easily mount bundles and superbundles.

## Usage:

```lua
Events:Subscribe('BundleMounter:RegisterBundles', function(info)
  Events:Dispatch('BundleMounter:LoadBundle', 'Levels/XP4_Quake/XP4_Quake', {
    'Levels/XP4_Quake/XP4_Quake',
    'Levels/XP4_Quake/DeathMatch',
    'Levels/XP4_Quake/SquadDeathMatch',
})
end)
```

BundleMounter will automatically register the content into the current level.

## NOTE
Bundlemounter doesn't work on all levels, not sure why. Please create an issue for each of the affected levels.
