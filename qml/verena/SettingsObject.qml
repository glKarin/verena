import QtQuick 1.1

QtObject{
	id: root;
	property int defaultPlayer:vut.getSetting("default_player");
	onDefaultPlayerChanged:{
		vut.setSetting("default_player", defaultPlayer);
	}
	property bool fullScreen:vut.getSetting("fullscreen");
	onFullScreenChanged:{
		vut.setSetting("fullscreen", fullScreen);
		//app.showStatusBar = !fullScreen;
	}
	property int externalPlayer:vut.getSetting("external_player");
	onExternalPlayerChanged:{
		vut.setSetting("external_player", externalPlayer);
	}
	property int cardCountOfLine:vut.getSetting("card_count_of_line");
	onCardCountOfLineChanged:{
		vut.setSetting("card_count_of_line", cardCountOfLine);
	}
	property bool playerCorner:vut.getSetting("player_corner");
	onPlayerCornerChanged:{
		vut.setSetting("player_corner", playerCorner);
	}
	property string userAgent:vut.getSetting("user_agent");
	onUserAgentChanged:{
		vut.setSetting("user_agent", userAgent);
		vut.setUserAgent();
	}
	//browser
	property bool browserAutoLoadImage:vut.getSetting("browser_autoload_image");
	onBrowserAutoLoadImageChanged:{
		vut.setSetting("browser_autoload_image", browserAutoLoadImage);
	}
	property bool browserAutoParseVideo:vut.getSetting("browser_autoparse_video");
	onBrowserAutoParseVideoChanged:{
		vut.setSetting("browser_autoparse_video", browserAutoParseVideo);
	}
	property bool browserHtml5OfflineLocalStorage:vut.getSetting("browser_html5_offlineLocalStorage");
	onBrowserHtml5OfflineLocalStorageChanged:{
		vut.setSetting("browser_html5_offlineLocalStorage", browserHtml5OfflineLocalStorage);
	}
	property bool vthomeLockOrientation:vut.getSetting("verenatouchhome_lock_orientation");
	onVthomeLockOrientationChanged:{
		vut.setSetting("verenatouchhome_lock_orientation", vthomeLockOrientation);
	}
	property bool browserHelper:vut.getSetting("browser_helper");
	onBrowserHelperChanged:{
		vut.setSetting("browser_helper", browserHelper);
	}

	property string youku_ccode: vut.getSetting("youku/ccode");
	onYouku_ccodeChanged: {
		vut.setSetting("youku/ccode", youku_ccode);
	}
	property string youku_client_ip: vut.getSetting("youku/client_ip");
	onYouku_client_ipChanged: {
		vut.setSetting("youku/client_ip", youku_client_ip);
	}
	property string youku_ckey: vut.getSetting("youku/ckey");
	onYouku_ckeyChanged: {
		vut.setSetting("youku/ckey", youku_ckey);
	}
	property string youku_ua: vut.getSetting("youku/ua");
	onYouku_uaChanged: vut.setSetting("youku/ua", youku_ua);
	property string youku_referer: vut.getSetting("youku/referer");
	onYouku_refererChanged: vut.setSetting("youku/referer", youku_referer);

	property bool youkuVideoUrlLoadOnce: vut.getSetting("youku_video_url_load_once");
	onYoukuVideoUrlLoadOnceChanged: vut.setSetting("youku_video_url_load_once", youkuVideoUrlLoadOnce);

	property int playerOrientation: vut.getSetting("player_orientation");
	onPlayerOrientationChanged:{
		vut.setSetting("player_orientation", playerOrientation);
	}
}
