# BundleMounter
Bundlemounter is a dependency mod for Venice Unleashed that allows you to easily mount bundles and superbundles.
It was created so several mods can load different bundles without conflicts.

## Usage:

```lua
Events:Subscribe('BundleMounter:GetBundles', function(bundles)
  Events:Dispatch('BundleMounter:LoadBundles', 'Levels/XP4_Quake/XP4_Quake', {
    'Levels/XP4_Quake/XP4_Quake',
    'Levels/XP4_Quake/DeathMatch',
    'Levels/XP4_Quake/SquadDeathMatch'
})
end)
```

BundleMounter will automatically register the content into the current level.

You can find a list of superbundles and bundles in the [Venice Unleashed Docs](https://docs.veniceunleashed.net/vext/bundles/) and search through the bundle contents [here](https://github.com/Powback/VU-Wiki/tree/master/Bundles/)
