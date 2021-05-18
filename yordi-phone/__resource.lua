
ui_page 'html/index.html'

files {
	'html/index.html',
	'html/static/css/app.css',
	'html/static/js/app.js',
	'html/static/js/manifest.js',
	'html/static/js/vendor.js',
	'html/static/config/config.json',

	'html/static/img/coque/yordi-coque.png',
	'html/static/img/background/back001.jpg',
	'html/static/img/background/back002.jpg',
	'html/static/img/background/back003.jpg',
	
	'/html/static/img/general/account.png',
	'html/static/img/courbure.png',
	'html/static/fonts/fontawesome-webfont.ttf',

	'html/static/sound/call.mp3',
	'html/static/sound/call_sound.mp3',

	'html/static/img/icons_app/call.png',
	'html/static/img/icons_app/contacts.png',
	'html/static/img/icons_app/sms.png',
	'html/static/img/icons_app/settings.png',
	'html/static/img/icons_app/menu.png',
	'html/static/img/icons_app/bourse.png',
	'html/static/img/icons_app/tchat.png',
	'html/static/img/icons_app/photo.png',
	'html/static/img/icons_app/bank.png',
	'html/static/img/icons_app/9gag.png',
	'html/static/img/icons_app/twitter.png',
	'html/static/img/icons_app/ad.png',
	'html/static/img/icons_app/news.png',
	'html/static/img/icons_app/games.png',

	'html/static/img/applications/twitter/default.png',
	'html/static/img/applications/ad/default.png',
	'html/static/img/applications/games/clickgame.png',
	'html/static/img/applications/games/colorgame.png',
	'html/static/img/applications/games/tetrisgame.png',
	'html/static/img/applications/games/xoxgame.png',

	'html/static/sound/twitter_sound.ogg',
	'html/static/sound/ad_sound.ogg',
	'html/static/sound/news_sound.ogg',

	'html/static/img/icons_app/lspd.png',
	'html/static/img/icons_app/lsems.png',

	-- Font:
	'html/static/font/circular-bold.ttf',
	'html/static/font/circular-normal.ttf',
	'html/static/font/gilroy-bold.ttf',
	'html/static/font/gilroy-extra.otf',
	'html/static/font/gilroy-normal.ttf',

}

client_script {
	"yordi-config.lua",
	
	"client/yordi-animation.lua",
	"client/yordi-client.lua",
	"client/yordi-photo.lua",
	"client/yordi-bank.lua",
	"client/yordi-twitter.lua",
	"client/yordi-ad.lua",
	"client/yordi-news.lua"
}

server_script {
	'@mysql-async/lib/MySQL.lua',
	"yordi-config.lua",

	"server/yordi-server.lua",
	"server/yordi-twitter.lua",
	"server/yordi-bank.lua",
	"server/yordi-ad.lua",
	"server/yordi-news.lua"
}  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--