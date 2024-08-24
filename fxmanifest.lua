fx_version 'bodacious'
game 'gta5'

name 'vCAD UI - ESX Version'
author 'Ffrankys, Flixxx, Tallerik & Mîhó'
version '2.0.1'

client_scripts {
    '@NativeUI/NativeUI.lua',
	'config/config.lua',
    'config/config_esx_qb.lua',
    'config/zonen.lua',
    
	'client/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/config.lua',
    'config/config_esx_qb.lua',
    'config/zonen.lua',

    'server/server.lua',
    'server/items.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/functions.js',
    'nui/main.css',
    'nui/new.css',
    'nui/tablet.png'
}
