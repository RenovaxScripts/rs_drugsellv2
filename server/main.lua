local globalCooldowns = {}

local function GetXPData(identifier, cb)
    MySQL.single('SELECT xp, level, total_sales, total_earned FROM rs_drugsell_xp WHERE identifier = ?',
        { identifier },
        function(row)
            cb(row or { xp = 0, level = 1, total_sales = 0, total_earned = 0 })
        end
    )
end

local function CalcLevel(xp)
    local currentLevel = 1
    for lvl, data in pairs(Config.XP.levels) do
        if xp >= data.xpRequired and lvl > currentLevel then
            currentLevel = lvl
        end
    end
    return currentLevel
end

local function SaveXP(identifier, xp, level, totalSales, totalEarned)
    MySQL.insert(
        [[INSERT INTO rs_drugsell_xp (identifier, xp, level, total_sales, total_earned)
          VALUES (?, ?, ?, ?, ?)
          ON DUPLICATE KEY UPDATE xp=VALUES(xp), level=VALUES(level),
          total_sales=VALUES(total_sales), total_earned=VALUES(total_earned)]],
        { identifier, xp, level, totalSales, totalEarned }
    )
end

local function TriggerPoliceAlert(source, coords, item)
    if not Config.Police.enabled then return end
    RS.LogPolice(source, coords, item)

    if Config.Police.dispatch == 'ps-dispatch' then
        TriggerEvent('ps-dispatch:server:notify', {
            message  = Config.Police.alertMessage,
            coords   = coords,
            job      = Config.Police.jobNames,
            blip     = { sprite = Config.Police.blipSprite, colour = Config.Police.blipColor, scale = Config.Police.blipScale },
            duration = Config.Police.alertDuration,
        })
    elseif Config.Police.dispatch == 'cd_dispatch' then
        TriggerEvent('cd_dispatch:CreateDispatchCall', {
            message    = Config.Police.alertMessage,
            coords     = { x = coords.x, y = coords.y, z = coords.z },
            jobs       = Config.Police.jobNames,
            blipSprite = Config.Police.blipSprite,
            blipColour = Config.Police.blipColor,
        })
    elseif Config.Police.dispatch == 'lspd_dispatch' then
        exports['lspd_dispatch']:addJob(source, 48, Config.Police.alertMessage)
    elseif Config.Police.dispatch == 'print' then
        print(Config.Police.alertMessage)
    else
        local players = GetPlayers()
        for _, pid in ipairs(players) do
            local p = RS.GetPlayer(tonumber(pid))
            if p then
                local job = Config.Framework == 'esx' and p.job and p.job.name
                    or (Config.Framework == 'qbcore' and p.PlayerData.job and p.PlayerData.job.name)
                if job then
                    for _, allowedJob in ipairs(Config.Police.jobNames) do
                        if job == allowedJob then
                            TriggerClientEvent('rs_drugsell2:client:policeNotify', tonumber(pid), {
                                message = Config.Police.alertMessage,
                                coords  = coords,
                            })
                            break
                        end
                    end
                end
            end
        end
    end
end

local function SendFail(source, reason, extra)
    local payload = { success = false, reason = reason }
    for k, v in pairs(extra or {}) do payload[k] = v end
    TriggerClientEvent('rs_drugsell2:client:result', source, payload)
end

RegisterNetEvent('rs_drugsell2:server:sell', function(data)
    local source = source

    local ok, err = pcall(function()
        if type(data) ~= 'table' or not data.item or not data.quantity or not data.price then
            RS.Debug('Invalid sell data from', source)
            SendFail(source, 'invalid_data')
            return
        end

        local item     = tostring(data.item)
        local quantity = math.floor(tonumber(data.quantity) or 0)
        local price    = math.floor(tonumber(data.price) or 0)
        local chance   = math.floor(tonumber(data.chance) or 0)
        local coords   = data.coords

        local drugData = Config.Drugs[item]
        if not drugData then
            RS.Debug('Unknown drug:', item, 'from', source)
            SendFail(source, 'invalid_item')
            return
        end

        if quantity < (drugData.minQuantity or 1) or quantity > drugData.maxUnits then
            RS.Debug('Invalid quantity:', quantity, 'for', item)
            SendFail(source, 'invalid_quantity')
            return
        end

        if price < drugData.priceMin or price > drugData.priceMax then
            RS.Debug('Invalid price:', price, 'for', item)
            SendFail(source, 'invalid_price')
            return
        end

        chance = math.max(0, math.min(100, chance))

        local identifier = RS.GetIdentifier(source)
        if not identifier then
            RS.Debug('GetIdentifier failed for source', source)
            SendFail(source, 'identifier_error')
            return
        end

        local now = os.time()
        if globalCooldowns[identifier] and (now - globalCooldowns[identifier]) < Config.Cooldowns.global then
            RS.Debug('Global cooldown for', identifier)
            SendFail(source, 'cooldown')
            return
        end
        globalCooldowns[identifier] = now

        local serverCount = RS.GetItemCountSv(source, item)
        if serverCount < quantity then
            SendFail(source, 'not_enough', { item = item })
            return
        end

        local roll    = math.random(1, 100)
        local success = roll <= chance
        RS.Debug(('Sell roll: %d vs %d → %s'):format(roll, chance, tostring(success)))

        if success then
            local removed = RS.RemoveItem(source, item, quantity)
            if not removed then
                RS.Debug('RemoveItem failed for', source, item, quantity)
                SendFail(source, 'remove_failed')
                return
            end

            local tax   = Config.Economy.taxRate or 0
            local total = math.floor(price * quantity * (1 - tax / 100))

            RS.AddMoney(source, Config.Economy.paymentMethod, total)

            local xpGained = 0
            if Config.XP.enabled then
                xpGained = Config.XP.xpPerSale + (quantity * Config.XP.xpPerUnit)
                GetXPData(identifier, function(xpRow)
                    local newXP    = xpRow.xp + xpGained
                    local newLevel = CalcLevel(newXP)
                    local levelled = newLevel > xpRow.level
                    SaveXP(identifier, newXP, newLevel, xpRow.total_sales + 1, xpRow.total_earned + total)

                    TriggerClientEvent('rs_drugsell2:client:result', source, {
                        success  = true,
                        total    = total,
                        xp       = xpGained,
                        levelled = levelled,
                        newLevel = newLevel,
                        chance   = chance,
                    })
                end)
            else
                TriggerClientEvent('rs_drugsell2:client:result', source, {
                    success = true,
                    total   = total,
                    xp      = 0,
                    chance  = chance,
                })
            end

            RS.LogSale(source, item, quantity, price, total, chance)

            local policeDrug = drugData.policeChance or 0
            if Config.Police.enabled and policeDrug > 0 and math.random(1, 100) <= policeDrug then
                local alertCoords
                if coords and coords.x then
                    alertCoords = vector3(coords.x, coords.y, coords.z)
                else
                    alertCoords = GetEntityCoords(GetPlayerPed(source))
                end
                TriggerPoliceAlert(source, alertCoords, item)
                TriggerClientEvent('rs_drugsell2:client:policeAlert', source)
            end
        else
            RS.LogFail(source, item, quantity, chance)
            TriggerClientEvent('rs_drugsell2:client:result', source, {
                success = false,
                reason  = 'failed',
                chance  = chance,
            })
        end
    end)

    if not ok then
        print('^1[rs_drugsell2] Sell handler error:^7', tostring(err))
        SendFail(source, 'server_error')
    end
end)

RegisterNetEvent('rs_drugsell2:server:getXP', function()
    local source = source
    if not Config.XP.enabled then
        TriggerClientEvent('rs_drugsell2:client:xpData', source, { xp = 0, level = 1 })
        return
    end
    local identifier = RS.GetIdentifier(source)
    if not identifier then
        TriggerClientEvent('rs_drugsell2:client:xpData', source, { xp = 0, level = 1 })
        return
    end
    GetXPData(identifier, function(row)
        TriggerClientEvent('rs_drugsell2:client:xpData', source, row)
    end)
end)

CreateThread(function()
    while true do
        Wait(600000)
        local now = os.time()
        for id, ts in pairs(globalCooldowns) do
            if (now - ts) > Config.Cooldowns.global * 2 then
                globalCooldowns[id] = nil
            end
        end
    end
end)
