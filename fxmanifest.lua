fx_version 'cerulean'
game 'gta5'

name 'fgsk-spawnwrapper'
author 'NGA'
version '0.1.0'
description 'FGSK spawn flow built on top of the stock spawnmanager resource'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependency 'spawnmanager'
dependency 'oxmysql'
