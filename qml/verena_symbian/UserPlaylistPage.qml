import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;

	property string username:"";
	property string userid:"";

	title: qsTr("User") + ": \"" + username + "\" " + qsTr("Playlist");

	QtObject{
		id:qobj;
		property string internalUserId:root.userid;
		property string internalUserName:root.username;
		property int playlistPage:1;
		property int playlistMaxPage:0;
		property int count:20;
		property int total:0;
		property string orderby:schemas.playlistOrderbyList[0];

		onTotalChanged:{
			setMsg(qsTr("User") + " \"" + internalUserName + "\": "  + qsTr("playlists") + ": " + total);
		}
		function reOrder(o) {
			playlistPage = 1;
			orderby = schemas.playlistOrderbyList[o];
			search();
		}
		function search(o){
			root.show = true;
			listmodel.clear();
			if(o === "next"){
				playlistPage++;
			}else if(o === "prev"){
				playlistPage --;
			}else if(o !== "this"){
				playlistPage = 1;
			}
			var opt = ({});
			if(internalUserId.length !== 0){
				opt.user_id = internalUserId;
			}
			if(internalUserName.length !== 0){
				opt.user_name = internalUserName;
			}
			opt.orderby = orderby;
			opt.page = playlistPage;
			opt.count = count;
			function s(obj){
				if(!onFail(obj))
				{
					total = obj.total;
					var i = total / count;
					playlistMaxPage = Math.ceil(i);
					Script.makePlaylistResultList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				playlistMaxPage = 0;
				setMsg(err);
			}
			Script.callAPI("GET", "playlists_by_user", opt, s, f);
		}
	}

	Rectangle{
		id:rect;
		anchors.top:headbottom;
		height: constants.scheme_nav_bar_height;
		width:parent.width;
		z:1;
		ButtonRow{
			id:buttonrow;
			anchors.fill:parent;
			Button{
				text:qsTr("Published");
				onClicked:{
					qobj.reOrder(0);
				}
			}
			Button{
				id:first;
				text:qsTr("View-count");
				onClicked:{
					qobj.reOrder(1);
				}
			}
		}
	}

	PlaylistListView{
		anchors.topMargin:headheight + rect.height;
		anchors.fill:parent;
		visible:!show;
		max:qobj.playlistMaxPage;
		model:ListModel{id:listmodel}
		canGetMore: false;
		canRecursion:false;
		onRefresh:{
			qobj.search("this");
		}
		onJump:{
			qobj.playlistPage = page;
			qobj.search("this");
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			id:back;
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		VButton{
			platformStyle: VButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource_2: "image://theme/icon-m-toolbar-previous";
			enabled:qobj.playlistPage > 1;
			onClicked:{
				qobj.search("prev");
			}
		}
		VButton{
			platformStyle: VButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource_2: "image://theme/icon-m-toolbar-next";
			enabled:qobj.playlistPage < qobj.playlistMaxPage;
			onClicked:{
				qobj.search("next");
			}
        }
        Text{
            width:parent.width / 4;
						height: parent.height;
						horizontalAlignment: Text.AlignHCenter;
						verticalAlignment: Text.AlignVCenter;
						maximumLineCount: 2;
						wrapMode: Text.WordWrap;
            elide:Text.ElideRight;
            font.pixelSize: constants.pixel_large;
            text:qobj.playlistPage + "/" + qobj.playlistMaxPage;
						color: "white";
        }
	}
	Component.onCompleted:{
		qobj.search();
	}
}

