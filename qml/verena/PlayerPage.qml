import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script
import "../js/parserengine.js" as Parser

Page{
	id:root;

	property string videosource:"";
	property string videoid:"";
	property string source: "youku";

	orientationLock: qobj.playerOrientation === 0 ? PageOrientation.Automatic : (qobj.playerOrientation === 2 ? PageOrientation.LockPortrait : PageOrientation.LockLandscape);

	YoukuPlayerHelper{
		id: yk;
		vid: qobj.internalVideoId;
	}

	QtObject{
		id:qobj;

        property int count:20;
        //property int page:1;
        //property int maxPage:0;
        //property int total:0;
		property string internalVideoId:root.videoid;
		property bool loaded:false;
        //property string tags:"";
		property string category:"";
		property int playerOrientation: settingsObject.playerOrientation;

		// get video url
		function playVideo(vt, vp, ms)
		{
			var type = vt === undefined ? yk.playType : (Array.isArray(vt) ? vt[0] : vt);
			var part = vp === undefined ? yk.playPart : (Array.isArray(vp) ? vp[0] : vp);
			var initms = ms === undefined ? 0 : ms;
			if(settingsObject.youkuVideoUrlLoadOnce)
			{
				var url = yk.getVideoUrl(type, part);
				if(url)
					load(url, "youku", type, part, internalVideoId, initms);
				else
					setMsg(qsTr("Video is a preview."));
			}
			else // for older before 2016
				Parser.loadSource(internalVideoId, "youku", qobj, [type], yk.playQueue.length ? [yk.playQueue[part]] : [part], {settings: settingsObject, position: initms});
		}

		// stop
		function stoppedHandler(){
			addMsg(qsTr("Video playing finished"));
			if(root.videosource.length !== 0){
				exit();
				return;
			}
			loaded = false;
			yk.stop();
			addMsg(qsTr("Getting relative videos"));
			getRelateVideo();
		}

		// end of media
		function endOfMediaHandler(){
			addMsg(qsTr("Video playing finished"));
			if(loader.currentComponent === "VerenaPlayer"){
				loader.item.stopOnly();
			}
			if(root.videosource.length !== 0){
				exit();
				return;
			}
			loaded = false;
			if(yk.endOfMedia()){
				addMsg(qsTr("Loading next part of video"));
				qobj.playVideo();
			}else{
				stoppedHandler();
			}
		}

		// prev/next
		function playPartHandler(w){
			loaded = false;
			if(loader.currentComponent === "VerenaPlayer"){
				loader.item.stopOnly();
			}

			var r = yk.playAPart(w);
			if(r === 1)
			{
				addMsg(qsTr("Loading next part of video"));
				qobj.playVideo();
			}
			else if(r === 2)
			{
				stoppedHandler();
			}
			else if(r === -1){
				addMsg(qsTr("Loading previous part of video"));
				qobj.playVideo();
			}
			else if(r === -2)
			{
				setMsg(qsTr("This is first part"));
			}
		}

		// init
		function init(){
			if(root.videosource.length !== 0){
				var i = root.videosource.lastIndexOf("/");
				yk.vtitle = (i !== -1 ? root.videosource.substring(i + 1) : "");
				loadPlayer(root.videosource);
			}else if(internalVideoId.length !== 0){
				qobj.getStreamtypes();
			}
		}

		// get video streamtypes
		function getStreamtypes()
		{
			if(internalVideoId.length === 0){
				return;
			}
			show.visible = true;
			yk.reset();
			typemodel.clear();
			typebar.state = constants.state_show;
			function s(obj){
				yk.getStreamtypesArray(obj, typemodel);
				var tmp = [];
				yk.streamtypes.forEach(function(element){
					tmp.push(element.name);
				});
				if(tmp.length)
				playVideo(tmp, 0);
				else
				setMsg(qsTr("No streamtypes of video"));
				show.visible = false;
			}
			function f(err){
				show.visible = false;
				setMsg(err);
			}
			Script.getVideoStreamtypes(internalVideoId, s, f);
			//k	Parser.loadSource(vid, "youku", qobj, tmp, [0], {settings: settingsObject});
		}

		function addMsg(msg){
			logmodel.append({value: msg});
			if(logmodel.count > 20){
				logmodel.remove(0);
			}
		}
		
		// get relative
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
					addMsg(qsTr("Get %1 relative videos").arg(listmodel.count));
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

					 // exit
		function exit() {
			loader.sourceComponent = undefined;
			loader.currentComponent = "undefined";
			pageStack.pop(undefined, true);
		}

		// load relative view
		function loadGridView(){
			typebar.state = constants.state_hide;
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
				addMsg(qsTr("Load relative video fail"));
				return false;
			}
		}

		// parser engine callback
		function load(url, s, t, p, vid, data){
			var r = yk.loadHelper(t, p);
			if(r.type_changed)
			{
				typetc.selectedIndex = r.index;
				getPart(r.index, r.index2);
			}
			else
			{
				parttc.selectedIndex = r.index2;
			}
			typebar.state = constants.state_hide; // now hide it when loaded url
			var rurl = Script.GetPlayYKVideoUrl(url);
			loadPlayer(rurl, data.position);
		}

		// load player
		function loadPlayer(url, pos) {
			if(loader.currentComponent !== "VerenaPlayer"){
				loader.sourceComponent = undefined;
				loader.currentComponent = "undefined";
				addMsg(qsTr("Loading player..."));
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("VerenaPlayer.qml"));
				if (loader.status === Loader.Ready){
					loader.currentComponent = "VerenaPlayer";
					var item = loader.item;
					item.orientation = qobj.playerOrientation;
					item.source = url;
					item.tableEnabled = root.videosource.length === 0;
					item.canPrev = qobj.internalVideoId.length === 0 ? false : yk.playPart > 0;
					item.canNext = qobj.internalVideoId.length === 0 ? false : yk.playPart < yk.playQueue.length - 1;
					item.title = qobj.internalVideoId.length === 0 ? yk.vtitle : "%1_%2_part[%3]".arg(yk.vtitle).arg(yk.playType).arg(yk.playPart);
					item.playedMS = qobj.internalVideoId.length === 0 ? 0 : yk.getMilliseconds(yk.playType, yk.playPart - 1);
					item.totalMS = qobj.internalVideoId.length === 0 ? 0 : yk.getMilliseconds(yk.playType);
					item.endOfMedia.connect(endOfMediaHandler);
					item.requestShowType.connect(changeTypeBoxShow);
					item.requestPlayPart.connect(function(where){
						playPartHandler(where);
					});
					item.orientationChanged.connect(function(){
						qobj.playerOrientation = item.orientation;
					});
					item.seek.connect(function(value){
						if(qobj.internalVideoId.length === 0)
						{
							item.setPercent(value);
						}
						else
						{
							var r = yk.seekForAll(value);
							if(r)
							{
								if(r.part !== yk.playPart)
								{
									playVideo(yk.playType, r.part, r.millisecond);
								}
								else
								{
									item.setPosition(r.millisecond);
								}
							}
						}
					});
					item.stopped.connect(stoppedHandler);
					item.exit.connect(exit);
					item.load(pos);
					addMsg(qsTr("Load player successful"));
					loaded = true;
				}
				else{
					addMsg(qsTr("Load player fail"));
					loaded = false;
				}
			}else if(loader.currentComponent === "VerenaPlayer"){
				var item = loader.item;
				item.source = url;
				item.playedMS = qobj.internalVideoId.length === 0 ? 0 : yk.getMilliseconds(yk.playType, yk.playPart - 1);
				item.totalMS = qobj.internalVideoId.length === 0 ? 0 : yk.getMilliseconds(yk.playType);
				item.stopOnly();
				item.canPrev = qobj.internalVideoId.length === 0 ? false : yk.playPart > 0;
				item.canNext = qobj.internalVideoId.length === 0 ? false : yk.playPart < yk.playQueue.length - 1;
				item.title = qobj.internalVideoId.length === 0 ? yk.vtitle : "%1_%2_part[%3]".arg(yk.vtitle).arg(yk.playType).arg(yk.playPart);
				item.load(pos);
				loaded = true;
			}
		}

		// set tumbler data/sub data
		function getPart(index, sindex){
			yk.getPartModel(index, partmodel);
			parttc.selectedIndex = sindex;
		}

		// show streamtypes dialog, and set state.
		function changeTypeBoxShow(){
			if(typebar.state === constants.state_show){
				resetTumblerIndex();
				typebar.state = constants.state_hide;
			}else{
				typebar.state = constants.state_show;
			}
		}

		// reset tumbler index
		function resetTumblerIndex()
		{
			var r = yk.changeType();
			typetc.selectedIndex = r.index;
			parttc.selectedIndex = r.index2;
		}

	}

	Rectangle{
		anchors.fill: parent;
		color: "black";
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
		z: 30;
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
		z: 30;
		onClicked:{
			qobj.init();
		}
	}

	Rectangle{
		id:typebar;
		property int twidth: constants.player_right_bar_width;
		anchors{
			top:parent.top;
			right:parent.right;
			topMargin: constants.player_top_bar_height;
			bottom:parent.bottom;
			bottomMargin: constants.player_bottom_bar_height;
		}
		z: 20;
		opacity:0.6;
		color:"black";
		states:[
			State{
				name:constants.state_show;
				PropertyChanges {
					target: typebar;
					width: twidth;
				}
			}
			,
			State{
				name:constants.state_hide;
				PropertyChanges {
					target: typebar;
					width:0;
				}
			}
		]
        state:constants.state_hide;
        transitions: [
            Transition {
                from:constants.state_hide;
                to:constants.state_show;
                NumberAnimation{
                    target:typebar;
                    property:"width";
                    duration:400;
                    easing.type:Easing.OutExpo;
                }
            }
            ,
            Transition {
                from:constants.state_show;
                to:constants.state_hide;
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
			width: parent.width - closeicon.width;
			height: constants.player_streamtype_tumbler_height;
			visible: parent.width === parent.twidth;
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
			visible: parent.width === parent.twidth;
			z: 2;
			onClicked:{
				qobj.resetTumblerIndex();
				typebar.state = constants.state_hide;
			}
		}
		ToolIcon{
			id:playicon;
			iconId: "toolbar-mediacontrol-play";
			anchors.left:parent.left;
			anchors.bottom:parent.bottom;
			width:60;
			visible:parent.width === parent.twidth;
			z: 2;
			onClicked:{
				typebar.state = constants.state_hide;
				yk.setPlayQueue(typetc.selectedIndex, parttc.selectedIndex);
				qobj.playVideo();
			}
		}
	}

	Flickable{
		id: logitem;
		anchors{
			top:parent.top;
			left: parent.left;
			topMargin: constants.player_top_bar_height;
			bottom:parent.bottom;
			bottomMargin: constants.player_bottom_bar_height;
		}
		interactive: false;
		flickableDirection: Flickable.VerticalFlick;
		boundsBehavior: Flickable.StopAtBounds;
		width: parent.width;
		contentWidth: width;
		contentY: Math.max(logcol.height - height, 0);
		z: 2;
		clip: true;
		visible: show.visible || loader.status !== Loader.Ready;
		Column{
			id: logcol;
			width: parent.width;
			spacing: 2;
			Repeater{
				model:ListModel{id:logmodel}
				Text{
					width: logcol.width;
					height:25;
					font.pixelSize:24;
					color:"white";
					text:model.value;
				}
			}
		}
	}

	Loader{
		id:loader;
		property string currentComponent:"undefined";
		anchors.fill:parent;
		z: 1;
	}

	BusyIndicator{
		id:show;
		anchors.centerIn:parent;
		z: 50;
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

