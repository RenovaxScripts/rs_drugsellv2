local function SendWebhook(data)
    if not ServerConfig.Webhook.url or ServerConfig.Webhook.url == '' then return end
    PerformHttpRequest(ServerConfig.Webhook.url, function(err, text, headers) end, 'POST',
        json.encode(data),
        { ['Content-Type'] = 'application/json' }
    )
end

local function GetTimestamp()
    return os.date('!%Y-%m-%dT%H:%M:%SZ')
end

function RS.LogSale(source, item, quantity, price, total, chance)
    if not ServerConfig.Logging.sales then return end
    local drugData = Config.Drugs[item]
    local name = RS.GetPlayerName(source)
    local id   = RS.GetIdentifier(source) or 'unknown'

    if ServerConfig.Logging.richEmbed then
        SendWebhook({
            username   = ServerConfig.Webhook.name,
            avatar_url = ServerConfig.Webhook.avatar,
            embeds = {{
                title     = '💰 Successful drug sale',
                color     = ServerConfig.Webhook.color,
                timestamp = GetTimestamp(),
                fields = {
                    { name = '👤 Player',    value = string.format('`%s` (ID: %d)', name, source),   inline = true },
                    { name = '🪪 Identifier',value = string.format('`%s`', id),                      inline = true },
                    { name = '💊 Drug',      value = drugData and drugData.label or item,             inline = true },
                    { name = '📦 Quantity',  value = tostring(quantity),                              inline = true },
                    { name = '💵 Price/unit',value = string.format('$%d', price),                    inline = true },
                    { name = '💰 Total',     value = string.format('$%d', total),                    inline = true },
                    { name = '🎲 Chance',    value = string.format('%d%%', chance),                  inline = true },
                },
                footer = { text = 'rs_drugsell2 | ' .. os.date('%d.%m.%Y %H:%M:%S') }
            }}
        })
    else
        SendWebhook({
            username = ServerConfig.Webhook.name,
            content  = string.format('💰 **%s** (ID:%d | %s) sold **%dx %s** for **$%d** (chance: %d%%)',
                name, source, id, quantity, item, total, chance)
        })
    end
end

function RS.LogFail(source, item, quantity, chance)
    if not ServerConfig.Logging.fails then return end
    local name = RS.GetPlayerName(source)
    local id   = RS.GetIdentifier(source) or 'unknown'

    SendWebhook({
        username   = ServerConfig.Webhook.name,
        avatar_url = ServerConfig.Webhook.avatar,
        embeds = {{
            title     = '❌ Failed drug sale attempt',
            color     = 15158332,
            timestamp = GetTimestamp(),
            fields = {
                { name = '👤 Player',   value = string.format('`%s` (ID: %d)', name, source), inline = true },
                { name = '🪪 ID',       value = string.format('`%s`', id),                    inline = true },
                { name = '💊 Drug',     value = item,                                          inline = true },
                { name = '📦 Quantity', value = tostring(quantity),                            inline = true },
                { name = '🎲 Chance',   value = string.format('%d%%', chance),                inline = true },
            },
            footer = { text = 'rs_drugsell2 | ' .. os.date('%d.%m.%Y %H:%M:%S') }
        }}
    })
end

function RS.LogPolice(source, coords, item)
    if not ServerConfig.Logging.policeAlerts then return end
    local name = RS.GetPlayerName(source)

    SendWebhook({
        username   = ServerConfig.Webhook.name,
        avatar_url = ServerConfig.Webhook.avatar,
        embeds = {{
            title     = '🚨 Police Alert - Drug Deal',
            color     = 15548997,
            timestamp = GetTimestamp(),
            fields = {
                { name = '👤 Player',   value = string.format('`%s` (ID: %d)', name, source),                          inline = true },
                { name = '💊 Drug',     value = item,                                                                    inline = true },
                { name = '📍 Location', value = string.format('X:%.1f Y:%.1f Z:%.1f', coords.x, coords.y, coords.z),  inline = false },
            },
            footer = { text = 'rs_drugsell2 | ' .. os.date('%d.%m.%Y %H:%M:%S') }
        }}
    })
end
