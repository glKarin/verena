import QtQuick 1.1
import com.nokia.symbian 1.1
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
					name: schemas.playlistCategoryList.get(i).name,
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

	function addNotification(what){
		var option = what.option;
		var icon = "";
		var content = "";
		var title = "";
		var timestamp = Qt.formatDateTime(new Date(), "d/M/yy | h:m");
		if(option === "search_video"){
			icon = Qt.resolvedUrl("../image/verena-l-search.png");
            content = "关键字：%1".arg(what.value);
			title = "视频搜索";
        }else if(option === "search_tag"){
            icon = Qt.resolvedUrl("../image/verena-l-search.png");
            content = "关键字：%1".arg(what.value);
            title = "标签搜索";
        }else if(option === "search_show"){
			icon = Qt.resolvedUrl("../image/verena-l-search.png");
            content = "关键字：%1".arg(what.value);
			title = "节目搜索";
		}else if(option === "user_detail"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-user.png");
			content = "查看 用户-%1 的详情".arg(what.value);
			title = "用户详情";
		}else if(option === "category_video"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-videos.png");
			var arr = what.value.split(",");
			content = "查找 分类-%1 类型-%2 范围-%3 的视频".arg(schemas.videoCategoryMap[arr[0]].name).arg(schemas.videoCategoryMap[arr[0]].value[arr[1]].value).arg(schemas.periodList.get(arr[2]).value);
			title = "分类视频";
		}else if(option === "category_show"){
			icon = Qt.resolvedUrl("../image/verena-l-shows.png");
			var arr2 = what.value.split(",");
			content = "查找 分类-%1 类型-%2 地区-%3 的节目".arg(schemas.showCategoryMap[arr2[0]].name).arg(schemas.showCategoryMap[arr2[0]].value[arr2[1]].value).arg(schemas.areaList.get(arr2[2]).value);
			title = "分类节目";
		}else if(option === "category_playlist"){
			icon = Qt.resolvedUrl("../image/verena-l-playlists.png");
			content = "查找 分类-%1 的专辑".arg(schemas.playlistCategoryList.get(what.value).name);
			title = "分类专辑";
		}else if(option === "user_video"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-user.png");
			content = "查找 用户-%1 的视频".arg(what.value);
			title = "用户视频";
		}else if(option === "user_playlist"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-user.png");
			content = "查找 用户-%1 的专辑".arg(what.value);
			title = "用户专辑";
		}
		else if(option === "video_detail"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-videos.png");
			content = "查看 视频-%1 的详情".arg(what.title);
			title = "视频详情";
		}else if(option === "show_detail"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-shows.png");
			content = "查看 节目-%1 的详情".arg(what.title);
			title = "节目详情";
		}else if(option === "playlist_detail"){
			icon = what.thumbnail || Qt.resolvedUrl("../image/verena-l-playlists.png");
			content = "查看 专辑-%1 的详情".arg(what.title);
			title = "专辑详情";
		}else if(option === "download_success"){
			icon = Qt.resolvedUrl("../image/verena-l-download.png");
			content = "下载视频文件 %1 成功".arg(what.title);
			title = "视频下载";
		}else if(option === "download_fail"){
			icon = Qt.resolvedUrl("../image/verena-l-quit.png");
			content = "下载视频文件 %1 失败".arg(what.title);
			title = "视频下载";
		}
		var item = {
			icon: icon,
			content: content,
			title: title,
			timestamp: timestamp,
			option: option,
			what: what.value
		};
		notificationmodel.insert(0, item);
	}

	function addSwipeSwitcher(title, thumbnail, vid, source){
		var item = {
			title: title,
			thumbnail: thumbnail || Qt.resolvedUrl("../image/verena-l-videos.png"),
			vid: vid,
			source: source
		};
		taskmodel.insert(0, item);
	}

	ListModel{
		id:notificationmodel;
	}

	ListModel{
		id:taskmodel;
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
			name:"今日最新&热";
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
			icon: "../image/verena-l-yk.png";
			name: "YK";
			childModel: [];
			actions: "yk/YKMainPage";
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
					page:"NotificationPage.qml";
				}
				ListElement{
					page:"LauncherPage.qml";
				}
				ListElement{
					page:"SwipeSwitcherPage.qml";
				}
			}

			delegate:Component{
				Rectangle{
					id:rect;
					width:PathView.view.width;
					height:PathView.view.height;
					color:"black";
					Loader{
						id:loader;
						anchors.fill:parent;
					}
					Component.onCompleted:{
						loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl(model.page));
						if(loader.status === Loader.Ready){
							if(model.page === "NotificationPage.qml"){
								loader.item.model = notificationmodel;
							}else if(model.page === "LauncherPage.qml"){
								loader.item.model = hsmodel;
							}else if(model.page === "SwipeSwitcherPage.qml"){
								loader.item.model = taskmodel;
								loader.item.lockPage.connect(function(yes){
								pathview.interactive = !yes;	
								});
							}
						}
						/*
						var page = Qt.createComponent(Qt.resolvedUrl(model.page));
						if(page.status === Component.Ready){
							if(model.page === "NotificationPage.qml"){
								var pageObj = page.createObject(rect, {model: notificationmodel});
							}else if(model.page === "LauncherPage.qml"){
								var pageObj = page.createObject(rect, {model: hsmodel});
							}else if(model.page === "SwipeSwitcherPage.qml"){
								var pageObj = page.createObject(rect, {model: taskmodel});
							}
						}else{
							console.log(page.errorString);
						}
						*/
					}
				}
			}
			visible:!indicator.visible;
			clip:true;
			flickDeceleration:5000;
			//dragMargin:-400;
			path:Path{
				startX:- pathview.width / 2;
				startY:pathview.height / 2;
				PathLine{
					x:3 * pathview.width - pathview.width / 2;
					y:pathview.height / 2;
				}
			}
		}
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn:parent;
		z:5;
		platformInverted: true;
		visible:qobj.videoSubModelInit === -1 && qobj.showSubModelInit === -1 && qobj.playlistSubModelInit === -1;
		running:visible;
	}

	QtObject{
		id:qobj;

		property int videoSubModelInit:-1;
		property int showSubModelInit:-1;
		property int playlistSubModelInit:-1;

		function refresh(){
			hsmodel.get(0).childModel.clear();
			hsmodel.get(1).childModel.clear();
			hsmodel.get(2).childModel.clear();
			videoSubModelInit = -1;
			showSubModelInit = -1;
			playlistSubModelInit = -1;
			schemas.init();
		}

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

