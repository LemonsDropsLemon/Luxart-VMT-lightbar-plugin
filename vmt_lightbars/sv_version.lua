--[[
---------------------------------------------------
LUXART VEHICLE CONTROL V3 (FOR FIVEM)
---------------------------------------------------
PLUGIN: vmt_lightbars
FILE: sv_version.lua
---------------------------------------------------
]]

local plugin_name    = 'vmt_lightbars'
local plugin_version = '1.0.0'

RegisterServerEvent('lvc:plugins_getVersions')
AddEventHandler('lvc:plugins_getVersions', function()
    TriggerEvent('lvc:plugins_storePluginVersion', plugin_name, plugin_version)
end)
