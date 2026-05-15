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

---@param item string
---@return number
function RS.GetItemCount(item)
    if invSystem == 'ox' then
        return exports.ox_inventory:Search('count', item) or 0
    elseif invSystem == 'qb' then
        local count = exports['qb-inventory'] and exports['qb-inventory']:GetItemCount(item) or 0
        return count
    elseif invSystem == 'codem' then
        return exports['codem-inventory']:GetItemCount(item) or 0
    end
    return 0
end

---@return table
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
