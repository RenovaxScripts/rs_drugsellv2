RS = RS or {}

function RS.L(key, vars)
    if not Lang or not Lang[key] then return key end
    local str = Lang[key]
    if vars then
        for k, v in pairs(vars) do
            str = str:gsub('{' .. k .. '}', tostring(v))
        end
    end
    return str
end

function RS.Notify(msg, ntype, duration)
    lib.notify({
        title       = 'Drug Sell',
        description = msg,
        type        = ntype or 'inform',
        duration    = duration or 4000,
    })
end

if Config.Framework == 'esx' then
    local ESX = exports['es_extended']:getSharedObject()

    function RS.GetPlayerData()
        return ESX.GetPlayerData()
    end
elseif Config.Framework == 'qbcore' then
    local QBCore = exports['qb-core']:GetCoreObject()

    function RS.GetPlayerData()
        return QBCore.Functions.GetPlayerData()
    end
end

function RS.Debug(...)
    if Config.Debug then
        print('^3[rs_drugsell2]^7', ...)
    end
end
