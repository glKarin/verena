import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	property string userid:"";
	property string username:"";

	title:"<b>" + qsTr("User") + "</b> \"" + username + "\" " + qsTr("Video");

	QtObject{
		id:qobj;
		property int page:1;
		property int maxPage:0;
		property int count:20;
		property int total:0;
		property string internalUserId:root.userid;
		property string internalUserName:root.username;
		property string orderby:schemas.videoUserOrderbyList[0];

		onTotalChanged:{
			setMsg(qsTr("User") + " \"" + internalUserName + "\": " + qsTr("videos") + ": " + total);
		}

		function reOrder(o){
			page = 1;
			orderby = schemas.videoUserOrderbyList[o];
			search();
		}

		function search(o){
			root.show = true;
			listmodel.clear();
			if(o === "prev"){
				page --;
			}else if(o === "next"){
				page++;
			}else if(o !== "this"){
				page = 1;
			}
			var opt = ({});
			if(internalUserId.length !== 0){
				opt.user_id = internalUserId;
			}
			if(internalUserName.length !== 0){
				opt.user_name = internalUserName;
			}
			opt.orderby = orderby;
			opt.page = page;
			opt.count = count;
			function s(obj){
				if(!onFail(obj))
				{
					total = obj.total;
					var i = total / count;
					maxPage = Math.ceil(i);
					Script.makeVideoResultList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				maxPage = 0;
				setMsg(err);
			}
			Script.callAPI("GET", "videos_by_user", opt, s, f);
		}
	}

	ButtonRow{
		id:buttonrow;
		anchors.top:headbottom;
		width:parent.width;
		z:1;
		Button{
			text:qsTr("Published");
			onClicked:{
				qobj.reOrder(0);
			}
		}
		Button{
			text:qsTr("View-count");
			onClicked:{
				qobj.reOrder(1);
			}
		}
		Button{
			text:qsTr("Favorite-count");
			onClicked:{
				qobj.reOrder(3);
			}
		}
		Button{
			text:qsTr("Comment-count");
			onClicked:{
				qobj.reOrder(4);
			}
		}
	}

	VideoListView{
		id:lst;
		anchors.fill:parent;
		anchors.topMargin:headheight + buttonrow.height;
		visible:!show;
		max:qobj.maxPage;
		canRecursion:false;
		model:ListModel{id:listmodel}
		onRefresh:{
			qobj.search("this");
		}
		onJump:{
			qobj.page = page;
			qobj.search("this");
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		Button{
			platformStyle:ButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource: "image://theme/icon-m-toolbar-previous";
			enabled:qobj.page > 1;
			onClicked:{
				qobj.search("prev");
			}
		}
		Button{
			platformStyle:ButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource: "image://theme/icon-m-toolbar-next";
			enabled:qobj.page < qobj.maxPage;
			onClicked:{
				qobj.search("next");
			}
        }
        Text{
            width:parent.width/4;
            elide:Text.ElideRight;
            font.pixelSize:20;
            text:qobj.page + "/" + qobj.maxPage;
        }
	}
	Component.onCompleted:{
		qobj.search();
	}
}
