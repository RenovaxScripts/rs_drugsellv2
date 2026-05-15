fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Renovax Scripts | GoldenMeow'
description '[FREE] Drug sell V2'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/cs.lua',
    'locales/en.lua',
}

client_scripts {
    'bridge/framework_cl.lua',
    'bridge/inventory_cl.lua',
    'client/main.lua',
    'client/interactions.lua',
    'client/ui.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server_config.lua',
    'bridge/framework_sv.lua',
    'bridge/inventory_sv.lua',
    'server/webhook.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'ox_lib',
    'oxmysql',
}
