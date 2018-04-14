import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;

	title:"<b>" + qsTr("Hot & New") + "</b>";

	QtObject{
		id:qobj;
		property variant videoCategoryDialog:null;
		property variant showCategoryDialog:null;
		property variant playlistCategoryDialog:null;
		property string orderby:"new";
		function getHome(){
			getHomeVideo();
			getHomeShow();
			getHomePlaylist();
		}
		function getHomeVideo(){
			homemodel.clear();
			function s(obj){
				if(!onFail(obj))
				{
					Script.makeHomeCategoryVideoMap(obj, homemodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			for(var i = 1; i < 5; i++){
				var opt = {
					period: "today",
					orderby: orderby === "new" ? "published" : "view-count",
					page:i,
					count:10,
				};
				root.show = true;
				Script.callAPI("GET", "videos_by_category", opt, s, f);
			}
		}
		function getHomeShow(){
			root.show = true;
			showmodel.clear();
			var arr = ["电影", "电视剧", "动漫", "综艺", "纪录片", "体育", "教育", "音乐"];
			function s(obj){
				if(!onFail(obj))
				{
					Script.makeShowResultList_2(obj, showmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			for(var i = 0; i < arr.length; i++){
				var opt = {
					category: arr[i],
					orderby: orderby === "new" ? "updated" : "view-today-count",
					page: 1,
					count: 5
				};
				Script.callAPI("GET", "shows_by_category", opt, s, f);
			}
		}
		function getHomePlaylist(){
			root.show = true;
			playlistmodel.clear();
			var opt = {
				period: "today",
				orderby: orderby === "new" ? "published" : "view-count",
				page: 1,
				count: 20
			};
			function s(obj){
				if(!onFail(obj))
				{
					Script.makePlaylistResultList(obj, playlistmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "playlists_by_category", opt, s, f);
		}
	}

	Rectangle{
		id:rect;
		anchors.top:headbottom;
		anchors.left:parent.left;
		height:50;
		width:parent.width;
		z:1;
		ButtonRow{
			id:buttonrow;
			anchors.fill:parent;
			Button{
				text:qsTr("New of Today");
				onClicked:{
					qobj.orderby = "new";
					qobj.getHome();
				}
			}
			Button{
				id:first;
				text:qsTr("Hot of Today");
				onClicked:{
					qobj.orderby = "hot";
					qobj.getHome();
				}
			}
		}
	}


	Flickable{
		id:flickables;
		anchors.fill:parent;
		anchors.topMargin:headheight + rect.height;
		clip:true;
		visible:!show;
		contentWidth:width;
		contentHeight:layout.height;
		Column{
			id:layout;
			width:parent.width;
			LineHeader{
				text:qsTr("Videos");
				enabled:schemas.isInitVideoCategoryMap;
				onTrigger:{
					if(!qobj.videoCategoryDialog){
						var component = Qt.createComponent(Qt.resolvedUrl("VideoCategoryTumbler.qml"));
						if(component.status === Component.Ready){
							qobj.videoCategoryDialog = component.createObject(root);
							qobj.videoCategoryDialog.hasSelectedIndeies.connect(function(arr){
								mainpage.addNotification({option: "category_video", value: arr.join(",")});
								var page = Qt.createComponent(Qt.resolvedUrl("CategoryPage.qml"));
								pageStack.push(page, {idx:arr});
							});
							qobj.videoCategoryDialog.open();
						}
					}else{
						qobj.videoCategoryDialog.open();
					}
				}
			}
			Repeater {
				model:ListModel{id:homemodel;}
				HomeVideoListView{}
			}
			LineHeader{
				text:qsTr("Shows");
				enabled:schemas.isInitShowCategoryMap;
				onTrigger:{
					if(!qobj.showCategoryDialog){
						var component = Qt.createComponent(Qt.resolvedUrl("ShowCategoryTumbler.qml"));
						if(component.status === Component.Ready){
							qobj.showCategoryDialog = component.createObject(root);
							qobj.showCategoryDialog.hasSelectedIndeies.connect(function(arr){
								mainpage.addNotification({option: "category_show", value: arr.join(",")});
								var page = Qt.createComponent(Qt.resolvedUrl("ShowCategoryPage.qml"));
								pageStack.push(page, {idx:arr});
							});
							qobj.showCategoryDialog.open();
						}
					}else{
						qobj.showCategoryDialog.open();
					}
				}
			}
			HomeShowListView{
				model:ListModel{id:showmodel}
			}
			LineHeader{
				text:qsTr("Playlists");
				enabled:schemas.isInitPlaylistCategoryList;
				onTrigger:{
					if(!qobj.playlistCategoryDialog){
						var component = Qt.createComponent(Qt.resolvedUrl("VerenaSelectionDialog.qml"));
						if(component.status === Component.Ready){
							qobj.playlistCategoryDialog = component.createObject(root);
							qobj.playlistCategoryDialog.titleText = qsTr("Playlist Category");
							qobj.playlistCategoryDialog.model = schemas.playlistCategoryList;
							qobj.playlistCategoryDialog.hasSelectedIndex.connect(function(i){
								mainpage.addNotification({option: "category_playlist", value: i});
								var page = Qt.createComponent(Qt.resolvedUrl("PlaylistCategoryPage.qml"));
								pageStack.push(page, {index: i});
							});
							qobj.playlistCategoryDialog.open();
						}
					}else{
						qobj.playlistCategoryDialog.open();
					}
				}
			}
			HomePlaylistListView{
				model:ListModel{id:playlistmodel}
			}
		}
	}

	ScrollDecorator{
		flickableItem:flickables;
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qobj.getHome();
			}
		}
	}
	Component.onCompleted:{
		qobj.getHome();
	}
}
