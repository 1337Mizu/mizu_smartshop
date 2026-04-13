fx_version 'cerulean'
game 'gta5'

author 'Mizu | MizuScripts'
description 'Mizu Smartshop'
version '1.2.0'

shared_scripts {
    'locales/*.lua',
    'config.lua'
}

server_scripts {
    'server_open.lua'
}

client_scripts {
    'client_open.lua'
}

client_exports {
    'OpenShop',
    'CloseShop'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/js/ped_models.js',
    'html/images/*.png',
    'html/images/*.PNG',
    'html/images/*.jpg',
    'html/images/*.jpeg'
}
