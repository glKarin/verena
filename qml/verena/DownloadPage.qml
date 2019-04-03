import QtQuick 1.1
import com.nokia.meego 1.1
import karin.verena 1.5
import "../js/parserengine.js" as Parser
import "../js/utility.js" as Utility
import "../js/main.js" as Script

VerenaPage{
	id:root;

	title: qsTr("Download");
	property string videoid:"";
	property string gowhere:"downloading";

	ListModel{
		id:typemodel;
	}

	QtObject{
		id:qobj;
		property string internalVideoId:root.videoid;
		property string type:"";
		property string name:"";
		property int part;

		property variant typeDialog:null;
		property variant partDialog:null;
		property variant taskSheet:null;

		function addMsg(msg){
			logmodel.append({value: msg});
			if(logmodel.count > 10){
				logmodel.remove(0);
			}
			animation.restart();
		}
		function load(url, s, t, p, id){
			part = p;
			type = t;
			if(!vdlmanager.checkTaskList(s, id, t, p)){
				vdlmanager.addTask(url, s, name, t, p, id);
			}else{
				setMsg(qsTr("Video file is downloded or downloading"));
			}
		}

		function addNewTask(){
			if(!taskSheet){
				var component = Qt.createComponent(Qt.resolvedUrl("NewTaskSheet.qml"));
				if(component.status === Component.Ready){
					taskSheet = component.createObject(root);
					taskSheet.requestPause.connect(function(vid){
						qobj.getStreamtypes(vid);
					});
					taskSheet.open();
				}
			}else{
				taskSheet.open();
			}
		}

		function remakeStreamtypesModel(model)
		{
			for(var i = 0; i < model.count; i++)
			{
				var name = model.get(i).name;
				model.get(i).name = "%1 [%2]".arg(name).arg(Utility.FormatSize(model.get(i).size));
				model.get(i).value = name;

				for(var j = 0; j < model.get(i).part.count; j++)
				{
					var sname = model.get(i).part.get(j).name;
					model.get(i).part.get(j).name = "%1 [%2]".arg(sname).arg(Utility.FormatSize(model.get(i).part.get(j).size));
				}
			}
		}

		function getStreamtypes(vid){
			if(vid.length === 0){
				return;
			}
			root.show = true;
			typemodel.clear();
			function s(obj){
				////symbian
				if(obj.data){
					name = obj.data.video.title || "";
				}
				Script.makeStreamtypesModel(obj, typemodel);
				remakeStreamtypesModel(typemodel);
				if(!typeDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("VerenaSelectionDialog.qml"));
					if(component.status === Component.Ready){
						qobj.typeDialog = component.createObject(root, {titleText: qsTr("Stream types"), model: typemodel});
						qobj.typeDialog.hasSelectedIndex.connect(function(i){
							qobj.type = typemodel.get(i).value;
							if(!partDialog){
								var component2 = Qt.createComponent(Qt.resolvedUrl("VerenaMultiSelectionDialog.qml"));
								if(component2.status === Component.Ready){
									qobj.partDialog = component2.createObject(root, {titleText: qsTr("Parts(Multi Selection)"), acceptButtonText: qsTr("Download"), rejectButtonText: qsTr("Back"), model: typemodel.get(i).part});
									qobj.partDialog.hasSelectedIndies.connect(function(arr){
										var indexs = [];
										for(var k in arr)
										{
											indexs.push(typemodel.get(i).part.get(arr[k]).value);
											//console.log(k, arr[k]);
										}
										if(settingsObject.youkuVideoUrlLoadOnce)
										{
											for(var k in indexs)
											{
												var url = typemodel.get(i).part.get(indexs[k]).url;
												if(url.length)
												{
													load(url, "youku", qobj.type, indexs[k], vid);
												}
												else
												{
													setMsg(qsTr("Video is a preview."));
												}
											}
										}
										else
										{
											Parser.loadSource(vid, "youku", qobj, [qobj.type], indexs, {settings: settingsObject});
										}
									});
									qobj.partDialog.rejected.connect(function(){
										qobj.typeDialog.open();
									});
									qobj.partDialog.open();
								}
							}else{
								qobj.partDialog.resetSelectedIndexes();
								qobj.partDialog.model = typemodel.get(i).part;
								qobj.partDialog.open();
							}
						});
						qobj.typeDialog.open();
					}
				}else{
					qobj.typeDialog.model = typemodel;
					qobj.typeDialog.open();
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.getVideoStreamtypes(vid, s, f);
		}

		function setColor(state) {
			if(state === VDownloadTask.Doing){
				return "blue";
			}else if(state === VDownloadTask.Done){
				return "black";
			}else if(state === VDownloadTask.Fail){
				return "red";
			}else if(state === VDownloadTask.Pause){
				return "seagreen";
			}else{
				return "grey";
			}
		}

		function openDetailPage(source, vid, title)
		{
			if(source === "youku")
			{
				mainpage.addNotification({option: "video_detail", title: title, thumbnail: "", value: vid});
				var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
				pageStack.push(page, {videoid:vid, canRecursion: true});
			}
		}

	}

	QtObject{
		id: qobj2;
		property string taskId: "";
		function load(url, s, t, p, id){
			vdlmanager.reloadTask(url, taskId);
		}
		function addMsg(msg){
			logmodel.append({value: msg});
			if(logmodel.count > 10){
				logmodel.remove(0);
			}
			animation.restart();
		}

	}

	Connections{
		target:vdlmanager;
		onFileDownloadStarted:{
			setMsg(qsTr("Downloading file") + ": " + name);
		}
		onFileDownloadFinished:{
			if(downloadinglist.model.length === 0) {
				tabgroup.currentTab = finishedlist;
			}
			setMsg(qsTr("Download file successful") + ": " + name);
		}
		onFileDownloadRestarted:{
			if(faillist.model.length === 0) {
				tabgroup.currentTab = downloadinglist;
			}
			setMsg(qsTr("Redownloading file") + ": " + name);
		}
		onFileDownloadFailed:{
			if(downloadinglist.model.length === 0) {
				tabgroup.currentTab = faillist;
			}
			setMsg(qsTr("Downloading file fail") + ": " + name);
		}
		onFileDownloadPaused:{
			if(downloadinglist.model.length === 0) {
				tabgroup.currentTab = faillist;
			}
			setMsg(qsTr("Pause download task") + ": " + name);
		}
		onFileDownloadContinue:{
			if(faillist.model.length === 0) {
				tabgroup.currentTab = downloadinglist;
			}
			setMsg(qsTr("Continue download file fail") + ": " + name);
		}
	}

	Rectangle{
		id:infobox;
		width:parent.width;
		anchors.bottom:parent.bottom;
		anchors.left:parent.left;
		height:250;
		z:2;
		opacity:0;
		color:"black";
		visible:opacity != 0;
		MouseArea{
			anchors.fill:parent;
			onClicked:{
				animation.complete();
			}
		}
		SequentialAnimation{
			id:animation;
			NumberAnimation{
				target:infobox;
				property:"opacity";
				to:0.8;
				easing.type:Easing.OutExpo;
				duration:400;
			}
			PauseAnimation {
				duration: 5000;
			}
			NumberAnimation{
				target:infobox;
				property:"opacity";
				to:0.0;
				easing.type:Easing.InExpo;
				duration:400;
			}
		}
		//visible:opacity === 0.8;
		Column{
			anchors.fill:parent;
			Repeater{
				model:ListModel{id:logmodel}
				Text{
					width:root.width;
					height: 20;
					font.pixelSize: constants.pixel_large;
					color:"white";
					text:model.value;
				}
			}
		}
	}

	TabButton{
		id:tabbutton;
		width:parent.width;
		anchors.top:headbottom;
		ButtonRow{
			width:parent.width;
			TabButton{
				width:parent.width/3;
				text:qsTr("Download") + "\n[" + (downloadinglist.model !== undefined ? downloadinglist.model.length : "0") + "]";
				tab:downloadinglist;
			}
			TabButton{
				width:parent.width/3;
				text:qsTr("Finished") + "\n[" + (finishedlist.model !== undefined ? finishedlist.model.length : "0") + "]";
				tab:finishedlist;
			}
			TabButton{
				width:parent.width/3;
				text:qsTr("Unfinished") + "\n[" + (faillist.model !== undefined ? faillist.model.length : "0") + "]";
				tab:faillist;
			}
		}
	}

	TabGroup{
		id:tabgroup;
		anchors.fill:parent;
		anchors.topMargin:tabbutton.height + headheight;
		currentTab:downloadinglist;
		ListView{
			id:downloadinglist;
			anchors.fill:parent;
			delegate:Component{
				Rectangle{
					height:100;
					width:ListView.view.width;
					color:ListView.isCurrentItem ? "lightseagreen" : "white";
					FreeToolBar{
						id:freetoolbar;
						twidth: toolbarlayout.children.length * 64 + border.width * 2;
						current:parent.ListView.isCurrentItem;
						ToolBarLayout{
							id: toolbarlayout;
							anchors.centerIn: parent;
							visible: parent.twidth === parent.width;
							ToolIcon{
								iconId: "toolbar-mediacontrol-pause";
								onClicked:{
									freetoolbar.openToolBar();
									vdlmanager.pauseTask(modelData.taskId);
								}
							}
							ToolIcon{
								iconId: "toolbar-cut-paste";
								onClicked:{
									freetoolbar.openToolBar();
									vut.copyToClipboard(modelData.url);
									setMsg(qsTr("Copy video url to clipboard successful"));
								}
							}
							ToolIcon{
								iconId: "toolbar-search";
								onClicked:{
									freetoolbar.openToolBar();
									qobj.openDetailPage(modelData.source, modelData.vid, modelData.title);
								}
							}
							ToolIcon{
								iconId: "toolbar-delete";
								onClicked:{
									freetoolbar.openToolBar();
									var sf = function(){
										var name = modelData.name;
										vdlmanager.deleteOneTask(VDownloadManager.Downloading, modelData.taskId, true);
										setMsg(qsTr("Video task has deleted") + ": " + name);
									};
									openQueryDialog(
										qsTr("Warning"),
										qsTr("Delete this task(include file)"),
										qsTr("Yes"),
										qsTr("No"),
										sf);
								}
							}
						}
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							downloadinglist.currentIndex = index;
							freetoolbar.showToolBar();
						}
					}
					Text{
						anchors.top:parent.top;
						width:parent.width;
						height:40;
						anchors.fill:parent;
						color:qobj.setColor(modelData.state);
						font.pixelSize: constants.pixel_small;
						elide:Text.ElideRight;
						text:modelData.name;
						maximumLineCount:2;
						wrapMode:Text.WrapAnywhere;
					}
					ProgressBar{
						anchors.centerIn:parent;
						width:parent.width;
						maximumValue :100;
						minimumValue :0;
						value:modelData.percent;
					}
					Text{
						anchors.centerIn:parent
						z:1;
						opacity:0.6;
						color:qobj.setColor(modelData.state);
						font.pixelSize: constants.pixel_xxl;
						text:modelData.percent + "%";
					}
					Text{
						height:30;
						anchors.horizontalCenter:parent.horizontalCenter;
						anchors.bottom:parent.bottom;
						color:qobj.setColor(modelData.state);
						font.pixelSize: constants.pixel_xl;
						text: vut.FormatSize(modelData.read) + "/" + vut.FormatSize(modelData.total);
					}
				}
			}
			clip:true;
			spacing:2;
			model:vdlmanager.taskListDownloading;
			onModelChanged:{
				currentIndex = model.length - 1;
				positionViewAtEnd();
			}
			ScrollDecorator{
				flickableItem:parent;
			}
		}

		ListView{
			id:finishedlist;
			anchors.fill:parent;
			delegate:Component{
				Rectangle{
					height:100;
					width:ListView.view.width;
					color:ListView.isCurrentItem ? "lightsteelblue" : "white";
					FreeToolBar{
						id:freetoolbar;
						current:parent.ListView.isCurrentItem;
						twidth: toolbarlayout.children.length * 64 + border.width * 2;
						ToolBarLayout{
							id: toolbarlayout;
							anchors.centerIn: parent;
							visible: parent.twidth === parent.width;
							ToolIcon{
								iconId: "toolbar-mediacontrol-play";
								onClicked:{
									freetoolbar.openToolBar();
									setMsg(qsTr("Waiting to play local video file"));
									if(settingsObject.defaultPlayer === 0){
										var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
										pageStack.push(page,{source: "LocalHost", videosource: "file://" + modelData.path}, true);
									}else if(settingsObject.defaultPlayer === 1){
										//vplayer.openMMVideoSuitePlayer("file://" + modelData.path);
										if(settingsObject.externalPlayer === 0){
											vplayer.openMMVideoSuitePlayer("file://" + modelData.path);
										}else if(settingsObject.externalPlayer === 2){
											vplayer.openExternalKMPlayer(modelData.path);
										}
									}
								}
							}
							ToolIcon{
								iconId: "toolbar-cut-paste";
								onClicked:{
									freetoolbar.openToolBar();
									vut.copyToClipboard(modelData.path);
									setMsg(qsTr("Copy video path to clipboard successful"));
								}
							}
							ToolIcon{
								iconId: "toolbar-refresh";
								onClicked:{
									freetoolbar.openToolBar();
									var sf = function(){
										qobj2.taskId = modelData.taskId;
										var tvid = modelData.vid;
										var ttype = [modelData.streamtype];
										var tpart = [modelData.part];
										Parser.loadSource(tvid, "youku", qobj2, ttype, tpart, {settings: settingsObject});
									};
									openQueryDialog(
										qsTr("Warning"),
										qsTr("Redownload this video again?"),
										qsTr("Yes"),
										qsTr("No"),
										sf);
								}
							}
							ToolIcon{
								iconId: "toolbar-search";
								onClicked:{
									freetoolbar.openToolBar();
									qobj.openDetailPage(modelData.source, modelData.vid, modelData.title);
								}
							}
							ToolIcon{
								iconId: "toolbar-close";
								onClicked:{
									freetoolbar.openToolBar();
									var sf = function(){
										var name = modelData.name;
										vdlmanager.deleteOneTask(VDownloadManager.Finished, modelData.taskId, false);
										setMsg(qsTr("Video task has removed") + ": " + name);
									};
									openQueryDialog(
										qsTr("Warning"),
										qsTr("Remove this task(It will not delete this video file.)?"),
										qsTr("Yes"),
										qsTr("No"),
										sf);
								}
							}
							ToolIcon{
								iconId: "toolbar-delete";
								onClicked:{
									freetoolbar.openToolBar();
									var sf = function(){
										var name = modelData.path;
										vdlmanager.deleteOneTask(VDownloadManager.Finished, modelData.taskId, true);
										setMsg(qsTr("Video file has deleted") + ": " + name);
									};
									openQueryDialog(
										qsTr("Warning"),
										qsTr("Delete this task and file(This video file will be deleted!)?"),
										qsTr("Yes"),
										qsTr("No"),
										sf);
								}
							}
						}
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							finishedlist.currentIndex = index;
							freetoolbar.showToolBar();
						}
					}
					Column{
						anchors.fill:parent;
						Text{
							width:parent.width;
							height:parent.height / 3 * 2;
							color:qobj.setColor(modelData.state);
							font.pixelSize: constants.pixel_xl;
							elide:Text.ElideRight;
							text:modelData.name;
							maximumLineCount:2;
							wrapMode:Text.WrapAnywhere;
						}
						Text{
							height:parent.height / 3;
							anchors.horizontalCenter:parent.horizontalCenter;
							color:qobj.setColor(modelData.state);
							font.pixelSize: constants.pixel_xl;
							text:qsTr("Size") + ": " + vut.FormatSize(modelData.total);
						}
					}
					Image{
						height:40;
						width:40;
						anchors.bottom:parent.bottom;
						anchors.left:parent.left;
						smooth:true;
						source:modelData.state === VDownloadTask.Done ? "image://theme/icon-m-toolbar-done" : "image://theme/icon-m-toolbar-close";
					}
				}
			}
			clip:true;
			spacing:2;
			model:vdlmanager.taskListFinished;
			onModelChanged:{
				currentIndex = model.length - 1;
				positionViewAtEnd();
			}
			ScrollDecorator{
				flickableItem:parent;
			}
		}

		ListView{
			id:faillist;
			anchors.fill:parent;
			delegate:Component{
				Rectangle{
					height:100;
					width:ListView.view.width;
					color:ListView.isCurrentItem ? "orange" : "white";
					FreeToolBar{
						id:freetoolbar;
						twidth: toolbarlayout.children.length * 64 + border.width * 2;
						current:parent.ListView.isCurrentItem;
						anchors.right:parent.right;
						ToolBarLayout{
							id: toolbarlayout;
							anchors.centerIn: parent;
							visible:parent.width === parent.twidth;
							ToolIcon{
								iconId: "toolbar-refresh";
								onClicked:{
									freetoolbar.openToolBar();
									qobj.name = modelData.title;
									Parser.loadSource(modelData.vid, "youku", qobj, [modelData.streamtype], [modelData.part], {settings: settingsObject});
								}
							}
							ToolIcon{
								iconId: "toolbar-search";
								onClicked:{
									freetoolbar.openToolBar();
									qobj.openDetailPage(modelData.source, modelData.vid, modelData.title);
								}
							}
							ToolIcon{
								iconId: "toolbar-delete";
								onClicked:{
									freetoolbar.openToolBar();
									var sf = function(){
										var name = modelData.name;
										vdlmanager.deleteOneTask(VDownloadManager.Fail, modelData.taskId, true);
										setMsg(qsTr("Video task has deleted") + ": " + name);
									};
									openQueryDialog(
										qsTr("Warning"),
										qsTr("Delete this task(include file)"),
										qsTr("Yes"),
										qsTr("No"),
										sf);
								}
							}
						}
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							faillist.currentIndex = index;
							freetoolbar.showToolBar();
						}
					}
					Text{
						anchors.top:parent.top;
						width:parent.width;
						height:40;
						anchors.fill:parent;
						color:qobj.setColor(modelData.state);
						font.pixelSize: constants.pixel_small;
						elide:Text.ElideRight;
						text:modelData.name;
						maximumLineCount:2;
						wrapMode:Text.WrapAnywhere;
					}
					ProgressBar{
						anchors.centerIn:parent;
						width:parent.width;
						maximumValue :100;
						minimumValue :0;
						value:modelData.percent;
					}
					Text{
						anchors.centerIn:parent
						z:1;
						opacity:0.6;
						color:qobj.setColor(modelData.state);
						font.pixelSize: constants.pixel_xxl;
						text:modelData.percent + "%";
					}
					Text{
						height:30;
						anchors.horizontalCenter:parent.horizontalCenter;
						anchors.bottom:parent.bottom;
						color:qobj.setColor(modelData.state);
						font.pixelSize: constants.pixel_xl;
						text: vut.FormatSize(modelData.read) + "/" + vut.FormatSize(modelData.total);
					}
					Image{
						height:40;
						width:40;
						anchors.bottom:parent.bottom;
						anchors.left:parent.left;
						smooth:true;
						source:modelData.state === VDownloadTask.Pause ? "image://theme/icon-m-toolbar-mediacontrol-pause" : "image://theme/icon-m-toolbar-close";
					}
				}
			}
			clip:true;
			spacing:2;
			model:vdlmanager.taskListFail;
			onModelChanged:{
				currentIndex = model.length - 1;
				positionViewAtEnd();
			}
			ScrollDecorator{
				flickableItem:parent;
			}
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-list";
			visible:logmodel.count > 0;
			enabled:visible;
			onClicked:{
				if(animation.running) {
					animation.complete();
				} else {
					animation.restart();
				}
			}
		}
		ToolIcon{
			iconId: "toolbar-add";
			onClicked:{
				qobj.addNewTask();
			}
		}
	}
	Component.onCompleted:{
		vdlmanager.RefreshHistory();
		if(root.videoid.length !== 0){
			qobj.getStreamtypes(qobj.internalVideoId);
		}else{
			if(root.gowhere === "finished"){
				tabgroup.currentTab = finishedlist;
			}else if(root.gowhere === "fail"){
				tabgroup.currentTab = faillist;
			}
		}
	}
}
