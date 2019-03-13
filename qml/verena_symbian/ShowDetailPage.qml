import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	property string showid:"";

	title: qsTr("Show Detail");

	QtObject{
		id:qobj;
		property string internalShowId:root.showid;
		property int page:1;
		property int maxPage:0;
		property int count:24;
		property int total:0;
		property bool isCollected:false;
		property string thumbnail:"";
		property variant rankingDialog:null;

		function addOrRemoveCollection(){
			if(isCollected){
				Script.removeCollection('ShowCollection', 'vid', internalShowId);
				setMsg(qsTr("Uncollect"));
				checkIsCollected();
			}else{
				if(!rankingDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("RankSelectionDialog.qml"));
					if(component.status == Component.Ready){
						rankingDialog = component.createObject(root);
						rankingDialog.selectedRank.connect(function(rank){
								Script.addCollection('ShowCollection', [qobj.internalShowId, name.text, qobj.thumbnail, (new Date()).getTime(), rank]);
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
			isCollected = Script.checkIsCollected('ShowCollection', internalShowId);
		}

		function getShowDetail(){
			root.show = true;
			infomodel.clear();
			detailgroup.currentTab = posterview;
			var opt = {
				show_id: internalShowId
			};
			function s(obj){
				if(!onFail(obj))
				{
					name.text = obj.name || "";
					qobj.thumbnail = obj.thumbnail; //k obj.poster;
					Script.makeShowDetailList(obj, infomodel);
					image.source = obj.poster_large || "";
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "shows_show", opt, s, f);
		}
		function getShowEpisode(o){
			root.show = true;
			if(o === "more"){
				page++;
			}else{
				page = 1;
				listmodel.clear();
			}
			var opt = {
				show_id: internalShowId,
				show_videotype: "正片",
                ////symbian
                orderby: "videoseq-desc",
				page: page,
				count: count
			};
			function s(obj){
				if(!onFail(obj))
				{
					total = obj.total;
					maxPage = Math.ceil(total / count)
					Script.makeVideoResultList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "shows_videos", opt, s, f);
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
			font.pixelSize:20;
			color:"blue";
			anchors.centerIn:parent;
			elide:Text.ElideRight;

			font.family: "Nokia Pure Text";
		}
	}

	ButtonRow{
		id:buttonrow;
		anchors.top:rect.bottom;
		width:parent.width;
		z:1;
		TabButton{
			text:qsTr("Poster");
			tab:posterview;
		}
		TabButton{
			text:qsTr("Detail");
			tab:detailview;
		}
		TabButton{
			text:qsTr("Episode") + "\n[" + qobj.total + "]";
			tab:gridview;
		}
	}

	TabGroup{
		id:detailgroup;
		anchors.fill:parent;
		anchors.topMargin:headheight + buttonrow.height + rect.height;
		currentTab:posterview;

		Rectangle{
			id:posterview;
			anchors.fill:parent;
			Image{
				id:image;
				anchors.fill:parent;
			}
		}

		TextListView{
			id:detailview;
			anchors.fill:parent;
			model:ListModel{id:infomodel}
		}

		EpisodeGridView{
			id:gridview;
			anchors.fill:parent;
			model:ListModel{id:listmodel}
			canGetMore:qobj.page < qobj.maxPage;
			onRefresh:{
				qobj.getShowEpisode();
			}
			onMore:{
				qobj.getShowEpisode("more");
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
			enabled:qobj.internalShowId.length !== 0;
			iconId: qobj.isCollected ? "toolbar-delete" : "toolbar-add";
			onClicked:{
				qobj.addOrRemoveCollection();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qobj.getShowDetail();
				qobj.checkIsCollected();
				qobj.getShowEpisode();
			}
		}
	}
	Component.onCompleted:{
		qobj.getShowDetail();
		qobj.checkIsCollected();
		qobj.getShowEpisode();
	}
}

