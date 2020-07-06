# BundleMounter
Bundlemounter is a dependency mod for Venice Unleashed that allows you to easily mount bundles and superbundles.
It was created so several mods can load different bundles without conflicts.

## Usage:

```lua
Events:Subscribe('BundleMounter:GetBundles', function(info)
  Events:Dispatch('BundleMounter:LoadBundles', 'Levels/XP4_Quake/XP4_Quake', {
    'Levels/XP4_Quake/XP4_Quake',
    'Levels/XP4_Quake/DeathMatch',
    'Levels/XP4_Quake/SquadDeathMatch'
})
end)
```

BundleMounter will automatically register the content into the current level.