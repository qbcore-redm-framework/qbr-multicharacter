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
    'html/style.css',
    'html/reset.css',
    'html/script.js',
    'html/qbus-logo.png'
}

dependencies {
    'qbr-core',
    'qbr-spawn'
}
