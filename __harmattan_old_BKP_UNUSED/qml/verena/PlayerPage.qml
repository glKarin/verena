import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script
import "../js/parserengine.js" as Parser

Page{
	id:root;

	orientationLock: PageOrientation.LockLandscape;
	property string videosource:"";
	property string videoid:"";

	QtObject{
		id:qobj;

        property int count:20;
        //property int page:1;
        //property int maxPage:0;
        //property int total:0;
		property string internalVideoId:root.videoid;
		property bool loaded:false;
		property string vtitle:"";
        //property string tags:"";
		property string category:"";
		property variant streamtypes:[];
		property variant playQueue:[];
		property int playPart:0;
		property string playType:"";

		function setPlayQueue(ti, pi){
			playType = streamtypes[ti].name;
			var tmp = [];
			streamtypes[ti].value.forEach(function(e){
				tmp.push(e.value);
			});
			playQueue = tmp;
			playPart = pi;
		}

		function stoppedHandler(){
			addMsg("视频播放结束");
			if(root.videosource.length !== 0){
				exit();
				return;
			}
			loaded = false;
			playType = "";
			playPart = 0;
			playQueue = [];
			addMsg("正在取得与该视频相关视频");
            getRelateVideo();
		}

		function endOfMediaHandler(){
			addMsg("视频播放结束");
			if(loader.currentComponent === "VerenaPlayer"){
				loader.item.stopOnly();
			}
			if(root.videosource.length !== 0){
				exit();
				return;
			}
			loaded = false;
			if(playPart < playQueue.length - 1){
				addMsg("正在载入下一部分视频");
				playPart ++;
				Parser.loadSource(internalVideoId, "youku", qobj, [playType], [playQueue[playPart]]);
			}else{
				stoppedHandler();
			}
        }

		function playPartHandler(w){
			loaded = false;
			if(loader.currentComponent === "VerenaPlayer"){
				loader.item.stopOnly();
			}
			if(w === "next"){
				if(playPart < playQueue.length - 1){
					addMsg("正在载入下一部分视频");
					playPart ++;
					Parser.loadSource(internalVideoId, "youku", qobj, [playType], [playQueue[playPart]]);
				}else{
					stoppedHandler();
				}
			}else if(w === "prev"){
				if(playPart > 0){
					addMsg("正在载入上一部分视频");
					playPart --;
					Parser.loadSource(internalVideoId, "youku", qobj, [playType], [playQueue[playPart]]);
				}else{
					setMsg(qsTr("This is first part"));
				}
			}
		}

		function init(){
			if(root.videosource.length !== 0){
				var i = root.videosource.lastIndexOf("/");
				vtitle = (i !== -1 ? root.videosource.substring(i + 1) : "");
				loadPlayer(root.videosource);
			}else if(internalVideoId.length !== 0){
				getStreamtypes();
			}
		}
		function addMsg(msg){
			logmodel.append({value: msg});
			if(logmodel.count > 15){
				logmodel.remove(0);
			}
		}

        function getRelateVideo(){
            if(internalVideoId.length === 0){
                exit();
                return;
            }
            show.visible = true;
            listmodel.clear();
            if(!loadGridView()){
                show.visible = false;
                return;
            }
            loader.item.error = false;
            var opt = {
                video_id: internalVideoId,
                count: count
            };
            function s(obj){
							if(!onFail(obj))
							{
								loader.item.error = false;
								Script.makeVideoResultList(obj, listmodel)
								addMsg("已取得%1个相关视频".arg(listmodel.count));
							}
							else
							{
								loader.item.error = true;
							}
							show.visible = false;
            }
            function f(err){
                loader.item.error = true;
                show.visible = false;
                setMsg(err);
            }
            Script.callAPI("GET", "videos_by_related", opt, s, f);

        }
        /*
		//相关视频接口，测试未返回任何视频信息，无效。使用标签搜索接口
		function getRelateVideoBySameTags(option){
			if(videosource.length !== 0 || tags.length === 0){
				exit();
				return;
			}
			show.visible = true;
			listmodel.clear();
			if(!loadGridView()){
				show.visible = false;
				return;
			}
			loader.item.error = false;
			if(option === "next"){
				page++;
			}else if(option === "prev"){
				page --;
			}else if(option !== "this"){
				page = 1;
			}
			var opt = {
				tag: tags,
				period: "history",
				orderby: "relevance",
				page: page,
				count: count
			};

             //if(category.length !== 0){
                 //opt.category = category;
            // }
             //opt.period = "history";
            //opt.orderby = "relevance";
             //opt.page = page;
            //opt.count = count;

			function s(obj){
				loader.item.error = false;
				total = obj.total;
				maxPage = Math.ceil(total / count);
				Script.makeVideoResultList(obj, listmodel)
				addMsg("已取得相关视频: %1/%2".arg(page).arg(maxPage));
				show.visible = false;
			}
			function f(err){
				loader.item.error = true;
				show.visible = false;
				setMsg(err);
			}
			Script.callAPI("GET", "searches_video_by_tag", opt, s, f);
		}
            */

		function exit() {
			loader.sourceComponent = undefined;
			loader.currentComponent = "undefined";
			pageStack.pop(undefined, true);
		}

		function loadGridView(){
			typebar.state = "noshow";
			loader.sourceComponent = undefined;
			loader.currentComponent = "undefined";
			loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("RelateVideoGridView.qml"));
			if (loader.status === Loader.Ready){
				loader.currentComponent = "RelateVideoGridView";
				var item = loader.item;
				item.model = listmodel;
				item.visible = true;
				return true;
			} else{
				addMsg("载入相关视频列表失败");
				return false;
			}
		}
		function load(url, s, t, p, vid){
			var index = 0, index2 = 0;
			for(var i in streamtypes){
				if(streamtypes[i].name === t){
					index = i;
					break;
				}
			}
			for(var j in streamtypes[index].value){
				if(streamtypes[index].value[j].value === p){
					index2 = j;
					break;
				}
			}
			if(playType !== streamtypes[index].name){
				playType = streamtypes[index].name;
				typetc.selectedIndex = index;
				getPart(index, index2);
				setPlayQueue(index, index2);
			}else{
				playPart = index2;
				parttc.selectedIndex = index2;
			}
			typebar.state = "show";
			loadPlayer(url);
		}
		function loadPlayer(url) {
			if(loader.currentComponent !== "VerenaPlayer"){
				loader.sourceComponent = undefined;
				loader.currentComponent = "undefined";
				addMsg("正在载入播放器......");
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("VerenaPlayer.qml"));
				if (loader.status === Loader.Ready){
					loader.currentComponent = "VerenaPlayer";
					var item = loader.item;
					item.source = url;
					item.tableEnabled = root.videosource.length === 0;
					item.canPrev = playPart > 0;
					item.canNext = playPart < playQueue.length - 1;
					item.title = qobj.internalVideoId.length === 0 ? vtitle : "%1_%2_part[%3]".arg(vtitle).arg(playType).arg(playPart);
					item.endOfMedia.connect(endOfMediaHandler);
					item.requestShowType.connect(changeTypeBoxShow);
					item.requestPlayPart.connect(function(where){
						playPartHandler(where);
					});
					item.stopped.connect(stoppedHandler);
					item.exit.connect(exit);
					item.load();
					addMsg("载入播放器成功");
					loaded = true;
				}
				else{
					addMsg("载入播放器失败");
					loaded = false;
				}
			}else if(loader.currentComponent === "VerenaPlayer"){
				var item = loader.item;
				item.source = url;
				item.stopOnly();
				item.canPrev = playPart > 0;
				item.canNext = playPart < playQueue.length - 1;
				item.title = qobj.internalVideoId.length === 0 ? vtitle : "%1_%2_part[%3]".arg(vtitle).arg(playType).arg(playPart);
				item.load();
				loaded = true;
			}
		}

		function getStreamtypes(){
			if(internalVideoId.length === 0){
				return;
			}
			playPart = 0;
			playQueue = [];
			playType = "";
			show.visible = true;
			typemodel.clear();
			typebar.state = "show";
			streamtypes = [];
            function s(obj){
                ////symbian
                if(obj.data){
                    //tags = obj.data.video.tags.join(",");
                    vtitle = obj.data.video.title || "";
                }
				streamtypes = Script.makeStreamtypes(obj, true);
				var tmp = [];
				streamtypes.forEach(function(element){
					tmp.push(element.name);
					typemodel.append({value: element.name});
				});
				getPart(0, 0);
				Parser.loadSource(internalVideoId, "youku", qobj, tmp, [0]);
				show.visible = false;
			}
			function f(err){
				show.visible = false;
				setMsg(err);
			}
			Script.getVideoStreamtypes(internalVideoId, s, f);
		}
		function getPart(index, sindex){
			partmodel.clear();
			streamtypes[index].value.forEach(function(element){
				partmodel.append(element);
			});
			parttc.selectedIndex = sindex;
		}

		function changeTypeBoxShow(){
			if(typebar.state === "show"){
				var index = 0, index2 = 0;
				for(var i in qobj.streamtypes){
					if(qobj.streamtypes[i].name === qobj.playType){
						index = i;
						break;
					}
				}
				typetc.selectedIndex = index;
				for(var j in qobj.streamtypes[index].value){
					if(qobj.streamtypes[index].value[j].value === qobj.playPart){
						index2 = j;
						break;
					}
				}
				parttc.selectedIndex = index2;
				typebar.state = "noshow";
			}else{
				typebar.state = "show";
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
		id:replay;
		anchors.right:back.left;
		anchors.top:parent.top;
		anchors.topMargin:7;
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
		id:typebar;
		anchors{
			top:parent.top;
			right:parent.right;
			topMargin:60;
			bottom:parent.bottom;
			bottomMargin:60;
		}
		z:4;
		opacity:0.6;
		color:"black";
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: typebar;
                    width:320;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: typebar;
					width:0;
				}
			}
		]
        state:"noshow";
        transitions: [
            Transition {
                from:"noshow";
                to:"show";
                NumberAnimation{
                    target:typebar;
                    property:"width";
                    duration:400;
                    easing.type:Easing.OutExpo;
                }
            }
            ,
            Transition {
                from:"show";
                to:"noshow";
                NumberAnimation{
                    target:typebar;
                    property:"width";
                    duration:400;
                    easing.type:Easing.InExpo;
                }
            }
        ]

		Rectangle{
			id:tumbler;
			anchors.top:parent.top;
			anchors.right:parent.right;
            width:260;
			height:360;
            visible:parent.width === 320;
			z:1;
			Tumbler {
				anchors.fill:parent;
				opacity:0.8;
				columns: [typetc, parttc];
				TumblerColumn {
					id:typetc;
					label:qsTr("Streamtypes");
					items:ListModel{id:typemodel}
					selectedIndex: 0;
					onSelectedIndexChanged:{
						qobj.getPart(selectedIndex, 0);
					}
				}

				TumblerColumn {
					id:parttc;
					label:qsTr("Parts");
					items:ListModel{id:partmodel}
					selectedIndex: 0;
					onSelectedIndexChanged:{
						if(selectedIndex === -1){
							selectedIndex = 0;
						}
					}
				}
			}
		}
		ToolIcon{
			id:closeicon;
			iconId: "toolbar-close";
			anchors.left:parent.left;
			anchors.top:parent.top;
			width:60;
            visible:parent.width === 320;
			z:1;
			onClicked:{
				var index = 0, index2 = 0;
				for(var i in qobj.streamtypes){
					if(qobj.streamtypes[i].name === qobj.playType){
						index = i;
						break;
					}
				}
				typetc.selectedIndex = index;
				for(var j in qobj.streamtypes[index].value){
					if(qobj.streamtypes[index].value[j].value === qobj.playPart){
						index2 = j;
						break;
					}
				}
				parttc.selectedIndex = index2;
				typebar.state = "noshow";
			}
		}
		ToolIcon{
			id:playicon;
			iconId: "toolbar-mediacontrol-play";
			anchors.left:parent.left;
			anchors.bottom:parent.bottom;
			width:60;
            visible:parent.width === 320;
			z:1;
			onClicked:{
				typebar.state = "noshow";
				qobj.setPlayQueue(typetc.selectedIndex, parttc.selectedIndex);
				Parser.loadSource(qobj.internalVideoId, "youku", qobj, [qobj.playType], [qobj.playQueue[qobj.playPart]]);
			}
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
			property string currentComponent:"undefined";
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

