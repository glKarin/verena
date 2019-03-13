import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QtMobility.systeminfo 1.1
import karin.verena 1.5
import "../js/main.js" as Script

PageStackWindow{
	id:app;

	//platformInverted: true;
	//showStatusBar: inPortrait;
	platformSoftwareInputPanelEnabled: true;
	showStatusBar: true; //(!settingsObject.fullScreen && inPortrait && !mainpage.loading) || (!mainpage.loading && pageStack.currentPage === mainpage);
	initialPage:VerenaTouchHome{ id:mainpage; }
	/*
	platformStyle: PageStackWindowStyle {
		cornersVisible: app.inPortrait || settingsObject.playerCorner;
	}
	*/

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
		player:settingsObject.externalPlayer; // 0
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
		return qsTr("Update") + ": "+ updated + "/" + total;
	}
	/*
	 * QObject: Cannot create children for a parent that is in a different thread.
	 * (Parent is VNetworkAccessManager(0x1f687e00), parent's thread is QThread(0x1f64add0), currentthread is QThread(0x1f599580)
	 * {"error":{"code":1002,"type":"SystemException","description":"Service exception has occured"}
	 */

	DeviceInfo {
		id: devinfo;
	}

	InfoText{
		id:systemObject;
		property int currentVolume:devinfo.voiceRingtoneVolume > 50 ? 50 : devinfo.voiceRingtoneVolume < 20 ? 20 : devinfo.voiceRingtoneVolume;
		property int level:5;
		anchors.centerIn: parent;
		z:5;
		text: qsTr("Volume") + ":\n" + currentVolume + "%";

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

