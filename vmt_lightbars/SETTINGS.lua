--[[
---------------------------------------------------
LUXART VEHICLE CONTROL V3 (FOR FIVEM)
---------------------------------------------------
PLUGIN: vmt_lightbars

Attaches physical lightbar prop objects to
vehicles based on mod slot 49 index. Syncs prop
lights with LVC siren/light state automatically.
---------------------------------------------------
]]

-- Master switch — set to true to enable this plugin
vmtlb_masterswitch = true

-- How often (ms) the main loop ticks when at least one lightbar is attached
VMT_CHECK_INTERVAL = 100

-- How often (ms) nearby vehicles are scanned to attach props on other players' vehicles
VMT_SCAN_INTERVAL = 500

-- Radius (metres) for the nearby vehicle scan
VMT_SCAN_RANGE = 50.0

-- Mod slot 49 index → lightbar prop model name
-- Add or remove entries to match your server's vehicle pack.
-- The index here must match what the vehicle customisation mod slot 49 returns.
VMT_LIGHTBAR_MODELS = {
    [4]  = 'onx_pol_lbar_mdn1a',
    [5]  = 'onx_pol_lbar_mdn1b_b',
    [6]  = 'onx_pol_lbar_mdn1c',
    [7]  = 'onx_pol_lbar_mdn2a',
    [8]  = 'onx_pol_lbar_os1a',
    [9]  = 'onx_pol_lbar_mdn1c_b',
    [10] = 'onx_pol_lbar_os2b',
    [11] = 'onx_pol_lbar_mdn1a_b',
    [12] = 'onx_pol_lbar_mdn3a',
    [13] = 'onx_pol_lbar_mdn3b',
    [14] = 'onx_ems_lbar_mdn1a',
    [15] = 'onx_ems_lbar_mdn1b',
    [16] = 'onx_ems_lbar_mdn1c',
    [17] = 'onx_amb_lbar_mdn1a',
    [18] = 'onx_amb_lbar_mdn1b',
    [19] = 'onx_amb_lbar_mdn1c',
}
