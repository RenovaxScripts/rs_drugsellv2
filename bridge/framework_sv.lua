RS = RS or {}

if Config.Framework == 'esx' then
    local ESX = exports['es_extended']:getSharedObject()

    function RS.GetPlayer(source)
        return ESX.GetPlayerFromId(source)
    end

    function RS.GetIdentifier(source)
        local p = ESX.GetPlayerFromId(source)
        return p and p.identifier or nil
    end

    function RS.GetPlayerName(source)
        local p = ESX.GetPlayerFromId(source)
        return p and p.getName() or 'Unknown'
    end

    function RS.AddMoney(source, method, amount)
        local p = ESX.GetPlayerFromId(source)
        if not p then return false end
        if method == 'cash' then
            p.addMoney(amount)
        elseif method == 'bank' then
            p.addAccountMoney('bank', amount)
        elseif method == 'black_money' then
            p.addAccountMoney('black_money', amount)
        end
        return true
    end
elseif Config.Framework == 'qbcore' then
    local QBCore = exports['qb-core']:GetCoreObject()

    function RS.GetPlayer(source)
        return QBCore.Functions.GetPlayer(source)
    end

    function RS.GetIdentifier(source)
        local p = QBCore.Functions.GetPlayer(source)
        return p and p.PlayerData.citizenid or nil
    end

    function RS.GetPlayerName(source)
        local p = QBCore.Functions.GetPlayer(source)
        if p then
            return p.PlayerData.charinfo.firstname .. ' ' .. p.PlayerData.charinfo.lastname
        end
        return 'Unknown'
    end

    function RS.AddMoney(source, method, amount)
        local p = QBCore.Functions.GetPlayer(source)
        if not p then return false end
        local qbMethod = method == 'black_money' and 'cash' or method
        p.Functions.AddMoney(qbMethod, amount, 'drug-sell')
        return true
    end
end

function RS.Debug(...)
    if Config.Debug then
        print('^3[rs_drugsell2]^7', ...)
    end
end
