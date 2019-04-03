import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

VerenaPage{
	id:root;
	title: qsTr("Setting");
	extraToolEnabled:false;
	property string cachesize;
	property int historysize:0;
	property string gowhere:"";
	property string browsercachesize;

	QtObject{
		id: qobj;
		property bool ykedit: false;

		function makeUserAgent(uas)
		{
			if(!uas)
				return null;

			var r = [];
			for(var k in uas)
			{
				r.push({
					value: k,
					text: uas[k]
				});
			}
			return r;
		}

		function setYoukuSetting()
		{
			var ykm = [
				{name: "youku_ccode", setting: "youku/ccode"},
				{name: "youku_client_ip", setting: "youku/client_ip"},
				{name: "youku_ckey", setting: "youku/ckey"},
				{name: "youku_ua", setting: "youku/ua"},
				{name: "youku_referer", setting: "youku/referer"}
			];
			for(var i = 0; i < ykm.length; i++)
			{
				settingsObject[ykm[i].name] = vut.getSetting(ykm[i].setting);
				ykmodel.get(i).value = settingsObject[ykm[i].name];
			}
			ykrepeater.modelChanged(ykmodel);
			//k settingsObject.youkuVideoUrlLoadOnce = vut.getSetting("youku_video_url_load_once");
		}

		function allowEditYoukuSetting()
		{
			openQueryDialog(
				qsTr("Warning"),
				qsTr("This settings is used by request for getting Youku video url. If not notified, do not change them. If you want to reset them when you have changed them, press 'Reset' to set default."),
				qsTr("Edit"),
				qsTr("No edit"),
				function(){
					ykedit = true;
					ykswitcher.checked = true;
				},
				function(){
					ykedit = false;
					ykswitcher.checked = false;
				});
			}

			function makeYoukuModel()
			{
				ykmodel.clear();
				ykmodel.append({
					name: "ccode",
					setting: "youku_ccode",
					value: settingsObject["youku_ccode"],
					desc: qsTr("Get Youku video url request parameter")
				});
				ykmodel.append({
					name: "client_ip",
					setting: "youku_client_ip",
					value: settingsObject["youku_client_ip"],
					desc: qsTr("Get Youku video url request parameter")
				});
				ykmodel.append({
					name: "ckey",
					setting: "youku_ckey",
					value: settingsObject["youku_ckey"],
					desc: qsTr("Get Youku video url request parameter")
				});
				ykmodel.append({
					name: "User-Agent",
					setting: "youku_ua",
					value: settingsObject["youku_ua"],
					desc: qsTr("Get Youku video url request header")
				});
				ykmodel.append({
					name: "Referer",
					setting: "youku_referer",
					value: settingsObject["youku_referer"],
					desc: qsTr("Get Youku video url request header")
				});
			}
		}

		ButtonRow{
			id:buttonrow;
			width:parent.width;
			anchors.top:headbottom;
			anchors.left:parent.left;
			z:1;
			TabButton{
				text:qsTr("General");
				tab:generaltab;
			}
			TabButton{
				text:qsTr("Browser");
				tab:browsertab;
			}
			TabButton{
				text:qsTr("Other");
				tab:othertab;
			}
		}

		TabGroup{
			id:tabgroup;
			anchors.fill:parent;
			anchors.topMargin:headheight + buttonrow.height;
			currentTab:generaltab;
			Flickable{
				id:generaltab;
				anchors.fill:parent;
				contentWidth:width;
				clip:true;
				contentHeight:mainlayout.height;
				Column{
					id:mainlayout;
					width: parent.width;
					SectionItem{
						text: qsTr("Setting");
						content: Column{
							width: parent.width;
							SelectionItem{
								text: qsTr("Default Video Player");
								subitems: [
									{
										text: qsTr("Verena Player"),
										value: 0,
									},
									{
										text: qsTr("External Player"),
										value: 1,
									}
								]
								currentValue: settingsObject.defaultPlayer;
								onClicked:{
									settingsObject.defaultPlayer = value;
								}
							}
							SelectionItem{
								text: qsTr("Default External Player");
								subitems: [
									{
										text: qsTr("Harmattan Video-Suite"),
										value: 0,
									},
									{
										text: qsTr("Harmattan Grob Browser"),
										value: 1,
										enabled: false,
									},
									{
										text: qsTr("External KMPlayer"),
										value: 2,
										enabled: false,
									}
								]
								currentValue: settingsObject.externalPlayer;
								onClicked: {
									settingsObject.externalPlayer = value;
								}
							}
							SwitchItem{
								text: qsTr("VerenaTouchHome Lock Portrait");
								checked: settingsObject.vthomeLockOrientation;
								onCheckedChanged: {
									settingsObject.vthomeLockOrientation = checked;
								}
							}
							SwitchItem{
								text: qsTr("Fullscreen");
								enabled: false;
								checked: settingsObject.fullScreen;
								onCheckedChanged: {
									settingsObject.fullScreen = checked;
								}
							}
							SwitchItem{
								text: qsTr("Player Corner");
								enabled: false;
								checked: settingsObject.playerCorner;
								onCheckedChanged: {
									settingsObject.playerCorner = checked;
								}
							}
							SelectionItem{
								text: qsTr("Player Orientation");
								subitems: [
									{
										text: qsTr("Automatic"),
										value: 0,
									},
									{
										text: qsTr("Lock Landscape"),
										value: 1,
									},
									{
										text: qsTr("Lock Portrait"),
										value: 2,
									}
								]
								currentValue: settingsObject.playerOrientation;
								onClicked: {
									settingsObject.playerOrientation = value;
								}
							}
						}
					}
					SectionItem{
						text: qsTr("Utility");
						content: Column{
							width: parent.width;
							ButtonItem{
								text: qsTr("Cache Size") + ": " + root.cachesize;
								buttonText: qsTr("Clear cache");
								onClicked: {
									vut.clearDiskCache();
									var cache = vut.castDiskCache();
									root.cachesize = "%1/%2".arg(Utility.FormatSize(cache["current"])).arg(Utility.FormatSize(cache["total"]));
									setMsg(qsTr("Clean disk cache successful"));
								}
							}
							ButtonItem{
								text: qsTr("Search History Size") + ": " + root.historysize;
								buttonText: qsTr("Clear search history");
								onClicked: {
									Script.clearTable('KeywordHistory');
									root.historysize = Script.getTableSize('KeywordHistory');
									setMsg(qsTr("Clean search keyword history successful"));
								}
							}
						}
					}
					SectionItem{
						text: qsTr("Tips");
						content: Column {
							width: parent.width;
							TextsItem{
								text: qsTr("General");
								texts: [
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("You can change card count and size by pinching with two finger, and enter edit mode by holding the card in play history page of Verena Touch Home."),
									},
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("In option history page of Verena Touch Home, you can remove a history by holding the item, and do this option again by clicking this item."),
									}
								]
							}
						}
					}
				}
			}

			Flickable{
				id:browsertab;
				anchors.fill:parent;
				contentWidth:width;
				contentHeight:mainlayout2.height;
				clip:true;
				Column{
					id:mainlayout2;
					width:parent.width;
					SectionItem{
						text: qsTr("Setting");
						content: Column{
							width: parent.width;
							SwitchItem{
								text: qsTr("Browser Auto Load Image");
								checked: settingsObject.browserAutoLoadImage;
								onCheckedChanged: {
									settingsObject.browserAutoLoadImage = checked;
								}
							}
							SwitchItem{
								text: qsTr("Browser Auto Parse Video");
								checked: settingsObject.browserAutoParseVideo;
								onCheckedChanged: {
									settingsObject.browserAutoParseVideo = checked;
								}
							}
							SwitchItem{
								text: qsTr("HTML5 Offline Local Storage");
								checked: settingsObject.browserHtml5OfflineLocalStorage;
								onCheckedChanged: {
									settingsObject.browserHtml5OfflineLocalStorage = checked;
								}
							}
							SwitchItem{
								text: qsTr("Browser Helper Tool");
								checked: settingsObject.browserHelper;
								onCheckedChanged: {
									settingsObject.browserHelper = checked;
								}
							}
							SelectionItem{
								text: qsTr("User Agent");
								subitems: qobj.makeUserAgent(vut.userAgent);
								currentValue: settingsObject.userAgent;
								onClicked:{
									settingsObject.userAgent = value;
								}
							}
						}
					}
					SectionItem{
						text: qsTr("Utility");
						content: Column{
							width: parent.width;
							ButtonItem{
								text: qsTr("Browser Cache Size") + ": " + root.browsercachesize;
								buttonText: qsTr("Clear Browser Cache");
								onClicked:{
									vut.clearBrowserCache();
									root.browsercachesize = Utility.FormatSize(vut.castBrowserLocalStorage());
									setMsg(qsTr("Clean browser cache successful"));
								}
							}
						}
					}
					SectionItem{
						text: qsTr("Tips");
						content: Column {
							width: parent.width;
							TextsItem{
								text: qsTr("Browser");
								texts: [
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("If you want to use desktop user-agent, you can check \"Debian IceWeasel.\""),
									}
								]
							}
						}
					}
				}
			}

			Flickable{
				id:othertab;
				anchors.fill:parent;
				contentWidth:width;
				contentHeight:mainlayout3.height;
				clip:true;
				Column{
					id:mainlayout3;
					width:parent.width;
					SectionItem{
						text:qsTr("Updates");
						content: Column {
							width: parent.width;
							TextsItem{
								horizontalAlignment: Text.AlignHCenter;
								text: qsTr("Version");
								texts: [
									{
										pixelSize: constants.pixel_xl,
										text: developer.appVersion + " (" + appState() + ")",
									},
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("Release") + ": " + developer.appRelease,
									},
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("Code") + ": " + developer.appCode,
									},
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("Platform") + ": " + developer.osInfo.PLATFORM + " (Qt " + developer.osInfo.V_QT_VERSION + ")",
									},
								]
							}
							TextsItem{
								text: qsTr("Changes");
								nu: "  * ";
								texts: [
									{
										pixelSize: constants.pixel_large,
										text: qsTr("Fixed youku video downloading and playing with internal player (2019/03/25)."),
									},
									{
										pixelSize: constants.pixel_large,
										text: qsTr("Fixed breakpoint downloading error."),
									},
								]
							}
						}
					}
					SectionItem{
						text:qsTr("Youku");
						content: Column {
							width: parent.width;
							TextsItem{
								text: qsTr("Warning");
								texts: [
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("Change request for getting Youku video url parameters."),
									}
								]
							}
							Column{
								id: youkucol;
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width;
								SwitchItem{
									id: ykswitcher;
									anchors.horizontalCenter: parent.horizontalCenter;
									text: qobj.ykedit ? qsTr("Edit") : qsTr("No edit");
									checked: qobj.ykedit;
									onCheckedChanged: {
										if(checked)
										{
											qobj.allowEditYoukuSetting();
										}
										else
										{
											qobj.ykedit = false;
											qobj.setYoukuSetting();
										}
									}
								}

								Repeater{
									id: ykrepeater;
									model: ListModel{
										id: ykmodel;
									}
									delegate: Component{
										EditItem{
											id: ykinput;
											//anchors.horizontalCenter: header_col.horizontalCenter;
											// width: youkucol.width;
											editable: qobj.ykedit;
											text: model.name;
											inputText: model.value;

											onReturnPressed: {
												settingsObject[model.setting] = inputText;
												setMsg(model.name + " " + qsTr("saved"));
											}
											placeholderText: model.desc;
											inputMethodHints: Qt.ImhNoAutoUppercase;
											Connections{
												target: ykrepeater;
												onModelChanged: {
													//console.log(model.value);
													ykinput.inputText = model.value;
												}
											}
										}
									}
									Component.onCompleted: {
										qobj.makeYoukuModel();
									}
								}
								SwitchItem{
									text: qsTr("Load video url of youku once");
									checked: settingsObject.youkuVideoUrlLoadOnce;
									//k enabled: qobj.ykedit;
									onCheckedChanged: {
										settingsObject.youkuVideoUrlLoadOnce = checked;
									}
								}
								VButton {
									anchors.horizontalCenter: parent.horizontalCenter;
									platformStyle: VButtonStyle {
										buttonWidth: 200;
									}
									enabled: qobj.ykedit;
									text: qsTr("Reset");
									onClicked: {
										vut.ResetYoukuSetting();
										qobj.setYoukuSetting();
										setMsg(qsTr("Settings has reseted"));
									}
								}
							}
						}
					}
					SectionItem{
						text: qsTr("About");
						content: Column{
							width: parent.width;
							Image{
								anchors.horizontalCenter:parent.horizontalCenter;
								smooth:true;
								source:Qt.resolvedUrl("../image/verena_logo.png");
							}
							TextsItem{
								text: "<b>" + qsTr("Thanks") + "</b>";
								texts: [
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("BaiduTieba") + ": <b><a href='http://tieba.baidu.com/home/main?id=422f44656172e5ad9c9f06'>Dear孜</a></b>",
									},
									{
										pixelSize: constants.pixel_xl,
										text: qsTr("BaiduTieba") + ": <b><a href='http://tieba.baidu.com/home/main?id=1c58e6a2a6e5bdb1e586b3e5b9bba61a'>梦影决幻</a> Anna icons</b>",
									}
								]
								onClicked: {
									Qt.openUrlExternally(link);
								}
							}

							TextsItem{
								text: "<b>" + developer.appFName + "</b>";
								texts: [
									{
										pixelSize: constants.pixel_xl,
										text: "<b>" + qsTr("Verena is a web-video player based on YouKu Open API v2.   You can search, watch and download the videos, shows and playlists of www.youku.com.") + "</b>",
									},
									{
										pixelSize: constants.pixel_xl,
										text: "<b>" + developer.appDeveloper + " @ 2015 &lt;" + developer.appMail + "&gt;" + "</b>",
									},
									{
										pixelSize: constants.pixel_large,
										text: "<b>" + qsTr("Download") + ": </b>" + "<b><a href='%1'>OpenRepos(WareHouse)</a>   <a href='%2'>BaiduPan</a></b>".arg(developer.appLink.OPENREPOS_DL).arg(developer.appLink.PANBAIDU_DL),
									},
									{
										pixelSize: constants.pixel_large,
										text: "<b>TMO: <a href='%1'>%2</a></b>".arg(developer.appLink.TMO).arg("Karin_Zhao"),
									},
									{
										pixelSize: constants.pixel_large,
										text: "<b>github: <a href='%1'>%2</a></b>".arg(developer.appLink.GITHUB).arg("glKarin/verena"),
									},
									{
										pixelSize: constants.pixel_large,
										text: "<b>" + qsTr("Contact") + ": </b>" + "<b><a href='mailto:%1'>%2</a></b>".arg(developer.appMail).arg(developer.appMail),
									},
								]
								onClicked: {
									Qt.openUrlExternally(link);
								}
							}
						}
					}
				}
			}
		}

		function appState(){
			if(developer.appState === "devel"){
				return qsTr("devel");
			}else if(developer.appState === "testing"){
				return qsTr("testing");
			}else{
				return qsTr("stable");
			}
		}

		tools:ToolBarLayout{
			ToolIcon{
				iconId: "toolbar-back";
				onClicked:{
					pageStack.pop();
				}
			}
		}
		Component.onCompleted:{
			root.historysize = Script.getTableSize('KeywordHistory');
			var cache = vut.castDiskCache();
			root.cachesize = "%1/%2".arg(Utility.FormatSize(cache["current"])).arg(Utility.FormatSize(cache["total"]));
			root.browsercachesize = Utility.FormatSize(vut.castBrowserLocalStorage());
			if(root.gowhere === "browser"){
				tabgroup.currentTab = browsertab;
			}else if(root.gowhere === "about"){
				tabgroup.currentTab = othertab;
			}
		}
	}
