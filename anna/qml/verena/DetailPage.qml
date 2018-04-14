import QtQuick 1.1
import com.nokia.symbian 1.1
import karin.verena 1.5
import "../js/main.js" as Script
import "../js/parserengine.js" as Parser

VerenaPage{
	id:root;

	property string videoid:"";
	property bool canRecursion:true;
	title:"<b>" + qsTr("Detail") + "</b>";

	ListModel{
		id:typemodel;
	}

	QtObject{
		id:qobj;
		property string internalVideoId:root.videoid;
		property int page:1;
		property int maxPage:1;
		property int count:20;
		property int total:0;

		property variant streamtypesDialog:null;
		property variant rankingDialog:null;

		property string vtitle:"";
		property variant playQueue:[];
		property int playPart:0;
		property string playType:"";

		property string username;
		property string userid;
		property url userimg;
		property int comment_count;

		property string playerType:"";
		property bool isCollected:false;
		property string thumbnail:"";
		function resetPlayer(){
			if(loader.item !== null){
				loader.item.stopOnly();
				loader.sourceComponent = undefined;
			}
			playPart = 0;
			playType = "";
			playQueue = [];
			playerType = "";
		}

		function addMsg(msg){
			setMsg(msg);
		}

		function addOrRemoveCollection(){
			if(isCollected){
				Script.removeCollection('VideoCollection', 'vid', internalVideoId);
				setMsg(qsTr("Uncollect"));
				checkIsCollected();
			}else{
				if(!rankingDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("RankSelectionDialog.qml"));
                    if(component.status === Component.Ready){
						rankingDialog = component.createObject(root);
						rankingDialog.selectedRank.connect(function(rank){
								Script.addCollection('VideoCollection', [qobj.internalVideoId, qobj.vtitle, qobj.thumbnail, (new Date()).getTime(), rank]);
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
			isCollected = Script.checkIsCollected('VideoCollection', internalVideoId);
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

		function getVideoDetail(){
			root.show = true;
			infomodel.clear();
			tabgroup.currentTab = baseinfo;
			var opt = {
				video_id: internalVideoId
            };
            function s(obj){
                if(!onFail(obj))
                {
                    userid = obj.user.id || "";
                    username = obj.user.name || "";
                    vtitle = obj.title || "";
                    name.text = vtitle;
                    thumbnail = obj.thumbnail || "";
                    image.source = obj.bigThumbnail || "";
                    comment_count = obj.comment_count || 0;
                    Script.makeVideoDetailList(obj, infomodel);
                    getUserDetail();
                }
                root.show = false;
            }
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "videos_show", opt, s, f);
		}

		function getVideoComment(o){
			root.show = true;
			if(o === "more"){
				page++;
			}else{
				page = 1;
				listmodel.clear();
			}
			var opt = {
				video_id: internalVideoId,
				page: page,
				count: count
            };
            function s(obj){
                if(!onFail(obj))
                {
                    root.show = false;
                    total = obj.total;
                    maxPage = Math.ceil(total / count)
                    Script.makeVideoCommentList(obj, listmodel);
                }
            }
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "comments_by_video", opt, s, f);
		}

		function getStreamtypes(o){
			if(internalVideoId.length === 0){
				return;
			}
			playPart = 0;
			playQueue = [];
			playType = "";
			playerType = o;
			function s(obj){
				typemodel.clear();
				Script.makeStreamtypesModel(obj, typemodel);
				if(!streamtypesDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("StreamtypesDialog.qml"));
					if(component.status == Component.Ready){
						qobj.streamtypesDialog = component.createObject(root, {model: typemodel});
						qobj.streamtypesDialog.requestParse.connect(function(type, part){
							if(qobj.playerType === "External-player"){
								Parser.loadSource(qobj.internalVideoId, "youku", vplayer, [type], [part]);
							}else if(qobj.playerType === "Verena-player"){
								qobj.setPlayQueue(type, part);
								Parser.loadSource(qobj.internalVideoId, "youku", qobj, [type], [part]);
							}
						});
						qobj.streamtypesDialog.open();
					}
				}else{
					qobj.streamtypesDialog.model = typemodel;
					qobj.streamtypesDialog.open();
				}
			}
			function f(err){
				setMsg(err);
			}
			Script.getVideoStreamtypes(internalVideoId, s, f);
		}

		function stoppedHandler(){
			setMsg(qsTr("All end to play"));
			playPart = playQueue[playQueue.length - 1];
		}

		function load(url, t, p, vid){
			loadPlayer(url);
		}
		function loadPlayer(url) {
			if(loader.item === null){
				setMsg("正在载入播放器......");
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("VerenaPlayer.qml"));
				if (loader.status === Loader.Ready){
					var item = loader.item;
					item.source = url;
					item.canPrev = playPart > 0;
					item.canNext = playPart < playQueue.length - 1;
					item.title = "%1_%2_part[%3]".arg(vtitle).arg(playType).arg(playPart);
					item.endOfMedia.connect(endOfMediaHandler);
					item.requestShowType.connect(function(){
						if(streamtypesDialog){
							streamtypesDialog.open();
						}
					});
					item.requestPlayPart.connect(function(where){
						playPartHandler(where);
					});
					item.stopped.connect(stoppedHandler);
					item.exit.connect(function(){
						loader.sourceComponent = undefined;
					});
					item.load();
					setMsg(qsTr("Load Verena-Player successful"));
				}
				else{
					setMsg(qsTr("Load Verena-Player fail"));
				}
			}else{
				var item = loader.item;
				item.source = url;
				item.stopOnly();
				item.canPrev = playPart > 0;
				item.canNext = playPart < playQueue.length - 1;
				item.title = "%1_%2_part[%3]".arg(vtitle).arg(playType).arg(playPart);
				item.load();
			}
		}

		function setPlayQueue(type, part){
			playType = type;
			playPart = 0;
			var tmp = [];
			for(var i = 0; i < typemodel.count; i++){
				if(typemodel.get(i).type === type){
					for(var j = 0; j < typemodel.get(i).part.count; j++){
						tmp.push(typemodel.get(i).part.get(j).value);
						if(typemodel.get(i).part.get(j).value === part){
							playPart = j;
						}
					}
					break;
				}
			}
			playQueue = tmp;
		}

		function endOfMediaHandler(){
			setMsg(qsTr("End to play"));
			if(playPart < playQueue.length - 1){
				setMsg(qsTr("Loading next part video"));
				playPart ++;
				if(loader.item !== null){
					loader.item.stopOnly();
				}
				Parser.loadSource(internalVideoId, "youku", qobj, [playType], [playQueue[playPart]]);
			}else{
				stoppedHandler();
			}
		}

		function playPartHandler(w){
			if(loader.item !== null){
				loader.item.stopOnly();
			}
			if(w === "next"){
				if(playPart < playQueue.length - 1){
					setMsg(qsTr("Loading next part video"));
					playPart ++;
					Parser.loadSource(internalVideoId, "youku", qobj, [playType], [playQueue[playPart]]);
				}else{
					stoppedHandler();
				}
			}else if(w === "prev"){
				if(playPart > 0){
					setMsg(qsTr("Loading previous part video"));
					playPart --;
					Parser.loadSource(internalVideoId, "youku", qobj, [playType], [playQueue[playPart]]);
				}else{
					setMsg(qsTr("This is first part"));
				}
			}
		}
	}

	Rectangle{
		id:rect;
		color:"orange";
		width:parent.width;
		height:40;
		anchors.top:headbottom;
		z:1;
		AutoMoveText{
			id:name;
            pixelSize:20;
			color:"blue";
			anchors.verticalCenter:parent.verticalCenter;
			width:parent.width;
			isOver:true;
		}
	}

	Image{
		id:image;
		z:1;
        width:360;
        height:200;
		smooth:true;
		anchors.top:rect.bottom;
		Image{
			anchors.centerIn:parent;
			width:80;
			height:width;
			source: Qt.resolvedUrl("../image/verena-l-play.png");
			smooth:true;
			opacity:0.8;
			MouseArea{
				anchors.fill:parent;
				enabled:qobj.internalVideoId.length !== 0;
				onClicked:{
					mainpage.addSwipeSwitcher(qobj.vtitle, qobj.thumbnail, qobj.internalVideoId, "youku");
					qobj.getStreamtypes("Verena-player");
				}
			}
		}
		Loader{
			id:loader;
			anchors.fill:parent;
		}
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
			text:qsTr("Comment") + "\n[" + qobj.comment_count + "]";
			tab:commentlist;
		}
	}

	TabGroup{
		id:tabgroup;
		anchors.top:buttonrow.bottom;
		anchors.bottom:parent.bottom;
        width:parent.width;
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
                    width:120;
					Column{
						anchors.fill:parent;
						spacing:2;
						Image{
							id:avatar;
							width:parent.width;
							height:width;
							source:qobj.userimg;
							smooth:true;
							Image{
								anchors.fill:parent;
								source:Qt.resolvedUrl("../image/verena_avatar_box.png");
								smooth:true;
							}
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
						Text{
							width:parent.width;
							height:(parent.height - avatar.width) / 2;
							maximumLineCount:2;
							wrapMode:Text.WrapAnywhere;
							elide:Text.ElideRight;
                            font.pixelSize:18;
							font.family: "Nokia Pure Text";
							text:"<b>" + qobj.username + "</b>";
						}
                        ToolButton{
							width:parent.width;
							text:qsTr("User'video");
							enabled:root.canRecursion;
							onClicked:{
								mainpage.addNotification({option: "user_video", value: qobj.username, thumbnail: qobj.userimg});
								var page = Qt.createComponent(Qt.resolvedUrl("UserDetailPage.qml"));
								pageStack.push(page, {userid: qobj.userid, username: qobj.username, gowhere: "videos"});
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

		ListView{
			id:commentlist;
			anchors.fill:parent;
			model:ListModel{id:listmodel}
			header: Component{
				RefreshHeader {
					view:commentlist;
					onRefresh:{
						hide();
						qobj.getVideoComment();
					}
				}
			}
			spacing:4;
			delegate:Component{
				Rectangle{
					height:comment.height;
					width:ListView.view.width;
                    color:"white";
					//color:ListView.isCurrentItem?"lightskyblue":"white";
					Text{
						id:comment;
						width:parent.width;
						//color:parent.ListView.isCurrentItem?"red":"black";
                        font.pixelSize:16;
                        color:"black";
						font.family: "Nokia Pure Text";
						wrapMode:Text.WordWrap;
						text:"<b><big>" + model.username + ": </big></b>" + model.content;
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							commentlist.currentIndex = index;
						}
					}
				}
			}
			clip:true;
			footer:Component{
				GetMoreFooter{
					visible:qobj.page * qobj.count < qobj.total;
					width:ListView.view.width;
					onMore:{
						qobj.getVideoComment("more");
					}
				}
			}
			ScrollDecorator{
				flickableItem:parent;
			}
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				if(loader.item !== null){
					loader.item.stopOnly();
				}
				loader.sourceComponent = undefined;
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qobj.resetPlayer();
				qobj.getVideoDetail();
				qobj.checkIsCollected();
				qobj.getVideoComment();
			}
		}
        ToolButton{
			enabled:qobj.internalVideoId.length !== 0;
			iconSource: Qt.resolvedUrl("../image/verena-s-videos.png");
			onClicked:{
				mainpage.addSwipeSwitcher(qobj.vtitle, qobj.thumbnail, qobj.internalVideoId, "youku");
				qobj.resetPlayer();
				qobj.getStreamtypes("External-player");
			}
		}
        ToolButton{
			enabled:qobj.internalVideoId.length !== 0;
			iconSource: Qt.resolvedUrl("../image/verena-s-download.png");
			onClicked:{
				qobj.resetPlayer();
				var page = Qt.createComponent(Qt.resolvedUrl("DownloadPage.qml"));
				pageStack.push(page, {videoid: qobj.internalVideoId});
			}
		}
        ToolButton{
            iconSource: "toolbar-mediacontrol-play";
			enabled:qobj.internalVideoId.length !== 0;
			onClicked:{
				mainpage.addSwipeSwitcher(qobj.vtitle, qobj.thumbnail, qobj.internalVideoId, "youku");
				qobj.resetPlayer();
				var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
				pageStack.push(page, {videoid: qobj.internalVideoId}, true);
			}
		}
		ToolIcon{
			enabled:qobj.internalVideoId.length !== 0;
            iconId: qobj.isCollected ? "toolbar-delete" : "toolbar-add";
			onClicked:{
				qobj.addOrRemoveCollection();
			}
		}
		ToolIcon{
            iconId: "toolbar-list";
			onClicked:{
				var page = Qt.createComponent(Qt.resolvedUrl("DownloadPage.qml"));
				pageStack.push(page);
			}
		}
	}
	Component.onCompleted:{
		qobj.getVideoDetail();
		qobj.checkIsCollected();
		qobj.getVideoComment();
	}
	Component.onDestruction:{
		if(loader.item !== null){
			loader.item.stopOnly();
		}
		loader.sourceComponent = undefined;
	}
}
