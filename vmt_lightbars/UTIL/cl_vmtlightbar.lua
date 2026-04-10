--[[
---------------------------------------------------
LUXART VEHICLE CONTROL V3 (FOR FIVEM)
---------------------------------------------------
PLUGIN: vmt_lightbars
FILE: cl_vmtlightbar.lua
PURPOSE: Attach/detach physical lightbar prop objects
based on mod slot 49. Syncs prop lights with LVC.
---------------------------------------------------
]]
if not vmtlb_masterswitch then return end

VMTLB = {}
VMTLB.enabled         = true   -- toggled via RageUI menu
VMTLB.attachedProps   = {}     -- [vehHandle] = propHandle
VMTLB.currentMod      = {}     -- [vehHandle] = modIndex
VMTLB.lastLightState  = {}     -- [vehHandle] = bool

-- ──────────────────────────────────────────────
-- Internal helpers
-- ──────────────────────────────────────────────

local function getLightbarMod(veh)
    if not veh or veh == 0 or not DoesEntityExist(veh) then return nil end
    local mod = GetVehicleMod(veh, 49)
    if mod == nil or mod < 0 then return nil end
    return tonumber(mod)
end

local function requestModelSync(modelHash, timeoutMs)
    RequestModel(modelHash)
    local elapsed = 0
    while not HasModelLoaded(modelHash) do
        Wait(50)
        elapsed = elapsed + 50
        if elapsed >= (timeoutMs or 5000) then
            UTIL:Print('[VMT Lightbars] Model request timed out: ' .. modelHash, true)
            return false
        end
    end
    return true
end

local function getLightbarBone(veh)
    local idx = GetEntityBoneIndexByName(veh, 'misc_1')
    return (idx ~= -1) and idx or nil
end

-- Sync the prop vehicle's siren lights to match the parent vehicle state
local function syncPropLights(propVeh, lightsOn)
    if not propVeh or not DoesEntityExist(propVeh) then return end
    SetVehicleHasMutedSirens(propVeh, true)
    SetVehicleSiren(propVeh, lightsOn and true or false)
    SetEntityVisible(propVeh, true, 0)
    SetEntityAlpha(propVeh, 255, false)
end

-- Remove the attached prop for a given vehicle
function VMTLB:RemoveAttachedProp(veh)
    local prop = self.attachedProps[veh]
    if prop and DoesEntityExist(prop) then
        syncPropLights(prop, false)
        DeleteEntity(prop)
    end
    self.attachedProps[veh]  = nil
    self.currentMod[veh]     = nil
    self.lastLightState[veh] = nil
end

-- Attach the correct lightbar prop to a vehicle based on mod slot 49
function VMTLB:AttachToVehicle(veh, modIndex)
    if not VMTLB.enabled then return end
    if not veh or veh == 0 or not DoesEntityExist(veh) then return end

    local modelName = VMT_LIGHTBAR_MODELS[modIndex]
    if not modelName then return end

    local modelHash = GetHashKey(modelName)
    if not IsModelInCdimage(modelHash) then
        UTIL:Print('[VMT Lightbars] Model not in cdimage: ' .. modelName, true)
        return
    end

    local boneIdx = getLightbarBone(veh)
    if not boneIdx then return end

    -- Remove any existing prop first
    self:RemoveAttachedProp(veh)

    if not requestModelSync(modelHash, 5000) then return end

    -- Guard: vehicle may have been deleted while we were loading the model
    if not DoesEntityExist(veh) then
        SetModelAsNoLongerNeeded(modelHash)
        return
    end

    local coords = GetEntityCoords(veh)
    local prop   = CreateVehicle(modelHash, coords.x, coords.y, coords.z, GetEntityHeading(veh), false, false)
    SetModelAsNoLongerNeeded(modelHash)

    if not prop or prop == 0 or not DoesEntityExist(prop) then return end

    -- Configure the prop vehicle
    SetVehicleEngineOn(prop, true, true, false)
    SetVehicleHasMutedSirens(prop, true)
    SetVehicleHasMutedSirens(veh, true)
    SetDisableVehiclePetrolTankDamage(prop, true)
    SetDisableVehiclePetrolTankFires(prop, true)
    SetDisableVehicleEngineFires(prop, true)
    SetVehicleExplodesOnHighExplosionDamage(prop, false)
    -- Bullet proof, fire proof, explosion proof, etc.
    SetEntityProofs(prop, false, false, true, false, false, false, false, false)

    AttachEntityToEntity(
        prop, veh, boneIdx,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        false, false, false, false, 2, true
    )

    self.attachedProps[veh]  = prop
    self.currentMod[veh]     = modIndex

    -- Sync initial light state
    local lightsOn = IsVehicleSirenOn(veh)
    syncPropLights(prop, lightsOn)
    self.lastLightState[veh] = lightsOn
end

-- Called when the player enters a new vehicle (lvc:onVehicleChange)
function VMTLB:OnVehicleChange()
    if not player_is_emerg_driver or not veh or veh == 0 then return end
    local mod = getLightbarMod(veh)
    if mod and VMT_LIGHTBAR_MODELS[mod] then
        self:AttachToVehicle(veh, mod)
    end
end

-- ──────────────────────────────────────────────
-- LVC vehicle change event
-- ──────────────────────────────────────────────
RegisterNetEvent('lvc:onVehicleChange')
AddEventHandler('lvc:onVehicleChange', function()
    VMTLB:OnVehicleChange()
end)

-- ──────────────────────────────────────────────
-- Nearby vehicle scanner — attaches props to
-- other players' vehicles within scan range
-- ──────────────────────────────────────────────
local function scanNearbyVehicles()
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local range  = VMT_SCAN_RANGE * VMT_SCAN_RANGE  -- compare squared distances

    local pool = GetGamePool('CVehicle')
    for i = 1, #pool do
        local nearVeh = pool[i]
        if nearVeh and nearVeh ~= 0 and DoesEntityExist(nearVeh) then
            local dist = #(coords - GetEntityCoords(nearVeh))
            if dist <= VMT_SCAN_RANGE then
                local mod = getLightbarMod(nearVeh)
                if mod and VMT_LIGHTBAR_MODELS[mod] then
                    SetVehicleHasMutedSirens(nearVeh, true)
                    if not VMTLB.attachedProps[nearVeh] then
                        VMTLB:AttachToVehicle(nearVeh, mod)
                    end
                end
            end
        end
    end
end

-- ──────────────────────────────────────────────
-- Main maintenance loop
-- ──────────────────────────────────────────────
CreateThread(function()
    local lastScan = 0

    while true do
        local hasAttached = next(VMTLB.attachedProps) ~= nil
        Wait(hasAttached and VMT_CHECK_INTERVAL or 500)

        if not VMTLB.enabled then
            -- If plugin disabled, clean up all props
            if hasAttached then
                for attachedVeh in pairs(VMTLB.attachedProps) do
                    VMTLB:RemoveAttachedProp(attachedVeh)
                end
            end
        else
            -- Scan nearby vehicles periodically
            local now = GetGameTimer()
            if (now - lastScan) >= VMT_SCAN_INTERVAL then
                lastScan = now
                scanNearbyVehicles()
            end

            -- Reconcile: sync lights, remove stale props, handle mod changes
            for attachedVeh, prop in pairs(VMTLB.attachedProps) do
                if not DoesEntityExist(attachedVeh) then
                    -- Vehicle gone
                    if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
                    VMTLB.attachedProps[attachedVeh]  = nil
                    VMTLB.currentMod[attachedVeh]     = nil
                    VMTLB.lastLightState[attachedVeh] = nil
                else
                    local curMod = getLightbarMod(attachedVeh)

                    -- Mod changed — reattach with new model (or remove if no longer lightbar)
                    if curMod ~= VMTLB.currentMod[attachedVeh] then
                        VMTLB:RemoveAttachedProp(attachedVeh)
                        if curMod and VMT_LIGHTBAR_MODELS[curMod] then
                            VMTLB:AttachToVehicle(attachedVeh, curMod)
                        end
                    else
                        -- Keep muting the parent vehicle siren so GTA audio doesn't conflict
                        SetVehicleHasMutedSirens(attachedVeh, true)

                        -- Sync lights if state changed
                        local lightsOn = IsVehicleSirenOn(attachedVeh)
                        if lightsOn ~= VMTLB.lastLightState[attachedVeh] then
                            VMTLB.lastLightState[attachedVeh] = lightsOn
                            if prop and DoesEntityExist(prop) then
                                syncPropLights(prop, lightsOn)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ──────────────────────────────────────────────
-- Cleanup on resource stop
-- ──────────────────────────────────────────────
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, prop in pairs(VMTLB.attachedProps) do
        if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    end
end)
