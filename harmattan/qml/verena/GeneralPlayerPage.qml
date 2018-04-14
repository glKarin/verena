import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script
import "../js/parserengine.js" as Parser

Page{
	id:root;

	orientationLock: PageOrientation.LockLandscape;
	property string source:"";
	property string videoid:"";

	QtObject{
		id:qobj;

		property string internalVideoId:root.videoid;
		property string internalSource:root.source;
		property bool loaded:false;

		function init(){
			if(internalSource === "LocalHost"){
				loadPlayer(internalVideoId);
			}else{
				Parser.loadSource(internalVideoId, internalSource, qobj);
			}
		}

		function addMsg(msg){
			logmodel.append({value: msg});
			if(logmodel.count > 15){
				logmodel.remove(0);
			}
		}
		function exit() {
			loader.sourceComponent = undefined;
			pageStack.pop(undefined, true);
		}
		function endOfMediaHandler(){
			loaded = false;
		}

		function load(url, s, t, p, id){
			loadPlayer(url);
		}
		function loadPlayer(url) {
			if(loader.currentComponent === undefined){
				addMsg("正在载入播放器......");
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("GeneralVerenaPlayer.qml"));
				if (loader.status === Loader.Ready){
					var item = loader.item;
					item.source = url;
					item.exit.connect(exit);
					item.stopped.connect(endOfMediaHandler);
					item.load();
					addMsg("载入播放器成功");
					loaded = true;
				}
				else{
					addMsg("载入播放器失败");
				}
			}else{
				var item = loader.item;
				item.source = url;
				item.stopOnly();
				item.load();
			}
		}

	}

	ListModel{
		id:listmodel;
	}
	ToolIcon{
		id:back;
		iconId: "toolbar-back";
		anchors.right:parent.right;
		anchors.top:parent.top;
		enabled:visible;
		visible:!qobj.loaded;
		z:4;
		onClicked:{
			pageStack.pop(undefined, true);
		}
	}

	Button{
		anchors{
			right:parent.right;
			top:back.bottom;
			rightMargin:15;
			topMargin:20;
		}
		platformStyle:ButtonStyle {
			buttonWidth: buttonHeight; 
		}
		iconSource: "image://theme/icon-m-toolbar-refresh";
		enabled:visible;
		visible:!qobj.loaded;
		z:4;
		onClicked:{
			qobj.init();
		}
	}


	Rectangle{
		anchors.fill:parent;
		z:3;
		color:"black";
		Column{
			anchors.topMargin: 40;
			anchors.top:parent.top;
			width:parent.width;
			Repeater{
				model:ListModel{id:logmodel}
				Text{
					width:root.width;
					height:25;
					font.pixelSize:24;
					color:"white";
					text:model.value;
				}
			}
		}

		Loader{
			id:loader;
			anchors.fill:parent;
			z:1;
		}
	}

	BusyIndicator{
		id:show;
		anchors.centerIn:parent;
		z:2;
		platformStyle:BusyIndicatorStyle{
			size:"large";
			inverted:true;
		}
		visible:false;
		running:visible;
	}

	Component.onCompleted:{
		qobj.init();
	}

	Component.onDestruction:{
		loader.sourceComponent = undefined;
	}
}

