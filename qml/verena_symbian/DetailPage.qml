import QtQuick 1.1
import com.nokia.symbian 1.1
import karin.verena 1.5
import "../js/main.js" as Script
import "../js/parserengine.js" as Parser

VerenaPage{
	id:root;

	property string videoid:"";
	property bool canRecursion:true;
	title: qsTr("Detail");

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
		property string vtitle;

		property variant streamtypesDialog:null;
		property variant rankingDialog:null;

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
			if(streamtypesDialog)
			streamtypesDialog.yk.stop();
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
					if(component.status == Component.Ready){
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
					qobj.vtitle = obj.title || "";
					name.text = qobj.vtitle;
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

		// Begin(2019c)
		function getVideoComment(o)
		{
			if(1)
			getVideoComment_v2(o);
			else
			getVideoComment_v3(o);
		}

		function getVideoComment_v2(o){
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

		// v3
		function getVideoComment_v3(o){
			root.show = true;
			if(o === "more"){
				page++;
			}else{
				page = 1;
				listmodel.clear();
			}
			var opt = {
				vid: internalVideoId,
				pg: page - 1, // from 0
				pl: count,
				// top: true
			};
			function s(obj){
				if(!onFail(obj))
				{
					root.show = false;
					total = obj.total;
					maxPage = Math.ceil(total / count)
					Script.makeVideoCommentList_v3(obj, listmodel);
				}
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI_v3("GET", "comments_by_video_v3", opt, s, f);
		}
		// End()

		// get video url
		function playVideo(vt, vp, player_setting, ms)
		{
			var type = vt === undefined ? streamtypesDialog.yk.playType : (Array.isArray(vt) ? vt[0] : vt);
			var part = vp === undefined ? streamtypesDialog.yk.playPart : (Array.isArray(vp) ? vp[0] : vp);
			var player = player_setting ? playerType : constants.player_verena;
			var initms = ms === undefined ? 0 : ms;

			streamtypesDialog.yk.setPlayQueueByName(type, part);
			if(settingsObject.youkuVideoUrlLoadOnce)
			{
				var url = streamtypesDialog.yk.getVideoUrl(type, part);
				if(url)
				{
					if(player === constants.player_external)
					{
						vplayer.load(url);
					}
					else if(player === constants.player_verena)
					{
						load(url, "youku", type, part, internalVideoId, initms);
					}
				}
				else
					setMsg(qsTr("Video is a preview."));
			}
			else // for older before 2016
			{
				if(player === constants.player_external)
				{
					Parser.loadSource(internalVideoId, "youku", vplayer, [type], streamtypesDialog.yk.playQueue.length ? [streamtypesDialog.yk.playQueue[part]] : [part], {settings: settingsObject});
				}
				else if(player === constants.player_verena)
				{
					Parser.loadSource(internalVideoId, "youku", qobj, [type], streamtypesDialog.yk.playQueue.length ? [streamtypesDialog.yk.playQueue[part]] : [part], {settings: settingsObject, position: initms});
				}
			}
		}

		function getStreamtypes(o)
		{
			if(internalVideoId.length === 0){
				return;
			}
			if(streamtypesDialog)
				streamtypesDialog.yk.reset();
			playerType = o;
			function s(obj){
				typemodel.clear();
				if(!streamtypesDialog){
					var component = Qt.createComponent(Qt.resolvedUrl("StreamtypesDialog.qml"));
					if(component.status == Component.Ready){
						qobj.streamtypesDialog = component.createObject(root, {vid: internalVideoId, model: typemodel});
						qobj.streamtypesDialog.yk.getStreamtypesModel(obj, typemodel);
						qobj.streamtypesDialog.requestParse.connect(function(type, part, url){
							playVideo(type, part, true);
						});
						qobj.streamtypesDialog.open();
					}
				}else{
					qobj.streamtypesDialog.yk.getStreamtypesModel(obj, typemodel);
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
			streamtypesDialog.yk.stopToEnd();
		}

		function load(url, s, t, p, vid, data){
			var rurl = Script.GetPlayYKVideoUrl(url);
			loadPlayer(rurl, data.position);
		}

		function loadPlayer(url, pos) {
			if(loader.item === null){
				setMsg("正在载入播放器......");
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("VerenaPlayer.qml"));
				if (loader.status === Loader.Ready){
					var item = loader.item;
					item.source = url;
					item.canPrev = streamtypesDialog.yk.playPart > 0;
					item.canNext = streamtypesDialog.yk.playPart < streamtypesDialog.yk.playQueue.length - 1;
					item.title = "%1_%2_part[%3]".arg(qobj.vtitle).arg(streamtypesDialog.yk.playType).arg(streamtypesDialog.yk.playPart);
					item.playedMS = streamtypesDialog.yk.getMilliseconds(streamtypesDialog.yk.playType, streamtypesDialog.yk.playPart - 1);
					item.totalMS = streamtypesDialog.yk.getMilliseconds(streamtypesDialog.yk.playType);
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
					item.seek.connect(function(value){
						var r = streamtypesDialog.yk.seekForAll(value);
						if(r)
						{
							if(r.part !== streamtypesDialog.yk.playPart)
							{
								playVideo(streamtypesDialog.yk.playType, r.part, r.millisecond);
							}
							else
							{
								item.setPosition(r.millisecond);
							}
						}
					});
					item.load(pos);
					setMsg(qsTr("Load Verena-Player successful"));
				}
				else{
					setMsg(qsTr("Load Verena-Player fail"));
				}
			}else{
				var item = loader.item;
				item.source = url;
				item.stopOnly();
				item.canPrev = streamtypesDialog.yk.playPart > 0;
				item.canNext = streamtypesDialog.yk.playPart < streamtypesDialog.yk.playQueue.length - 1;
				item.title = "%1_%2_part[%3]".arg(qobj.vtitle).arg(streamtypesDialog.yk.playType).arg(streamtypesDialog.yk.playPart);
				item.playedMS = streamtypesDialog.yk.getMilliseconds(streamtypesDialog.yk.playType, streamtypesDialog.yk.playPart - 1);
				item.totalMS = streamtypesDialog.yk.getMilliseconds(streamtypesDialog.yk.playType);
				item.load(pos);
			}
		}

		function endOfMediaHandler(){
			setMsg(qsTr("End to play"));
			if(streamtypesDialog.yk.endOfMedia())
			{
				setMsg(qsTr("Loading next part video"));
				if(loader.item !== null){
					loader.item.stopOnly();
				}
				qobj.playVideo();
			}else{
				stoppedHandler();
			}
		}

		function playPartHandler(w){
			if(loader.item !== null){
				loader.item.stopOnly();
			}

			var r = streamtypesDialog.yk.playAPart(w);
			if(r === 1)
			{
				setMsg(qsTr("Loading next part video"));
				qobj.playVideo();
			}
			else if(r === 2)
			{
				stoppedHandler();
			}
			else if(r === -1){
				setMsg(qsTr("Loading previous part video"));
				qobj.playVideo();
			}
			else if(r === -2)
			{
				setMsg(qsTr("This is first part"));
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
			pixelSize: constants.pixel_xl;
			color:"blue";
			anchors.verticalCenter:parent.verticalCenter;
			width:parent.width;
			isOver:true;
		}
	}

	Image{
		id:image;
		z:1;
		width: constants.max_width;
		height: width * 9 / 16; // 19 : 9
		smooth:true;
		anchors.top:rect.bottom;
		anchors.left: parent.left; //k
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
					qobj.getStreamtypes(constants.player_verena);
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
		anchors.left: parent.left;
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
		width: parent.width;
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
							font.pixelSize: constants.pixel_xl;
							font.bold: true;
							text: qobj.username;
						}
						VButton{
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
					color: "white"; //color:ListView.isCurrentItem?"lightskyblue":"white";
					Text{
						id:comment;
						width:parent.width;
						color: "black"; //color:parent.ListView.isCurrentItem?"red":"black";
						font.pixelSize: constants.pixel_large;
						wrapMode:Text.WordWrap;
						text:"<b>" + model.username + ": </b>" + model.content;
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
		VButton{
			platformStyle: VButtonStyle {
				buttonWidth: buttonHeight; 
			}
			enabled:qobj.internalVideoId.length !== 0;
			iconSource: Qt.resolvedUrl("../image/verena-s-videos.png");
			onClicked:{
				mainpage.addSwipeSwitcher(qobj.vtitle, qobj.thumbnail, qobj.internalVideoId, "youku");
				qobj.resetPlayer();
				qobj.getStreamtypes(constants.player_external);
			}
		}
		VButton{
			platformStyle: VButtonStyle {
				buttonWidth: buttonHeight; 
			}
			enabled:qobj.internalVideoId.length !== 0;
			iconSource: Qt.resolvedUrl("../image/verena-s-download.png");
			onClicked:{
				qobj.resetPlayer();
				var page = Qt.createComponent(Qt.resolvedUrl("DownloadPage.qml"));
				pageStack.push(page, {videoid: qobj.internalVideoId});
			}
		}
		VButton{
			platformStyle: VButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource_2: "image://theme/icon-m-toolbar-mediacontrol-play";
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
			iconId: qobj.isCollected ? "toolbar-favorite-mark" : "toolbar-favorite-unmark";
			onClicked:{
				qobj.addOrRemoveCollection();
			}
		}
		ToolIcon{
			iconId: "toolbar-directory-move-to";
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
