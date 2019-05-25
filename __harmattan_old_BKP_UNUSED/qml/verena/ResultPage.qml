import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	property string keyword:"";

	title:"<b>" + qsTr("Search") + "</b> \"" + keyword + "\"";

QtObject{
	id:qobj;
	property int page:1;
	property int maxPage:0;
	property int count:20;
	property int total:0;
	property string internalKeyword:root.keyword;
	property string orderby:schemas.videoSearchOrderbyList[5];

	onTotalChanged:{
		setMsg(qsTr("Search") + " \"" + internalKeyword + "\" : " + qsTr("videos") + ": " + total);
	}

	function reOrder(o){
		page = 1;
		orderby = schemas.videoSearchOrderbyList[o];
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
		var opt = {
			keyword: internalKeyword,
			period: "history",
			orderby: orderby,
			//streamtypes: 4, //4 - 3gphd
			page: page,
			count: count
		};
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
		Script.callAPI("GET", "searches_video_by_keyword", opt, s, f);
	}
}

Rectangle{
	id:rect;
	anchors.top:headbottom;
	width:parent.width;
	height:50;
	z:1;
	ButtonRow{
		id:buttonrow;
		anchors.fill:parent;
		Button{
			text:qsTr("Relevance");
			onClicked:{
				qobj.reOrder(5);
			}
		}
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
				qobj.reOrder(4);
			}
		}
	}
}

VideoListView{
	id:lst;
	anchors.fill:parent;
	anchors.topMargin:headheight + rect.height;
	visible:!show;
	max:qobj.maxPage;
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
