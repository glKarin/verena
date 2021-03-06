import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	title:"<b>" + qsTr("Setting") + "</b>";
	extraToolEnabled:false;
	property string cachesize;
	property int historysize:0;
	property string gowhere:"";
	property string browsercachesize;

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
				width:parent.width;
				ListItemHeader{
					text:qsTr("Setting");
					item:settingitem;
				}
				VerenaRectangle{
                    id:settingitem;
                    theight:childrenRect.height;
					Column{
                        //id:generalitem;
						width:parent.width;
						visible:parent.fullShow;
						LineText{
							anchors.horizontalCenter:parent.horizontalCenter;
                            style:"left";
							text:qsTr("Default Video Player");
						}
						ButtonColumn{
							width:parent.width;
							spacing:3;
							CheckBox{
								width:parent.width;
								checked:settingsObject.defaultPlayer === 0;
								text:qsTr("Verena Player");
								onClicked:{
									settingsObject.defaultPlayer = 0;
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.defaultPlayer === 1;
								text:qsTr("External Player");
								onClicked:{
									settingsObject.defaultPlayer = 1;
								}
							}
						}
						LineText{
							anchors.horizontalCenter:parent.horizontalCenter;
                            style:"left";
							text:qsTr("Default External Player");
						}
						ButtonColumn{
							width:parent.width;
							spacing:3;
							CheckBox{
								width:parent.width;
								checked:settingsObject.externalPlayer === 0;
								text:qsTr("Harmattan Video-Suite");
								onClicked:{
									settingsObject.externalPlayer = 0;
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.externalPlayer === 1;
								text:qsTr("Harmattan Grob Browser");
								onClicked:{
									settingsObject.externalPlayer = 1;
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.externalPlayer === 2;
								text:qsTr("External KMPlayer");
								onClicked:{
									settingsObject.externalPlayer = 2;
								}
							}
						}
						Row{
							width:parent.width;
							height:50;
							LineText{
                                anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								width:parent.width - switcher.width;
								text:qsTr("VerenaTouchHome Lock Portrait");
							}
							Switch{
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.vthomeLockOrientation;
								onCheckedChanged:{
									settingsObject.vthomeLockOrientation = checked;
								}
							}
						}
						Row{
							width:parent.width;
							height:50;
							LineText{
                                width:parent.width - switcher.width;
								anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								text:qsTr("Fullscreen");
							}
							Switch{
								id:switcher;
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.fullScreen;
								onCheckedChanged:{
									settingsObject.fullScreen = checked;
								}
							}
						}
						Row{
							width:parent.width;
							height:50;
							LineText{
								anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								width:parent.width - switcher.width;
								text:qsTr("Player Corner");
							}
							Switch{
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.playerCorner;
								onCheckedChanged:{
									settingsObject.playerCorner = checked;
								}
							}
						}
					}
				}
				ListItemHeader{
					text:qsTr("Utility");
					item:utilityitem;
				}
				VerenaRectangle{
                    id:utilityitem;
                    theight:childrenRect.height;
					Column{
                        //id:generalitem2;
						visible:parent.fullShow;
						width:parent.width;
						LineText{
							anchors.horizontalCenter:parent.horizontalCenter;
                            text:qsTr("Cache Size") + ": " + root.cachesize;
						}
						Button{
							anchors.horizontalCenter:parent.horizontalCenter;
							text:qsTr("Clear cache");
							onClicked:{
								vut.clearDiskCache();
								root.cachesize = vut.castDiskCache();
								setMsg(qsTr("Clean disk cache successful"));
							}
						}
						LineText{
							anchors.horizontalCenter:parent.horizontalCenter;
                            text:qsTr("Search History Size") + ": " + root.historysize;
						}
						Button{
							anchors.horizontalCenter:parent.horizontalCenter;
							text:qsTr("Clear search history");
							onClicked:{
								Script.clearTable('KeywordHistory');
								root.historysize = Script.getTableSize('KeywordHistory');
								setMsg(qsTr("Clean search keyword history successful"));
							}
						}
					}
				}
				ListItemHeader{
					text:qsTr("Tips");
					item:generaltipsrect;
				}
				VerenaRectangle{
                    id:generaltipsrect;
                    theight:childrenRect.height;
					Column {
                        //id:generaltips;
						width:parent.width;
						visible:parent.fullShow;
						// 2017
						Text{
                            font.pixelSize: 24;
							width:parent.width;
							color:"black";
                            text: qsTr("You can change card count and size by pinching with two finger, and enter edit mode by holding the card in play history page of Verena Touch Home.");
							wrapMode:Text.WordWrap;
						}
						Text{
                            font.pixelSize: 24;
							width:parent.width;
							color:"black";
                            text: qsTr("In option history page of Verena Touch Home, you can remove a history by holding the item, and do this option again by clicking this item.");
							wrapMode:Text.WordWrap;
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
				ListItemHeader{
					text:qsTr("Setting");
					item:settingitem2;
				}
				VerenaRectangle{
                    id:settingitem2;
                    theight:childrenRect.height;
					Column{
                        //id:browseritem;
						width:parent.width;
						visible:parent.fullShow;
						Row{
							width:parent.width;
							height:50;
							LineText{
								anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								width:parent.width - switcher.width;
								text:qsTr("Browser Auto Load Image");
							}
							Switch{
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.browserAutoLoadImage;
								onCheckedChanged:{
									settingsObject.browserAutoLoadImage = checked;
								}
							}
						}
						Row{
							width:parent.width;
							height:50;
							LineText{
                                anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								width:parent.width - switcher.width;
								text:qsTr("Browser Auto Parse Video");
							}
							Switch{
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.browserAutoParseVideo;
								onCheckedChanged:{
									settingsObject.browserAutoParseVideo = checked;
								}
							}
						}
						Row{
							width:parent.width;
							height:50;
							LineText{
                                anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								width:parent.width - switcher.width;
								text:qsTr("HTML5 Offline Local Storage");
							}
							Switch{
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.browserHtml5OfflineLocalStorage;
								onCheckedChanged:{
									settingsObject.browserHtml5OfflineLocalStorage = checked;
								}
							}
						}
						Row{
							width:parent.width;
							height:50;
							LineText{
								width:parent.width - switcher.width;
                                anchors.verticalCenter:parent.verticalCenter;
                                style:"left";
								text:qsTr("Browser Helper Tool");
							}
							Switch{
								anchors.verticalCenter:parent.verticalCenter;
								checked:settingsObject.browserHelper;
								onCheckedChanged:{
									settingsObject.browserHelper = checked;
								}
							}
						}
						LineText{
                            anchors.horizontalCenter:parent.horizontalCenter;
							text:qsTr("User Agent");
						}
						ButtonColumn{
							width:parent.width;
							spacing:3;
							CheckBox{
								width:parent.width;
								checked:settingsObject.userAgent === "iceweasel";
								text:qsTr("Debian IceWeasel 24.5.0(based on FireFox 24.0)");
								onClicked:{
									settingsObject.userAgent = "iceweasel";
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.userAgent === "harmattan";
								text:qsTr("MeeGo(Nokia N9/50 Harmattan edition Grob browser)");
								onClicked:{
									settingsObject.userAgent = "harmattan";
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.userAgent === "maemo";
								text:qsTr("MicroB(Nokia N900 browser, based on FireFox 3)");
								onClicked:{
									settingsObject.userAgent = "maemo";
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.userAgent === "android";
								text:qsTr("Android(Google Nexus 7 version 4.1.1)");
								onClicked:{
									settingsObject.userAgent = "android";
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.userAgent === "s40";
								text:qsTr("Nokia S40(Nokia 2700c S40 v6 Fp1)");
								onClicked:{
									settingsObject.userAgent = "s40";
								}
							}
							CheckBox{
								width:parent.width;
								checked:settingsObject.userAgent === "wp7.5";
								text:qsTr("Windows Phone 7.5 Mango(Nokia Lumia 710)");
								onClicked:{
									settingsObject.userAgent = "wp7.5";
								}
							}
							CheckBox{
								width:parent.width;
								text:qsTr("IPhone(IOS 7)");
								checked:settingsObject.userAgent === "iphone";
								onClicked:{
									settingsObject.userAgent = "iphone";
								}
							}
						}
					}
				}
				ListItemHeader{
					text:qsTr("Utility");
					item:utilityitem2;
				}
				VerenaRectangle{
                    id:utilityitem2;
                    theight:childrenRect.height;
					Column{
                        //id:browseritem2;
						visible:parent.fullShow;
						width:parent.width;
						LineText{
                            anchors.horizontalCenter:parent.horizontalCenter;
							text:qsTr("Browser Cache Size") + ": " + root.browsercachesize;
						}
						Button{
							anchors.horizontalCenter:parent.horizontalCenter;
							text:qsTr("Clear Browser Cache");
							onClicked:{
								vut.clearBrowserCache();
								root.browsercachesize = vut.castBrowserLocalStorage();
								setMsg(qsTr("Clean browser cache successful"));
							}
						}
					}
				}
				ListItemHeader{
					text:qsTr("Tips");
					item:browsertipsrect;
				}
				VerenaRectangle{
                    id:browsertipsrect;
                    theight:childrenRect.height;
					Column {
                        //id:browsertips;
						width:parent.width;
						visible:parent.fullShow;
						Text{
                            font.pixelSize: 24;
							width:parent.width;
							color:"black";
                            text: qsTr("If you want to use desktop user-agent, you can check \"Debian IceWeasel.\"");
							wrapMode:Text.WordWrap;
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
				ListItemHeader{
					text:qsTr("Updates");
					item:tipsitem;
				}
				VerenaRectangle{
                    id:tipsitem;
                    theight:childrenRect.height;
					Column {
                        //id:tips;
						width:parent.width;
						visible:parent.fullShow;
                        LineText{
                            anchors.horizontalCenter:parent.horizontalCenter;
                            text:qsTr("Version");
                        }
						Text{
                            font.pixelSize: 24;
							width:parent.width;
							color:"black";
                            text: developer.appName + " - " + developer.appVersion + " (" + appState() + ")";
							wrapMode:Text.WordWrap;
						}
                        LineText{
                            anchors.horizontalCenter:parent.horizontalCenter;
                            text:qsTr("Changes");
                        }
						Text{
                            font.pixelSize: 22;
							width:parent.width;
							color:"black";
                            text: qsTr("1, Fixed Youku video parser script(2017/06/04).");
							wrapMode:Text.WordWrap;
                        }
					}
				}
				ListItemHeader{
					text:qsTr("About");
					item:aboutitem;
				}
				VerenaRectangle{
                    id:aboutitem;
                    theight:childrenRect.height;
					Column {
                        //id:about;
						width:parent.width;
						visible:parent.fullShow;
						Image{
							anchors.horizontalCenter:parent.horizontalCenter;
							smooth:true;
							source:Qt.resolvedUrl("../image/verena_logo.png");
						}
						Text{
                            font.pixelSize: 22;
							width:parent.width;
							text: "<b>" + qsTr("Verena is a web-video player based on YouKu Open API v2.   You can search, watch and download the videos, shows and playlists of www.youku.com.") + "</b>";
							wrapMode:Text.WordWrap;
						}
						Text{
                            font.pixelSize: 24;
							width:parent.width;
                            text: "<b>" + developer.appDeveloper + " @ 2017 &lt;" + developer.appMail + "&gt;" + "</b>";
							wrapMode:Text.WordWrap;
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
		root.cachesize = vut.castDiskCache();
		root.browsercachesize = vut.castBrowserLocalStorage();
		if(root.gowhere === "browser"){
			tabgroup.currentTab = browsertab;
		}else if(root.gowhere === "about"){
			tabgroup.currentTab = othertab;
		}
	}
}
