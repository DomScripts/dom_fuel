fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
	"@ox_lib/init.lua",
	'config.lua',
	'data.lua'
}

client_scripts {
    'client.lua',
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	'server.lua',
}