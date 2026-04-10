--[[
---------------------------------------------------
LUXART VEHICLE CONTROL V3 (FOR FIVEM)
---------------------------------------------------
PLUGIN: vmt_lightbars
FILE: cl_ragemenu.lua
---------------------------------------------------
]]
if not vmtlb_masterswitch then return end

-- Register the submenu under the plugins parent menu
RMenu.Add('lvc', 'vmtlbsettings', RageUI.CreateSubMenu(RMenu:Get('lvc', 'plugins'), ' ', Lang:t('plugins.menu_vmtlb'), 0, 0, "lvc", "lvc_plugin_logo"))
RMenu:Get('lvc', 'vmtlbsettings'):DisplayGlare(false)

CreateThread(function()
    Wait(1000)
    while true do
        RageUI.IsVisible(RMenu:Get('lvc', 'vmtlbsettings'), function()

            -- Enable / Disable toggle
            RageUI.Checkbox(
                Lang:t('menu.enabled'),
                Lang:t('plugins.vmtlb_enabled_desc'),
                VMTLB.enabled, {}, {
                    onChecked = function()
                        VMTLB.enabled = true
                        if player_is_emerg_driver and veh and veh ~= 0 then
                            VMTLB:OnVehicleChange()
                        end
                    end,
                    onUnChecked = function()
                        VMTLB.enabled = false
                    end,
                }
            )

            RageUI.Separator(Lang:t('plugins.vmtlb_info_separator'))

            -- Read-only: current lightbar model name
            local modIndex   = (veh and veh ~= 0) and GetVehicleMod(veh, 49) or -1
            local modelName  = (modIndex and VMT_LIGHTBAR_MODELS[modIndex]) or Lang:t('plugins.vmtlb_no_lightbar')
            RageUI.Button(
                Lang:t('plugins.vmtlb_current_model'),
                Lang:t('plugins.vmtlb_current_model_desc'),
                { RightLabel = modelName, Enabled = false }, false, {}
            )

        end)
        Wait(0)
    end
end)
