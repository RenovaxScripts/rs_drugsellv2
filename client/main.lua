if Config.Framework == 'esx' then
    local ESX = exports['es_extended']:getSharedObject()

    AddEventHandler('esx:playerLoaded', function() end)
    AddEventHandler('esx:setJob', function() end)
elseif Config.Framework == 'qbcore' then
    local QBCore = exports['qb-core']:GetCoreObject()

    AddEventHandler('QBCore:Client:OnPlayerLoaded', function() end)
    AddEventHandler('QBCore:Client:OnJobUpdate', function() end)
end

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 200) then
            RS.CloseUI()
        end
    end
end)

if Config.Debug then
    RegisterCommand('drugsell_debug', function()
        local drugs = RS.GetDrugsInInventory()
        print('^3[rs_drugsell2 Debug]^7')
        print('Inventory system: ' .. tostring(RS.invSystem))
        print('Interaction: ' .. Config.Interaction)
        for k, v in pairs(drugs) do
            print(' - ' .. k .. ': ' .. v.count)
        end
    end, false)

    RegisterCommand('drugsell_openui', function()
        local buyer = Config.NearbyPed.buyers[1]
        RS.OpenUI(nil, {
            name  = buyer.name,
            label = buyer.label,
            quote = buyer.quotes[1],
        })
    end, false)
end
