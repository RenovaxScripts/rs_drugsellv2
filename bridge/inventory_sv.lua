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

function RS.RemoveItem(source, item, count)
    if invSystem == 'ox' then
        return exports.ox_inventory:RemoveItem(source, item, count)
    elseif invSystem == 'qb' then
        local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
        if Player then
            return Player.Functions.RemoveItem(item, count)
        end
        return false
    elseif invSystem == 'codem' then
        return exports['codem-inventory']:RemoveItem(source, item, count)
    end
    return false
end

function RS.GetItemCountSv(source, item)
    if invSystem == 'ox' then
        local result = exports.ox_inventory:Search(source, 'count', item)
        if type(result) == 'number' then return result end
        if type(result) == 'table' then return result[item] or 0 end
        return 0
    elseif invSystem == 'qb' then
        local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
        if Player then
            local it = Player.Functions.GetItemByName(item)
            return it and it.amount or 0
        end
        return 0
    elseif invSystem == 'codem' then
        return exports['codem-inventory']:GetItemCount(source, item) or 0
    end
    return 0
end
