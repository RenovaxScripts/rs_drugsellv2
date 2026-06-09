local invSystem = Config.Inventory

if invSystem == 'auto' then
    if GetResourceState('ox_inventory') == 'started' then
        invSystem = 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        invSystem = 'qb'
    elseif GetResourceState('codem-inventory') == 'started' then
        invSystem = 'codem'
    else
        invSystem = 'ox'
    end
end

RS.invSystem = invSystem

function RS.GetItemCount(item)
    if invSystem == 'ox' then
        return exports.ox_inventory:Search('count', item) or 0
    elseif invSystem == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local playerData = QBCore.Functions.GetPlayerData()
        if not playerData or not playerData.items then return 0 end
        local count = 0
        for _, slot in pairs(playerData.items) do
            if slot and slot.name == item then
                count = count + (slot.amount or 0)
            end
        end
        return count
    elseif invSystem == 'codem' then
        return exports['codem-inventory']:GetItemCount(item) or 0
    end
    return 0
end

function RS.GetDrugsInInventory()
    local found = {}
    for itemName, drugData in pairs(Config.Drugs) do
        local count = RS.GetItemCount(itemName)
        if count > 0 then
            found[itemName] = { count = count, data = drugData }
        end
    end
    return found
end
