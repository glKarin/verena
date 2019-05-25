import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import karin.verena 1.5
import karin.verena.dev 1.1
import "../js/main.js" as Script

PageStackWindow{
	id:app;

	QtObject{
		id:settingsObject;
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
	}

	//showStatusBar: inPortrait;
	showStatusBar: (!settingsObject.fullScreen && inPortrait && !mainpage.loading) || (!mainpage.loading && pageStack.currentPage === mainpage);
	initialPage:VerenaTouchHome{ id:mainpage; }
	platformStyle: PageStackWindowStyle {
		cornersVisible: app.inPortrait || settingsObject.playerCorner;
	}

	DeveloperModeDialog{
		id:devmode;
		onAccepted:{
			developer.restart();
		}
	}

	InfoBanner {
		id: infobanner; 
		topMargin: app.showStatusBar ? 50 : 0 + 10;
		leftMargin:5;
		// 2017
	}

	Schemas{
		id:schemas;
		onVideoCategoryMapInitFinished:{
			mainpage.makeVideoSubModel(yes);
		}
		onShowCategoryMapInitFinished:{
			mainpage.makeShowSubModel(yes);
		}
		onPlaylistCategoryListInitFinished:{
			mainpage.makePlaylistSubModel(yes);
		}
	}

	VDeveloper{
		id:developer;
	}

	VPlayer{
		id:vplayer;
		player:settingsObject.externalPlayer;
		onMsgChanged:{
			setMsg(msg);
		}
	}

	VDownloadManager{
		id: vdlmanager;
		onInfoChanged:{
			setMsg(info);
		}
		onFileDownloadFinished:{
			mainpage.addNotification({option: "download_success", title: name, value: "finished"});
		}
		onFileDownloadFailed:{
			mainpage.addNotification({option: "download_fail", title: name, value: "fail"});
		}
	}

	function setMsg(text) {
		infobanner.text = text;
		infobanner.show();
	}

	function formatUpdateAndTotal(updated, total) {
		if(updated.length === 8) {
			return qsTr("Time") + ": " + updated;
		}
		if(updated === "0") {
			return qsTr("Unreleased");
		}
		if(updated === "1" && total === "1") {
			return qsTr("1 End");
		}
		if(total === "0" && updated !== "0") {
			return qsTr("Update") + ": " + updated;
		}
		return qsTr("Update") + ":"+ updated + "/" + total;
	}
	/*
	 * QObject: Cannot create children for a parent that is in a different thread.
	 * (Parent is VNetworkAccessManager(0x1f687e00), parent's thread is QThread(0x1f64add0), currentthread is QThread(0x1f599580)
	 * {"error":{"code":1002,"type":"SystemException","description":"Service exception has occured"}
	 */

	// 2017
	function onFail(json)
	{
		var error = Script.checkError(json);
		if(error)
		{
			setMsg(
				qsTr("Error") + ": " + error.code
			  + " - " + error.type + "\n"
				+ error.description + "\n"
				+ error.cn_description + "\n"
			);
			return true;
		}
		return false;
	}

	Component.onCompleted:{
		Script.init(schemas);
		schemas.init();
	}
}

