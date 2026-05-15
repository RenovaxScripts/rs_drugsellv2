local trackedPeds  = {}
local pedCooldowns = {}
local pedBuyerMap  = {}
local usedPeds     = {}

pendingPedCooldown = nil
currentInteractPed = nil

local blacklistSet = {}
for _, hash in ipairs(Config.NearbyPed.blacklistModels) do
    blacklistSet[hash] = true
end

local blacklistTypeSet = {}
for _, t in ipairs(Config.NearbyPed.blacklistTypes) do
    blacklistTypeSet[t] = true
end

local function IsPedBlacklisted(ped)
    if blacklistSet[GetEntityModel(ped)] then return true end
    if blacklistTypeSet[GetPedType(ped)] then return true end
    if IsPedAPlayer(ped) then return true end
    if IsPedDeadOrDying(ped, true) then return true end
    return false
end

function RS.MarkPedUsed(entity)
    if not entity then return end
    usedPeds[entity] = true
    if trackedPeds[entity] then
        if Config.Target == 'ox_target' then
            exports.ox_target:removeLocalEntity(entity)
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(entity)
        end
        trackedPeds[entity] = nil
        pedBuyerMap[entity] = nil
    end
    RS.Debug('Ped', entity, 'marked as USED (permanent, this session)')
end

function RS.SetPedCooldown(entity, cdType)
    local dur = cdType == 'success' and Config.Cooldowns.afterSuccess or Config.Cooldowns.afterFail
    pedCooldowns[entity] = { ts = GetGameTimer(), duration = dur * 1000 }
end

local function IsPedAvailable(entity)
    if usedPeds[entity] then return false end
    local cd = pedCooldowns[entity]
    if cd then
        if (GetGameTimer() - cd.ts) < cd.duration then
            return false
        end
        pedCooldowns[entity] = nil
    end
    return true
end

function RS.StopAndFacePed(entity)
    if not entity or not DoesEntityExist(entity) then return end
    currentInteractPed = entity
    SetBlockingOfNonTemporaryEvents(entity, true)
    ClearPedTasksImmediately(entity)
    TaskTurnPedToFaceEntity(entity, PlayerPedId(), 1500)
    CreateThread(function()
        Wait(1600)
        if currentInteractPed == entity and DoesEntityExist(entity) then
            TaskStandStill(entity, 999999)
        end
    end)
end

function RS.RestorePed(entity, walkAway)
    if currentInteractPed == entity then currentInteractPed = nil end
    if not entity or not DoesEntityExist(entity) then return end
    SetBlockingOfNonTemporaryEvents(entity, false)
    ClearPedTasks(entity)
    if walkAway then
        CreateThread(function()
            Wait(500)
            if DoesEntityExist(entity) then TaskWanderStandard(entity, 10.0, 10) end
        end)
    else
        TaskWanderStandard(entity, 10.0, 10)
    end
end

local function GetBuyerForPed(entity)
    if pedBuyerMap[entity] then return pedBuyerMap[entity] end
    local buyers        = Config.NearbyPed.buyers
    local b             = buyers[math.random(1, #buyers)]
    local quote         = b.quotes[math.random(1, #b.quotes)]
    local buyer         = { name = b.name, label = b.label, quote = quote, refusalQuotes = b.refusalQuotes }
    pedBuyerMap[entity] = buyer
    return buyer
end

local function InteractWithPed(entity)
    if not IsPedAvailable(entity) then
        RS.Notify(RS.L('notify_cooldown'), 'error')
        return
    end

    local drugs = RS.GetDrugsInInventory()
    if not next(drugs) then
        RS.Notify(RS.L('notify_no_drugs'), 'error')
        return
    end

    local buyer = GetBuyerForPed(entity)

    local refChance = Config.NearbyPed.refusalChance or 0
    if refChance > 0 and math.random(1, 100) <= refChance then
        RS.StopAndFacePed(entity)

        local refQuotes = buyer.refusalQuotes or { 'Not interested. Keep walking.' }
        local refQuote  = refQuotes[math.random(1, #refQuotes)]
        RS.Notify('🚫 "' .. refQuote .. '"', 'error', 4000)
        RS.MarkPedUsed(entity)
        CreateThread(function()
            Wait(1800)
            RS.RestorePed(entity, true)
        end)

        RS.Debug('NPC', entity, 'REFUSED (refusalChance roll hit)')
        return
    end

    RS.StopAndFacePed(entity)
    pendingPedCooldown = entity
    RS.OpenUI(entity, buyer)
end

if Config.Interaction == 'target' then
    local function AddPedTarget(entity)
        if trackedPeds[entity] or usedPeds[entity] then return end
        trackedPeds[entity] = true

        if Config.Target == 'ox_target' then
            exports.ox_target:addLocalEntity(entity, {
                {
                    name        = 'rs_drugsell_' .. entity,
                    label       = RS.L('interact_label'),
                    icon        = Config.NearbyPed.targetIcon,
                    distance    = Config.NearbyPed.scanRadius,
                    canInteract = function()
                        return IsPedAvailable(entity)
                            and next(RS.GetDrugsInInventory()) ~= nil
                    end,
                    onSelect    = function()
                        InteractWithPed(entity)
                    end,
                }
            })
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:AddTargetEntity(entity, {
                options = {
                    {
                        type   = 'client',
                        event  = 'rs_drugsell2:client:targetInteract',
                        icon   = Config.NearbyPed.targetIcon,
                        label  = RS.L('interact_label'),
                        entity = entity,
                    }
                },
                distance = Config.NearbyPed.scanRadius,
            })
        end
    end

    local function RemovePedTarget(entity)
        if not trackedPeds[entity] then return end
        trackedPeds[entity] = nil
        pedBuyerMap[entity] = nil
        if entity == currentInteractPed then return end

        if Config.Target == 'ox_target' then
            exports.ox_target:removeLocalEntity(entity)
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(entity)
        end
    end

    RegisterNetEvent('rs_drugsell2:client:targetInteract', function(data)
        local entity = data.entity
        if entity and DoesEntityExist(entity) and not IsPedBlacklisted(entity) then
            InteractWithPed(entity)
        end
    end)

    CreateThread(function()
        while true do
            Wait(800)
            local playerPed    = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearbySet    = {}

            for _, ped in ipairs(GetGamePool('CPed')) do
                if ped ~= playerPed
                    and DoesEntityExist(ped)
                    and not IsPedBlacklisted(ped)
                    and not usedPeds[ped] then
                    if #(GetEntityCoords(ped) - playerCoords) <= Config.NearbyPed.scanRadius then
                        nearbySet[ped] = true
                        AddPedTarget(ped)
                    end
                end
            end

            for entity in pairs(trackedPeds) do
                if not nearbySet[entity] and entity ~= currentInteractPed then
                    RemovePedTarget(entity)
                end
            end
        end
    end)
else
    local textUIShowing = false

    local function ShowInteractUI(show)
        if Config.Interaction == 'textui' then
            if show and not textUIShowing then
                lib.showTextUI('[E] ' .. RS.L('interact_label'), {
                    position = 'left-center',
                    icon = 'hand-holding',
                    style = { borderRadius = 2, backgroundColor = '#110000', color = '#ff4545' }
                })
                textUIShowing = true
            elseif not show and textUIShowing then
                lib.hideTextUI()
                textUIShowing = false
            end
        end
    end

    CreateThread(function()
        while true do
            local sleep        = 500
            local playerPed    = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local bestDist     = Config.NearbyPed.scanRadius + 0.1
            local bestPed      = nil

            for _, ped in ipairs(GetGamePool('CPed')) do
                if ped ~= playerPed
                    and DoesEntityExist(ped)
                    and not IsPedBlacklisted(ped)
                    and not usedPeds[ped] then
                    local d = #(GetEntityCoords(ped) - playerCoords)
                    if d < bestDist then
                        bestDist = d; bestPed = ped
                    end
                end
            end

            if bestPed then
                sleep = 0
                if Config.Interaction == 'drawtext' then
                    SetTextFont(0)
                    SetTextProportional(1)
                    SetTextScale(0.0, 0.55)
                    SetTextColour(255, 255, 255, 255)
                    SetTextDropShadow()
                    SetTextOutline()
                    SetTextEntry('STRING')
                    AddTextComponentString('[E] ' .. RS.L('interact_label'))
                    DrawText(0.5, 0.95)
                end
                if IsControlJustPressed(0, Config.NearbyPed.interactKey) then
                    InteractWithPed(bestPed)
                end
                ShowInteractUI(true)
            else
                ShowInteractUI(false)
            end

            Wait(sleep)
        end
    end)
end
