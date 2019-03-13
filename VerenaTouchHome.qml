import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

Page{
	id:root;
	orientationLock: settingsObject.vthomeLockOrientation ? PageOrientation.LockPortrait : PageOrientation.Automatic;

	property alias loading:indicator.visible;

	function makeVideoSubModel(yes){
		var m = hsmodel.get(0).childModel;
		m.clear();
		if(yes){
			schemas.videoCategoryMap.forEach(function(k, i){
				var item = {
					name: k.name,
					icon: Qt.resolvedUrl("../image/verena-l-videos.png"),
					index: i,
					category:"video"
				};
				m.append(item);
			});
			qobj.videoSubModelInit = 1;
		}else{
			qobj.videoSubModelInit = 0;
		}
	}

	function makeShowSubModel(yes){
		var m = hsmodel.get(1).childModel;
		m.clear();
		if(yes){
			schemas.showCategoryMap.forEach(function(k, i){
				var item = {
					name: k.name,
					icon: Qt.resolvedUrl("../image/verena-l-shows.png"),
					index: i,
					category:"show"
				};
				m.append(item);
			});
			qobj.showSubModelInit = 1;
		}else{
			qobj.showSubModelInit = 0;
		}
	}

	function makePlaylistSubModel(yes){
		var m = hsmodel.get(2).childModel;
		m.clear();
		if(yes){
			for(var i = 0; i < schemas.playlistCategoryList.count; i++){
				var item = {
					name: schemas.playlistCategoryList.get(i).value,
					icon: Qt.resolvedUrl("../image/verena-l-playlists.png"),
					index: i,
					category:"playlist"
				};
				m.append(item);
			}
			qobj.playlistSubModelInit = 1;
		}else{
			qobj.playlistSubModelInit = 0;
		}
	}

	ListModel{
		id:hsmodel;
		ListElement{
			icon:"../image/verena-l-videos.png";
			name:"视频分类";
			childModel:[];
			actions:"category";
		}
		ListElement{
			icon:"../image/verena-l-shows.png";
			name:"节目分类";
			childModel:[];
			actions:"category";
		}
		ListElement{
			icon:"../image/verena-l-playlists.png";
			name:"专辑分类";
			childModel:[];
			actions:"category";
		}
		ListElement{
			icon:"../image/verena-l-browser.png";
			name:"浏览器";
			childModel:[];
			actions:"VerenaBrowser";
		}
		ListElement{
			icon:"../image/verena-l-search.png";
			name:"搜索";
			childModel:[];
			actions:"SearchPage";
		}
		ListElement{
			icon:"../image/verena-l-hot.png";
			name:"今日最新&最热";
			childModel:[];
			actions:"HotAndNewPage";
		}
		ListElement{
			icon:"../image/verena-l-collections.png";
			name:"本地收藏";
			childModel:[];
			actions:"LocalCollectionPage";
		}
		ListElement{
			icon:"../image/verena-l-download.png";
			name:"下载";
			childModel:[];
			actions:"DownloadPage";
		}
		ListElement{
			icon:"../image/verena-l-settings.png";
			name:"设置";
			childModel:[];
			actions:"SettingPage";
		}
		ListElement{
			icon:"../image/verena-l-user.png";
			name:"用户";
			childModel:[];
			actions:"unfinished";
		}
		ListElement{
			icon:"../image/verena-l-refresh.png";
			name:"刷新";
			childModel:[];
			actions:"refresh";
		}
		ListElement{
			icon:"../image/verena-l-quit.png";
			name:"退出";
			childModel:[];
			actions:"quit";
		}
	}

	Rectangle{
		anchors.fill:parent;
		color:"black";
		PathView{
			id:pathview;
			anchors.fill:parent;
			model: ListModel{
				ListElement{
					page:"NotifyPage";
				}
				ListElement{
					page:"MenuPage";
				}
				ListElement{
					page:"TaskPage";
				}
			}

			delegate:Component{
				Rectangle{
					id:rect;
					width:PathView.view.width;
					height:PathView.view.height;
					color:"black";
					Component.onCompleted:{
						if(model.page === "NotifyPage"){
							var notifyPage = Qt.createComponent(Qt.resolvedUrl("NotifyPage.qml"));
							if(notifyPage.status === Component.Ready){
								var notifyPageObj = notifyPage.createObject(rect);
							}else{
								console.log(notifyPage.errorString);
							}
						}else if(model.page === "MenuPage"){
							var menuPage = Qt.createComponent(Qt.resolvedUrl("MenuPage.qml"));
							if(menuPage.status === Component.Ready){
								var menuPageObj = menuPage.createObject(rect, {model:hsmodel});
							}else{
								console.log(menuPage.errorString);
							}
						}else if(model.page === "TaskPage"){
							var taskPage = Qt.createComponent(Qt.resolvedUrl("TaskPage.qml"));
							if(taskPage.status === Component.Ready){
								var taskPageObj = taskPage.createObject(rect);
							}else{
								console.log(taskPage.errorString);
							}
						}
					}
				}
			}
			//visible:!indicator.visible;
			clip:true;
			path:Path{
				startX:-pathview.width / 2;
				startY:pathview.height / 2;
				PathLine{
					x:3 * pathview.width - pathview.width / 2;
					y:pathview.height / 2;
				}
			}
		}
	}

	Connections{
		target:screen;
		onMinimizedChanged:{
			if(screen.minimized){
				//subgrid.state = "noshow";
			}
		}
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn:parent;
		z:5;
		platformStyle:BusyIndicatorStyle{
			size:"large";
			inverted:true;
			//numberOfFrames:10;
			period:2000;
		}
		visible:qobj.videoSubModelInit === -1 && qobj.showSubModelInit === -1 && qobj.playlistSubModelInit === -1;
		running:visible;
	}

	QtObject{
		id:qobj;

		property int videoSubModelInit:-1;
		property int showSubModelInit:-1;
		property int playlistSubModelInit:-1;

		property int desktopWidth:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 120 : 122;
		property int iconHorizontalMargin:(desktopWidth - iconWidth) / 2;
		property int desktopHeight:118;
		property int iconTopMargin:(desktopHeight - iconHeight) / 2;
		property int textHeight:30;
		property int iconWidth:80;
		property int iconHeight:80;
		property real frontBackgroundOpacity:0.5;
		property int folderContentMinTopMargin:80;
		property int folderContentMinBottomMargin:147;
		property int folderBorderLineWidth:1;
		//folder-content-vertical-offset-from-button-top: 8.0mm;
		property int folderContentMinHeight:118 ;
		property int folderContentMaxHeight:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 527 : 153;
		property int folderSizeChangeAnimationDuration:150;
		property int folderOpacityChangeAnimationDuration:200;

		function setHeight(count){
			var columns = screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 4 : 7;
			var max = screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 3 : 1;
			if(count > columns * max){
				return folderContentMaxHeight;
			}else if(count === 0){
				return folderContentMinHeight;
			}else{
				return (count / columns + (count % columns !== 0 ? 1 : 0)) * desktopHeight;
			}
		}

	}

	/*
	 onStatusChanged: {
		 if (status === PageStatus.Active){
		 }
	 }
	 */
	/*
	Component.onCompleted:{
	}
	*/
}

