import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	property string userid:"";
	property string username:"";
	property string gowhere:"";

	title:"<b>" + qsTr("User Detail") + "</b>";
	QtObject{
		id:qobj;
		property string internalUserName:root.username;
		property string internalUserId:root.userid;
		property string userName:"";
		property url userimg:"";
		property bool isCollected:false;
		property variant rankingDialog:null;

		function addOrRemoveCollection(){
			if(isCollected){
				Script.removeCollection('UserCollection', 'vid', internalUserId);
				setMsg(qsTr("Uncollect"));
				checkIsCollected();
			}else{
				if(!rankingDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("RankSelectionDialog.qml"));
					if(component.status == Component.Ready){
						rankingDialog = component.createObject(root);
						rankingDialog.selectedRank.connect(function(rank){
								Script.addCollection('UserCollection', [qobj.internalUserId, qobj.internalUserName, qobj.userimg, (new Date()).getTime(), rank]);
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
			isCollected = Script.checkIsCollected('UserCollection', internalUserId);
		}

		function getUserDetail(){
			root.show = true;
			usermodel.clear();
			var opt = ({});
			if(internalUserId.length !== 0){
				opt.user_id = internalUserId;
			}
			opt.user_name = internalUserName;
			function s(obj){
				if(!onFail(obj))
				{
					userimg = obj.avatar_large;
					root.userid = obj.id;
					userName = obj.name;
					Script.makeUserDetailList(obj, usermodel);
					checkIsCollected();
				}
				root.show = false;
				if(root.gowhere === "videos"){
					var page = Qt.createComponent(Qt.resolvedUrl("UserVideoPage.qml"));
					pageStack.push(page, {userid: qobj.internalUserId, username: qobj.userName}, true);
				}else if(root.gowhere === "playlists"){
					var page = Qt.createComponent(Qt.resolvedUrl("UserPlaylistPage.qml"));
					pageStack.push(page, {userid: qobj.internalUserId, username: qobj.userName}, true);
				}
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "users_show", opt, s, f);
		}
	}

	Column{
		id:layout
		anchors.fill:parent;
		anchors.topMargin:headheight;
		Item{
			id:userbase;
			height:160;
			width:parent.width;
			z:1;
			Row{
				anchors.fill:parent;
				spacing:5;
				Image{
					id:avatar;
					width:height;
					height:parent.height;
					source:qobj.userimg;
					smooth:true;
					Image{
						anchors.fill:parent;
						source:Qt.resolvedUrl("../image/verena_avatar_box.png");
						smooth:true;
					}
				}
				Item{
					height:parent.height;
					width:parent.width - avatar.width - parent.spacing;
					Text{
						anchors.verticalCenter:parent.verticalCenter;
						maximumLineCount:3;
						width:parent.width;
						wrapMode:Text.WrapAnywhere;
						elide:Text.ElideRight;
						font.pixelSize:28;
						text:"<b>" + qobj.userName + "</b>";
					}
				}
			}
		}

		ListItemHeader{
			id:header;
			z:1;
			text:qsTr("Description");
			item:lst;
		}
		VerenaRectangle{
			id:lst;
			theight:layout.height - header.height * 2 - usermore.height - userbase.height;
			TextListView{
				model:ListModel{id:usermodel}
				anchors.fill:parent;
				spacing:2;
				visible:parent.fullShow;
			}
		}

		ListItemHeader{
			text:qsTr("User more");
			item:usermore;
			z:1;
		}
		VerenaRectangle{
			id:usermore;
			z:1;
			theight:120;
			Column{
				anchors.fill:parent;
				visible:parent.fullShow;
				spacing:2;
				Repeater{
					model:ListModel{id:rectmodel}
					Rectangle{
						width:parent.width;
						height:parent.height / 2 - 1;
						color:qobj.internalUserId.length ? "lightskyblue" : "orange";
						Text{
							anchors.left:parent.left;
							color:"black";
							font.pixelSize:28;
							anchors.verticalCenter:parent.verticalCenter
							text:"<b>" + model.name +"</b>";
						}
						ToolIcon{
							anchors.right:parent.right;
							anchors.verticalCenter:parent.verticalCenter
							iconId: "toolbar-next";
						}
						MouseArea{
							anchors.fill:parent;
							enabled:qobj.internalUserId.length !== 0;
							onClicked:{
								if(model.sourceUrl === "UserVideoPage.qml"){
									mainpage.addNotification({option: "user_video", value: qobj.userName, thumbnail: qobj.userimg});
								}else if(model.sourceUrl === "UserPlaylistPage.qml"){
									mainpage.addNotification({option: "user_playlist", value: qobj.userName, thumbnail: qobj.userimg});
								}
								var page = Qt.createComponent(Qt.resolvedUrl(model.sourceUrl));
								pageStack.push(page, {userid: qobj.internalUserId, username: qobj.userName});
							}
						}
					}
				}
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
			enabled:qobj.internalUserId.length !== 0;
			iconId: qobj.isCollected ? "toolbar-favorite-mark" : "toolbar-favorite-unmark";
			onClicked:{
				qobj.addOrRemoveCollection();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qobj.getUserDetail();
			}
		}
	}
	Component.onCompleted:{
		rectmodel.append({name: "用户视频", sourceUrl: "UserVideoPage.qml"});
		rectmodel.append({name: "用户专辑", sourceUrl: "UserPlaylistPage.qml"});
		qobj.getUserDetail();
	}
}
