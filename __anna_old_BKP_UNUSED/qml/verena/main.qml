import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QtMobility.systeminfo 1.1
import karin.verena 1.5
import karin.verena.dev 1.1
import "../js/main.js" as Script

PageStackWindow{
	id:app;

    //platformInverted: true;
    platformSoftwareInputPanelEnabled: true;
	QtObject{
		id:settingsObject;
		property int defaultPlayer:vut.getSetting("default_player");
		onDefaultPlayerChanged:{
			vut.setSetting("default_player", defaultPlayer);
		}
        /*
		property bool fullScreen:vut.getSetting("fullscreen");
		onFullScreenChanged:{
			vut.setSetting("fullscreen", fullScreen);
			//app.showStatusBar = !fullScreen;
        }
        */
		property int cardCountOfLine:vut.getSetting("card_count_of_line");
		onCardCountOfLineChanged:{
			vut.setSetting("card_count_of_line", cardCountOfLine);
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
    showStatusBar: true;//(!settingsObject.fullScreen && inPortrait && !mainpage.loading) || (!mainpage.loading && pageStack.currentPage === mainpage);
	initialPage:VerenaTouchHome{ id:mainpage; }
    /*
	platformStyle: PageStackWindowStyle {
		cornersVisible: app.inPortrait || settingsObject.playerCorner;
	}
    */

	DeveloperModeDialog{
		id:devmode;
		onAccepted:{
			developer.restart();
		}
	}

	InfoBanner {
        id: infobanner;
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
        player:0;
		onMsgChanged:{
			setMsg(msg);
		}
	}

	VDownloadManager{
		id:vdlmanager;
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
        infobanner.open();
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

    DeviceInfo {
        id: devinfo;
    }

    InfoText{
        id:systemObject;
        property int currentVolume:devinfo.voiceRingtoneVolume > 50 ? 50 : devinfo.voiceRingtoneVolume < 20 ? 20 : devinfo.voiceRingtoneVolume;
        property int level:5;
        anchors.centerIn: parent;
        z:5;
        text:"音量：" + currentVolume + "%";

        gradient: Gradient {
            GradientStop {
                position: 0;
                color: "black";
            }
            GradientStop {
                position: 1 - systemObject.currentVolume / 100;
                color: "red";
            }
        }
        function volumeP(){
            show();
            currentVolume = Math.min(currentVolume + level, 100);
        }
        function volumeM(){
            show();
            currentVolume = Math.max(currentVolume - level, 0);
        }
    }

    focus:true;

    Keys.onVolumeDownPressed: {
        systemObject.volumeM();
    }

    Keys.onVolumeUpPressed: {
        systemObject.volumeP();
    }

    Keys.onUpPressed: {
        systemObject.volumeP();
    }

    Keys.onDownPressed: {
        systemObject.volumeM();
    }
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

