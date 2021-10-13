fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'QBR-Multicharacter'
version '1.0.0'

ui_page 'html/index.html'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'html/index.html',
    'html/assets/css/style.css',
    'html/assets/css/reset.css',
    'html/assets/js/script.js',
    'html/assets/img/logo/qbus-logo.png',
    'html/assets/img/button.png',
    'html/assets/img/button1.png',
    'html/assets/img/characterQB2.png',
    'html/assets/img/delete.png',
    'html/assets/img/id.png',
    'html/assets/img/registre2.png'
}

dependencies {
    'qbr-core',
    'qbr-spawn'
}
