import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/main.js" as Script
import "../js/parserengine.js" as Parser

VerenaPage{
	id:root;
	title: qsTr("Verena Browser");
	property string gotourl:Qt.resolvedUrl("../image/verena_home.html");

	QtObject{
		id:qobj;

		property variant dialog:null;

		function load(url, s, t, p, id){
			vut.copyToClipboard(url);
			setMsg(qsTr("Copy video url to clipboard successful"));
		}

		function addMsg(msg){
			setMsg(msg);
		}

		function handle(link){
			optionmodel.clear();
			var linkString = link.toString();
			//youku desktop
            var pattern = /^(http:\/\/)?v\.youku\.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
			if (linkString.match(pattern)) {
				var vid = linkString.match(pattern)[2];
				optionmodel.append({part: 0, source: "youku", vid: vid});
				option(link);
				return true;
			}
            /*
			//youku wap
			var wapyouku = /^(http:\/\/)?m\.youku\.com\/wap\/detail\?vid=([0-9a-zA-Z]+)(&.*)?/;
			if (linkString.match(wapyouku)) {
				var vid = linkString.match(wapyouku)[2];
				optionmodel.append({part: 0, source: "youku", vid: vid});
				option(link);
				return true;
			}
			//tencent desktop
			var tencent = /^(http:\/\/)?v\.qq\.com\/.*\?vid=([0-9a-zA-Z]+)(\.html)?/;
			if (linkString.match(tencent)) {
				var vid = linkString.match(tencent)[2];
				optionmodel.append({part: 0, source: "qq", vid: vid});
				option(link);
				return true;
			}
			//letv html5
			//http://m.letv.com/vplay_22290355.html
			var letvvideo = /^(http:\/\/)?m\.letv\.com\/vplay_(\d+)\.html/;
			if (linkString.match(letvvideo)) {
				var vid = linkString.match(letvvideo)[2];
				optionmodel.append({part: 0, source: "letvvideo", vid: vid});
				option(link);
				return true;
			}
			//letv video desktop
			//http://www.letv.com/ptv/vplay/22344307.html
			var letvvideodesktop = /^(http:\/\/)?www\.letv\.com\/ptv\/vplay\/(\d+)\.html/;
			if (linkString.match(letvvideodesktop)) {
				var vid = linkString.match(letvvideodesktop)[2];
				optionmodel.append({part: 0, source: "letvvideo", vid: vid});
				option(link);
				return true;
			}
			//sina desktop
			var sina = /^(http:\/\/)?video\.sina\.com\.cn\/.*\/#?(\d+)\.html/;
			if (linkString.match(sina)) {
				var vid = linkString.match(sina)[2];
				optionmodel.append({part: 0, source: "sina", vid: vid});
				option(link);
				return true;
			}
			//acfun desktop/html5
			var acMatch = linkString.match(/http:\/\/.*?acfun\.tv\/(lite\/)?v\/#?ac=?(\d+)/);
			if (acMatch){
				var acId = acMatch[2];
				function s(obj){
					if(obj.success && obj.data.hasOwnProperty("fullContent")){
						obj.data.fullContent.videos.forEach(function(e, i){
							optionmodel.append({part: i, source: e.type, vid: e.sourceId});
						});
						option(link);
					}else{
						if(webpagegroup.currentTab){
							webpagegroup.currentTab.url = link;
						}
					}
				}
				function f(err){
					setMsg(err);
					if(webpagegroup.currentTab){
						webpagegroup.currentTab.url = link;
					}
				}
				Script.getAcFunVideo(acId, s, f);
				return true;
            }*/
			return false;
		}

		function doLickClicked(link){
			//console.log(link);
			if (!settingsObject.browserAutoParseVideo || !handle(link)) {
				//fake open link in new window.
				/*
				 var linkString = link.toString();
				 var j = linkString.indexOf("://");
				 var i = linkString.indexOf("/", j + 3); //through "http(s)|ftp://"
				 var host = "";
				 if(i === -1){
					 host = linkString;
				 }else{
					 host = linkString.substring(0, i);
				 }
				 if(webpagegroup.currentTab && webpagegroup.currentTab.url.toString().indexOf(host) === 0)
				 */
				if(webpagegroup.currentTab && vut.newWindow(webpagegroup.currentTab.url, link)){
					webpagegroup.currentTab.url = link;
				}else{
					var component = Qt.createComponent(Qt.resolvedUrl("BrowserWebPage.qml"));
					if(component.status === Component.Ready){
						var obj = component.createObject(webpagegroup, {url: link});
						obj.linkClicked.connect(qobj.doLickClicked);
						obj.alert.connect(qobj.doAlert);
						tabmodel.append({title:obj.title, page: obj});
						obj.urlChanged.connect(function(){
                                                   try{
                                                       if(webpagegroup && webpagegroup.currentTab === obj){
                                                           textfield.text = obj.url;
                                                       }
                                                   }catch(e){
                                                       console.log("Page has destroyed");
                                                   }
						});
                        obj.titleChanged.connect(function(){
                                                     try{
                                                         for(var i = 0; i < tabmodel.count; i++){
                                                             if(tabmodel.get(i).page === obj){
                                                                 tabmodel.get(i).title = obj.title;
                                                                 break;
                                                             }
                                                         }
                                                     }catch(e){
                                                         console.log("Page has destroyed");
                                                     }
						});
						selectionlist.currentIndex = selectionlist.count - 1;
						webpagegroup.currentTab = obj;
					}else{
						console.log(component.errorString());
					}
				}
			}
		}

		function option(url){
			if(!dialog){
				var component = Qt.createComponent(Qt.resolvedUrl("BrowserDialog.qml"));
				if(component.status === Component.Ready){
					dialog = component.createObject(root, {url: url, model: optionmodel});
					dialog.request.connect(requestHandler);
					dialog.open();
				}
			}else{
				dialog.url = url;
				dialog.model = optionmodel;
				dialog.open();
			}
		}

		function requestHandler(option, source, vid){
			if(source === "youku"){
				mainpage.addNotification({option: "video_detail", value: vid, title: "优酷视频"});
				var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
				pageStack.push(page, {videoid:vid});
			}else{
				if(option === "play"){
					mainpage.addSwipeSwitcher("%1视频".arg(source === "qq" ? "腾讯" : source === "letv" ? "乐视云" : source === "letvvideo" ? "乐视" : source === "sina" ? "新浪" : "不支持源"), undefined, vid, source);
					if(settingsObject.defaultPlayer === 0){
						var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
						pageStack.push(page, {source: source, videosource: vid}, true);
					}else if(settingsObject.defaultPlayer === 1){
						Parser.loadSource(vid, source, vplayer, undefined, undefined, {settings: settingsObject});
					}
				}else if(option === "copy"){
					Parser.loadSource(vid, source, qobj, undefined, undefined, {settings: settingsObject});
				}else{
					if(webpagegroup.currentTab && settingsObject.browserAutoParseVideo){
						webpagegroup.currentTab.url = dialog.url;
					}else{
						Qt.openUrlExternally(dialog.url);
					}
				}
			}
		}

		function doAlert(message){
			setMsg(message);
		}
		function doGoTo(text){
			if(/^about:config/i.test(text)){
				var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
				pageStack.push(page, {gowhere: "browser"});
				return;
			}else if(/^about:verena/i.test(text)){
				var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
				pageStack.push(page, {gowhere: "about"});
				return;
			}
			if(webpagegroup.currentTab){
				if(/^((http|https|ftp|file):\/\/)?[^\/,\s]+\.[^\/,\s]+/.test(text)){
					webpagegroup.currentTab.url = vut.format(text);
				}else{
					var url = "http://m.baidu.com/s?word=%1".arg(textfield.text);
					textfield.text = url;
					webpagegroup.currentTab.url = url;
				}
			}
		}
	}

	ListModel{
		id:optionmodel;
	}

	Rectangle{
		id:urlinputbar;
		height:70;
		width:parent.width;
		anchors.top:headbottom;
		anchors.left:parent.left;
		color:"lightgrey";
		ProgressBar{
			id:progressbar;
			anchors{
				top:parent.top;
				leftMargin:40;
				rightMargin:40;
				left:parent.left;
				right:parent.right;
				topMargin:0 - height / 2;
			}
			maximumValue : 1;
			minimumValue : 0;
			value:webpagegroup.currentTab.progress;
			visible:value !== 1.0;
			z:2;
		}

		Row{
			anchors.fill:parent;
			anchors.topMargin:progressbar.height / 3 * 2;
			ToolIcon{
				id:back;
				iconId: "toolbar-tab-previous";
				anchors.verticalCenter: parent.verticalCenter;
				width:40;
				height:width;
				enabled:webpagegroup.currentTab !== null;
				visible:enabled;
				onClicked:{
					rect.visible = false;
					if(webpagegroup.currentTab){
						webpagegroup.currentTab.back.trigger();
					}
				}
			}
			ToolIcon{
				id:forward;
				iconId: "toolbar-tab-next";
				anchors.verticalCenter: parent.verticalCenter;
				width:40;
				height:width;
				enabled:webpagegroup.currentTab !== null;
				visible:enabled;
				onClicked:{
					rect.visible = false;
					if(webpagegroup.currentTab){
						webpagegroup.currentTab.forward.trigger();
					}
				}
			}
			TextField{
				id:textfield;
				placeholderText:qsTr("Input Url or Keyword");
				inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase;
				//text:"http://";
				anchors.verticalCenter:parent.verticalCenter;
				width:parent.width - forward.width - back.width - actions.width;
				platformRightMargin: clear.width;
				Keys.onReturnPressed:{
					textfield.closeSoftwareInputPanel();
					rect.visible = false;
					qobj.doGoTo(textfield.text);
				}
				onActiveFocusChanged:{
					if(activeFocus){
						//textfield.selectAll();
						rect.visible = true;
						textfield.openSoftwareInputPanel();
					}
				}
				ToolIcon{
					id:clear;
					width:45;
					anchors.right:parent.right;
					anchors.verticalCenter: parent.verticalCenter;
					enabled: !textfield.readOnly && textfield.text.length !== 0;
					visible:enabled;
					z:1;
					iconSource:Qt.resolvedUrl("../image/verena-m-clear.png");
					onClicked: {
						textfield.text="";
						textfield.forceActiveFocus();
					}
				}
			}
			ToolIcon{
				id:actions;
				iconId:webpagegroup.currentTab && webpagegroup.currentTab.progress === 1.0 ? "toolbar-refresh" : "toolbar-stop";
				enabled:webpagegroup.currentTab !== null;
				visible:enabled;
				width:40;
				height:width;
				anchors.verticalCenter: parent.verticalCenter;
				onClicked:{
					rect.visible = false;
					if(webpagegroup.currentTab){
						if(webpagegroup.currentTab.progress === 1.0){
							webpagegroup.currentTab.reload.trigger();
						}else{
							webpagegroup.currentTab.stop.trigger();
						}
					}
				}
			}
		}
	}

	Rectangle{
		id:rect;
		anchors.top:urlinputbar.bottom;
		width:parent.width;
		visible:false;
		color:"black";
		height:layout.height;
		z:4;
		opacity:0.8;
		Column{
			id:layout;
			width:parent.width;
			Item{
				visible:textfield.text.length !== 0;
				width:parent.width;
				height:visible ? 50 : 0;
				Text{
					anchors.verticalCenter:parent.verticalCenter;
					color:"white";
					font.pixelSize: constants.pixel_large;
					clip:true;
					width:parent.width;
					elide:Text.ElideMiddle;
					text:qsTr("Search") + " - " + textfield.text;
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						rect.visible = false;
						if(webpagegroup.currentTab && textfield.text.length !== 0) {
							var url = "http://m.baidu.com/s?word=%1".arg(textfield.text);
							textfield.text = url;
							webpagegroup.currentTab.url = url;
						}
					}
				}
			}
			Item{
				visible:textfield.text.length !== 0;
				width:parent.width;
				height:visible ? 50 : 0;
				Text{
					anchors.verticalCenter:parent.verticalCenter;
					color:"white";
					font.pixelSize: constants.pixel_large;
					clip:true;
					width:parent.width;
					elide:Text.ElideMiddle;
					text:qsTr("Go to") + " - " + textfield.text;
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						rect.visible = false;
						if(/^about:config/i.test(textfield.text)){
							var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
							pageStack.push(page, {gowhere: "browser"});
							return;
						}else if(/^about:verena/i.test(textfield.text)){
							var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
							pageStack.push(page, {gowhere: "about"});
							return;
						}
						if(webpagegroup.currentTab && textfield.text.length !== 0) {
							webpagegroup.currentTab.url = vut.format(textfield.text);
						}
					}
				}
			}
			Rectangle{
				width:parent.width - 20;
				height:5;
				color:"grey";
				anchors.horizontalCenter:parent.horizontalCenter;
			}
			ListView{
				width:parent.width;
				height:200;
				clip:true;
				model:ListModel{
					ListElement{
						name: "优酷视频";
						value: "http://www.youku.com";
                    }
                    /*
					ListElement{
						name: "AcFun主站";
						value: "http://www.acfun.tv";
					}
					ListElement{
						name: "AcFun主站Lite版";
						value: "http://www.acfun.tv/lite"
					}
					ListElement{
						name: "乐视手机版";
						value: "http://m.letv.com";
					}
					ListElement{
						name: "乐视";
						value: "http://www.letv.com";
					}
					ListElement{
						name: "新浪手机版";
						value: "http://sina.com.cn";
					}
					ListElement{
						name: "腾讯视频";
						value: "http://v.qq.com";
					}
                    */
					ListElement{
						name: "百度搜索";
						value: "http://www.baidu.com";
					}
					ListElement{
						name: "about:config";
						value: "about:config";
					}
					ListElement{
						name: "about:verena";
						value: "about:verena";
					}
				}
				delegate:Component{
					Item{
						width:ListView.view.width;
						height:45;
						Text{
							color:"white";
							font.pixelSize: constants.pixel_large;
							anchors.centerIn:parent;
							text:model.name;
						}
						MouseArea{
							anchors.fill:parent;
							onClicked:{
								if(/^about:config/i.test(model.value)){
									var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
									pageStack.push(page, {gowhere: "browser"});
									return;
								}else if(/^about:verena/i.test(model.value)){
									var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
									pageStack.push(page, {gowhere: "about"});
									return;
								}
								if(webpagegroup.currentTab){
									textfield.text = model.value;
									webpagegroup.currentTab.url = model.value;
									rect.visible = false;
								}
							}
						}
					}
				}
			}
			Rectangle{
				width:parent.width - 20;
				height:5;
				color:"grey";
				anchors.horizontalCenter:parent.horizontalCenter;
			}
			ToolIcon{
				iconId: Qt.resolvedUrl("../image/verena-m-close.png");
				anchors.horizontalCenter:parent.horizontalCenter;
				onClicked:{
					rect.visible = false
				}
			}
		}
	}

	ListView{
		id:selectionlist;
		anchors.top:urlinputbar.bottom;
		width:parent.width;
		height:50;
		z:1;
		interactive:count > 3;
		model:ListModel{id:tabmodel}
		delegate:Component{
			Rectangle{
				height:ListView.view.height;
				width:ListView.view.count < 4 ? ListView.view.width / ListView.view.count : 160;
				opacity:0.8;
				color:ListView.isCurrentItem?"lightskyblue":"black";
				Text{
					anchors.verticalCenter:parent.verticalCenter;
					anchors.left:parent.left;
					width:parent.width - close.width;
					color:parent.ListView.isCurrentItem ? "red" : "white";
					font.pixelSize: constants.pixel_medium;
					elide:Text.ElideRight;
					text:model.title;
					clip:true;
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						selectionlist.currentIndex=index;
						webpagegroup.currentTab = model.page;
						//textfield.text = model.page.url;
					}
				}
				ToolIcon{
					id:close;
					iconId: Qt.resolvedUrl("../image/verena-m-close.png");
					anchors.right:parent.right;
					anchors.verticalCenter:parent.verticalCenter;
					width:visible ? 50 : 0;
					visible:parent.ListView.view.count > 1;
					onClicked:{
						if(parent.ListView.view.count > 1){
							model.page.destroy();
							if(index < parent.ListView.view.count - 1){
								webpagegroup.currentTab = parent.ListView.view.model.get(index + 1).page;
							}else{
								webpagegroup.currentTab = parent.ListView.view.model.get(index - 1).page;
							}
							parent.ListView.view.model.remove(index);
						}
					}
				}
			}
		}
		clip:true;
		orientation:ListView.Horizontal;
	}

	TabGroup{
		id:webpagegroup;
		anchors.fill:parent;
		anchors.topMargin:headheight + selectionlist.height + urlinputbar.height;
		onCurrentTabChanged:{
			if(currentTab){
				textfield.text = currentTab.url;
			}
		}
	}

	tools:ToolBarLayout{
		id:toolbar;
		ToolIcon{
			iconId:"toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId:"toolbar-edit";
			visible:!settingsObject.browserAutoParseVideo;
			enabled:visible;
			onClicked:{
				if(webpagegroup.currentTab){
                    if(!qobj.handle(webpagegroup.currentTab.url)){
						setMsg(qsTr("No known video url"));
					}
				}
			}
		}
		ToolIcon{
			iconId:"toolbar-home";
			onClicked:{
				webpagegroup.currentTab.url = Qt.resolvedUrl("../image/verena_home.html");
			}
		}
	}
	Component.onCompleted:{
		qobj.doLickClicked(gotourl);
	}
}

