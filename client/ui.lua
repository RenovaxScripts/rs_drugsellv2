local uiOpen      = false
local pendingSell = nil

local function SendLocale()
    SendNUIMessage({ action = 'setLocale', lang = Lang })
end

local ANIM_DICT_GIVE = 'mp_common'
local ANIM_CLIP_GIVE = 'givetake1_a'
local ANIM_DICT_GET  = 'mp_common'
local ANIM_CLIP_GET  = 'givetake1_b'

local function PlayExchangeAndLeave(pedEntity, onDone)
    local playerPed = PlayerPedId()

    CreateThread(function()
        lib.requestAnimDict(ANIM_DICT_GIVE)
        lib.requestAnimDict(ANIM_DICT_GET)

        TaskPlayAnim(playerPed, ANIM_DICT_GIVE, ANIM_CLIP_GIVE,
            8.0, -8.0, 3000, 49, 0, false, false, false)

        if pedEntity and DoesEntityExist(pedEntity) then
            TaskPlayAnim(pedEntity, ANIM_DICT_GET, ANIM_CLIP_GET,
                8.0, -8.0, 3000, 49, 0, false, false, false)
        end

        Wait(3000)

        StopAnimTask(playerPed, ANIM_DICT_GIVE, ANIM_CLIP_GIVE, 1.0)

        if pedEntity and DoesEntityExist(pedEntity) then
            StopAnimTask(pedEntity, ANIM_DICT_GET, ANIM_CLIP_GET, 1.0)
            RS.RestorePed(pedEntity, true)
        end

        if onDone then onDone() end
    end)
end

function RS.OpenUI(ped, buyer)
    if uiOpen then return end

    local drugs = RS.GetDrugsInInventory()
    if not next(drugs) then
        RS.Notify(RS.L('notify_no_drugs'), 'error')
        if ped then RS.RestorePed(ped, false) end
        return
    end

    pendingSell = { ped = ped, buyer = buyer }

    TriggerServerEvent('rs_drugsell2:server:getXP')

    local drugList = {}
    for itemName, d in pairs(drugs) do
        local cfg = Config.Drugs[itemName]
        table.insert(drugList, {
            item             = itemName,
            label            = cfg.label,
            count            = d.count,
            basePrice        = cfg.basePrice,
            priceMin         = cfg.priceMin,
            priceMax         = cfg.priceMax,
            baseChance       = cfg.baseChance,
            chancePerExtra   = cfg.chancePerExtra,
            priceChanceBonus = cfg.priceChanceBonus or 15,
            maxUnits         = cfg.maxUnits,
            dayBonus         = cfg.dayBonus,
            nightBonus       = cfg.nightBonus,
            minQuantity      = cfg.minQuantity,
        })
    end

    local hour = GetClockHours()
    local isDay = hour >= 6 and hour < 20

    SendLocale()
    SendNUIMessage({
        action = 'open',
        buyer  = buyer,
        drugs  = drugList,
        isDay  = isDay,
        config = { animationsEnabled = Config.NUI.animationsEnabled },
    })

    uiOpen = true
    SetNuiFocus(true, true)
end

function RS.CloseUI(restorePed)
    if not uiOpen then return end
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    -- Vyresetůj pendingPedCooldown pokud herníč zavřel UI bez nabídnutí
    if pendingPedCooldown then
        pendingPedCooldown = nil
    end

    if restorePed ~= false and pendingSell and pendingSell.ped then
        RS.RestorePed(pendingSell.ped, false)
    end

    pendingSell = nil
end

RegisterNUICallback('close', function(_, cb)
    RS.CloseUI(true)
    cb('ok')
end)

RegisterNUICallback('makeoffer', function(data, cb)
    cb('ok')

    if not pendingSell then return end

    local item     = data.item
    local quantity = tonumber(data.quantity) or 1
    local price    = tonumber(data.price) or 0
    local chance   = tonumber(data.chance) or 0

    local drugCfg  = Config.Drugs[item]
    if not drugCfg then return end

    quantity           = math.max(drugCfg.minQuantity, math.min(quantity, drugCfg.maxUnits))
    price              = math.max(drugCfg.priceMin, math.min(price, drugCfg.priceMax))
    chance             = math.max(0, math.min(chance, 100))

    local sellPed      = pendingSell.ped
    local sellItem     = item
    local sellQuantity = quantity
    local sellPrice    = price
    local sellChance   = chance

    RS.CloseUI(false)

    RS.Notify(RS.L('notify_selling'), 'inform', 2000)

    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('rs_drugsell2:server:sell', {
        item     = sellItem,
        quantity = sellQuantity,
        price    = sellPrice,
        chance   = sellChance,
        coords   = { x = coords.x, y = coords.y, z = coords.z },
        _ped     = sellPed,
    })

    pendingPedCooldown = sellPed
    _lastSellPed       = sellPed
end)

_lastSellPed = nil

RegisterNetEvent('rs_drugsell2:client:result', function(data)
    -- Ulož ped entitu dřív, než resetujeme _lastSellPed
    local pedEntity = _lastSellPed
    _lastSellPed    = nil

    if pendingPedCooldown then
        RS.MarkPedUsed(pendingPedCooldown)
        pendingPedCooldown = nil
    end

    if data.success then
        PlayExchangeAndLeave(pedEntity, function()
            local formatted = '$' .. (data.total or 0)
            RS.Notify(RS.L('notify_success', { amount = formatted }), 'success')

            if Config.XP.enabled and data.xp and data.xp > 0 then
                RS.Notify(RS.L('xp_gained', { xp = data.xp }), 'inform', 2500)
            end
            if data.levelled then
                RS.Notify(RS.L('xp_levelup', { level = data.newLevel }), 'success', 5000)
            end
        end)
    else
        if pedEntity then
            RS.RestorePed(pedEntity, true)
        end

        if data.reason == 'not_enough' then
            RS.Notify(RS.L('notify_not_enough', { item = data.item or '' }), 'error')
        else
            RS.Notify(RS.L('notify_fail'), 'error')
        end
    end
end)


RegisterNetEvent('rs_drugsell2:client:policeAlert', function()
    RS.Notify(RS.L('notify_police'), 'error', 5000)
end)

RegisterNetEvent('rs_drugsell2:client:policeNotify', function(data)
    lib.notify({
        title       = '🚨 Dispatch',
        description = data.message,
        type        = 'error',
        duration    = Config.Police.alertDuration,
    })
end)


RegisterNetEvent('rs_drugsell2:client:xpData', function(row)
    SendNUIMessage({
        action = 'xpData',
        xp     = row.xp or 0,
        level  = row.level or 1,
        levels = Config.XP.levels,
    })
end)
