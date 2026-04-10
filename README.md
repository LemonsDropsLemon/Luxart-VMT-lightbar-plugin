# Luxart-VMT-lightbar-plugin
A plugin originally designed as a replacement for the ONX EVP vehicle pack, aided by [AutLaaws Development al_lightbar script](https://github.com/AutLaaw/al_lightbars), hence the ONX models referenced inside the plugin's "SETTINGS" lua, but can be used for other VMT type vehicles, for as long as you reference the lightbar models.

All you need is to take this plugin, and place it inside of the "PLUGINS" folder in Luxart.

For support, dont hesitate to [join my discord](https://discord.gg/SB3AUSYJYN) to open a ticket! 

### ONX
If you use ONX, you must remove "shared, client, server" folders from their "onx-evp-b-lightbars" resource, as this handles their own lightbar resource. This needs to be deleted so you can use Luxart instead.


## Expected ONX layout
Your onx-evp-b-lightbars file structure should look like this
```
onx-evp-b-lightbars/
├── data
├── stream
├── .fxap
├── fxmanifest.lua
└── version.lua
```

## Luxart file structure with plugin
Your file structure should look like this
```
Lvc (Luxart)/
├── PLUGINS/
│	└── vmt_lightbars/
├── stream/
├── UI/
├── UTIL/
├── fxmanifest.lua
├── SETTINGS.lua
└── SIRENS.lua
```

## Luxart Fxmanifest Does Not Need Changes

