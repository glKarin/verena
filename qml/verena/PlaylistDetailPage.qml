import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;

	property string playlistid:"";
	property bool canRecursion:true;
	title: qsTr("Playlist Detail");

	QtObject{
		id:qobj;
		property string internalPlaylistId:root.playlistid;
		property int page:1;
		property int maxPage:0;
		property int count:18;
		property int total:0;
		property variant rankingDialog:null;

		property string username;
		property string userid:"";
		property url userimg:"";
		property url thumbnail:"";
		property int video_count;
		property bool isCollected:false;

		function addOrRemoveCollection(){
			if(isCollected){
				Script.removeCollection('PlaylistCollection', 'vid', internalPlaylistId);
				setMsg(qsTr("Uncollect"));
				checkIsCollected();
			}else{
				if(!rankingDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("RankSelectionDialog.qml"));
					if(component.status == Component.Ready){
						rankingDialog = component.createObject(root);
						rankingDialog.selectedRank.connect(function(rank){
								Script.addCollection('PlaylistCollection', [qobj.internalPlaylistId, name.text, qobj.thumbnail, (new Date()).getTime(), rank]);
								qobj.checkIsCollected();
								setMsg(qsTr("Collect"));
						});
						rankingDialog.open();
					}
				}else{
					rankingDialog.open();
				}
			}
		}

		function checkIsCollected(){
			isCollected = Script.checkIsCollected('PlaylistCollection', internalPlaylistId);
		}

		function getUserDetail(){
			root.show = true;
			usermodel.clear();
			var opt = {
				user_id: userid,
				user_name: username
			};
			function s(obj){
				if(!onFail(obj))
				{
					userimg = obj.avatar_large;
					Script.makeUserDetailList(obj, usermodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "users_show", opt, s, f);
		}

		function getPlaylistDetail(){
			root.show = true;
			infomodel.clear();
			tabgroup.currentTab = baseinfo;
			var opt = {
				playlist_id: internalPlaylistId
			};
			function s(obj){
				if(!onFail(obj))
				{
					userid = obj.user.id || "";
					username = obj.user.name || "";
					getUserDetail();
					name.text = obj.name || "";
					video_count = obj.video_count || 0;
					thumbnail = obj.thumbnail || "";
					Script.makePlaylistDetailList(obj, infomodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "playlists_show", opt, s, f);
		}

		function getPlaylistEpisode(o){
			root.show = true;
			if(o === "more"){
				page++;
			}else{
				page = 1;
				listmodel.clear();
			}
			var opt = {
				playlist_id: internalPlaylistId,
				page: page,
				count: count
			};
			function s(obj){
				if(!onFail(obj))
				{
					total = obj.total;
					maxPage = Math.ceil(total / count)
					Script.makePlaylistEpisodeList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "playlists_videos", opt, s, f);
		}
	}

	Rectangle{
		id:rect;
		color:"orange";
		width:parent.width;
		height:40;
		anchors.top:headbottom;
		z:1;
		Text{
			id:name;
			font.pixelSize:24;
			color:"blue";
			anchors.centerIn:parent;
			elide:Text.ElideRight;
		}
	}

	Image{
		id:image;
		z:1;
		width: constants.max_width;
		height: width * 9 / 16;
		anchors.top:rect.bottom;
		anchors.left: parent.left;
		source:qobj.thumbnail;
		smooth:true;
	}

	ButtonRow{
		id:buttonrow;
		anchors.top:image.bottom;
		width:parent.width;
		z:1;
		TabButton{
			text:qsTr("Detail");
			tab:baseinfo;
		}
		TabButton{
			text:qsTr("User");
			tab:usergroup;
		}
		TabButton{
			text:qsTr("Episode") + "\n[" + qobj.video_count + "]";
			tab:episodeview;
		}
	}

	TabGroup{
		id:tabgroup;
		anchors.top:buttonrow.bottom;
		anchors.bottom:parent.bottom;
		currentTab:baseinfo;

		TextListView{
			id:baseinfo;
			anchors.fill:parent;
			model:ListModel{id:infomodel}
		}

		Item{
			id:usergroup;
			anchors.fill:parent;
			Row{
				anchors.fill:parent;
				spacing:4;
				Rectangle{
					id:userbase;
					height:parent.height;
					width: constants.user_avatar_image_width;
					Column{
						anchors.fill:parent;
						spacing:2;
						Rectangle{
							anchors.horizontalCenter: parent.horizontalCenter;
							width: parent.width - border.width;
							height: width;
							smooth: true;
							// radius: width / 2;
							clip: true;
							border.width: 2;
							border.color: "skyblue";
							Image{
								id:avatar;
								anchors.centerIn: parent;
								width: parent.width - parent.border.width;
								height: width;
								source: qobj.userimg;
								smooth: true;
								/*
								Image{
									anchors.fill:parent;
									source:Qt.resolvedUrl("../image/verena_avatar_box.png");
									smooth:true;
								}
								*/
								MouseArea{
									anchors.fill:parent;
									enabled:root.canRecursion;
									onClicked:{
										mainpage.addNotification({option: "user_detail", value: qobj.username, thumbnail: qobj.userimg});
										var page = Qt.createComponent(Qt.resolvedUrl("UserDetailPage.qml"));
										pageStack.push(page, {username: qobj.username, userid: qobj.userid});
									}
								}
							}
						}
						Text{
							width:parent.width;
							height:(parent.height - avatar.width) / 2;
							horizontalAlignment: Text.AlignHCenter;
							verticalAlignment: Text.AlignVCenter;
							maximumLineCount:2;
							wrapMode:Text.WrapAnywhere;
							elide:Text.ElideRight;
							font.pixelSize:22;
							font.bold: true;
							text: qobj.username;
						}
						Button{
							width:parent.width;
							text:qsTr("User'playlist");
							enabled:root.canRecursion;
							onClicked:{
								mainpage.addNotification({option: "user_playlist", value: qobj.username, thumbnail: qobj.userimg});
								var page = Qt.createComponent(Qt.resolvedUrl("UserDetailPage.qml"));
								pageStack.push(page, {userid: qobj.userid, username: qobj.username, gowhere: "playlists"});
							}
						}
					}
				}
				TextListView{
					model:ListModel{id:usermodel}
					height:parent.height;
					width:parent.width - avatar.width;
				}
			}
		}

		EpisodeGridView{
			id:episodeview;
			anchors.fill:parent;
			model:ListModel{id:listmodel}
			canGetMore:qobj.page < qobj.maxPage;
			onRefresh:{
				qobj.getPlaylistEpisode();
			}
			onMore:{
				qobj.getPlaylistEpisode("more");
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
			enabled:qobj.internalPlaylistId.length !== 0;
			iconId: qobj.isCollected ? "toolbar-favorite-mark" : "toolbar-favorite-unmark";
			onClicked:{
				qobj.addOrRemoveCollection();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qobj.getPlaylistDetail();
				qobj.checkIsCollected();
				qobj.getPlaylistEpisode();
			}
		}
	}
	Component.onCompleted:{
		qobj.getPlaylistDetail();
		qobj.checkIsCollected();
		qobj.getPlaylistEpisode();
	}
}
