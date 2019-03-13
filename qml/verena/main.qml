import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import karin.verena 1.5
import "../js/main.js" as Script

PageStackWindow{
	id:app;

	//showStatusBar: inPortrait;
	showStatusBar: (!settingsObject.fullScreen && inPortrait && !mainpage.loading) || (!mainpage.loading && pageStack.currentPage === mainpage);
	initialPage:VerenaTouchHome{ id:mainpage; }
	platformStyle: PageStackWindowStyle {
		cornersVisible: app.inPortrait || settingsObject.playerCorner;
	}

	SettingsObject{
		id:settingsObject;
		onYouku_ccodeChanged: {
			Script.UpdateSettings();
		}
		onYouku_client_ipChanged: {
			Script.UpdateSettings();
		}
		onYouku_ckeyChanged: {
			Script.UpdateSettings();
		}
	}

	Constants{
		id: constants;
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

	VPlayer{
		id:vplayer;
		player:settingsObject.externalPlayer;
		onMsgChanged:{
			setMsg(msg);
		}
	}

	Connections{
		target: vdlmanager;
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
		console.log(text);
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
		return qsTr("Update") + ": "+ updated + "/" + total;
	}
	/*
	 * QObject: Cannot create children for a parent that is in a different thread.
	 * (Parent is VNetworkAccessManager(0x1f687e00), parent's thread is QThread(0x1f64add0), currentthread is QThread(0x1f599580)
	 * {"error":{"code":1002,"type":"SystemException","description":"Service exception has occured"}
	 */

	// global request fail function
	function onFail(json)
	{
		var error = Script.checkError(json);
		if(error)
		{
			setMsg(
				"[" + qsTr("Error") + "]: " + error.code
				+ " - " + error.type + "\n"
				+ error.description + "\n"
				+ error.cn_description + "\n"
			);
			return true;
		}
		return false;
	}

	// BeginA(2019a)
	Component{
		id: querydialog;
		QueryDialog{
			id: querydialogroot;
			property bool __isClosing: false;
			onStatusChanged: {
				if (status == DialogStatus.Closing){
					__isClosing = true;
				} else if (status == DialogStatus.Closed && __isClosing){
					querydialogroot.destroy(1000);
				}
			}
			Component.onCompleted: open();
		}
	}

	function openQueryDialog(title, message, acceptText, rejectText, acceptCallback, rejectCallback){
		var prop = { titleText: title, message: message.concat("\n"), acceptButtonText: acceptText, rejectButtonText: rejectText };
		var diag = querydialog.createObject(pageStack.currentPage, prop);
		if (acceptCallback) diag.accepted.connect(acceptCallback);
		if (rejectCallback) diag.rejected.connect(rejectCallback);
	}
	// End()


	Component.onCompleted:{
		// BeginC(2019a)
		Script.init(schemas, settingsObject, vut);
		// End();
		schemas.init();
	}
}

