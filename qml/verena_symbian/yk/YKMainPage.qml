/*
 * This file included a define of Main page view.
 */
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import ".."
import "../../js/main.js" as Script
import "../../js/parserengine.js" as Parser

Page{

    id: mainView
		orientationLock: PageOrientation.LockPortrait;
    state: "navigationshow"

		QtObject{
			id: loaderWorker;
			property string orderby: "hot";

			function sendMessage(obj){
				toggleBusy(true);
				channels.model = undefined;
				var main_page_info = {"banner":[], "channel":[], "videos":[]};

				var getShowAsBanner = function (model)
				{
					model.clear();
					var arr = ["电影", "电视剧", "动漫", "综艺", "纪录片", "体育", "教育", "音乐"];
					function s(obj){
						if(!onFail(obj))
						{
							for (var i in obj.shows) // banner
							{
								var vid = Script.getYoukuVideoIDFromLink(obj.shows[i].last_play_link || "");
								var type = (vid !== "") ? "show_video" : "show";
								main_page_info.banner.push({
									"vid" : vid,
									"tid" : obj.shows[i].id,
									"title" : obj.shows[i].name,
									"type" : type,
									"img" : obj.shows[i].bigthumbnail
								});
							}
							var l = main_page_info.banner.length - 1;
								model.append({
									"vid" : main_page_info.banner[l].vid,
									"tid" : main_page_info.banner[l].tid,
									"title" : main_page_info.banner[l].title,
									"type" : main_page_info.banner[l].type,
									"img" : main_page_info.banner[l].img
								});
						}
						toggleBusy(false);
					}
					function f(err){
						toggleBusy(false);
						setMsg(err);
					}
					for(var i = 0; i < arr.length; i++){
						var opt = {
							category: arr[i],
							orderby: orderby === "new" ? "updated" : "view-today-count",
							page: 1,
							count: 1
						};
						Script.callAPI("GET", "shows_by_category", opt, s, f);
					}
				}

				var getVideoAsHome = function(model){
					model.clear();
					var arr = [1001, 97, 100, 96, 85, 95, 1002];
					for(var i = 0; i < arr.length; i++){
						var index = -1;
						for(var k in schemas.videoCategoryMap)
						{
							if(schemas.videoCategoryMap[k].id == arr[i])
							{
								index = k;
								break;
							}
						}
						if(index === -1)
							continue;
						main_page_info.channel.push({
							"cid" : index,
							"title" : schemas.videoCategoryMap[index].name,
							"type" : "video"
						});
					}

					for (var h in main_page_info.channel) {
						obj.channelsModel.append({
							"cid" : main_page_info.channel[h].cid,
							"title" : main_page_info.channel[h].title,
							"type" : main_page_info.channel[h].type
						});
					}
					channels.model = channelsmodel;
				}

				getShowAsBanner(obj.bannerModel);
				getVideoAsHome(obj.channelsModel);
			}

		}

		StreamtypesDialog{
			id: dialog;
			model: ListModel{id:typemodel;}
			onRequestParse: {
				if(settingsObject.youkuVideoUrlLoadOnce)
				{
					if(url.length)
					{
						vplayer.load(url);
					}
					else
					{
						setMsg(qsTr("Video is a preview."));
					}
				}
				else
				{
					Parser.loadSource(vid, "youku", vplayer, [type], [part], {settings: settingsObject});
				}
			}
		}

    // Initial data while page loading
    Component.onCompleted:  {
        var obj = {'format': "mp4", 'bannerModel': banner.model, 'channelsModel': channelsmodel};
        loaderWorker.sendMessage(obj);
    }

    // background
    Rectangle {
        anchors.fill: parent
				//source: "qrc:/mainPage/image/background_Drama.png"
				color: "#423c42";
				opacity: 0.8;
    }

		ListModel{
			id: channelsmodel;
		}

    // channels list
    YKmainPageChanelList {
        id:channels
        width: parent.width
        height: parent.height - banner.height
        anchors.top:  bannerRect.bottom
        onMoreDetail:  {
						mainpage.addNotification({option: "category_video", value: "%1,%2,%3".arg(arg.cid).arg(0).arg(0)});
						var page = Qt.createComponent(Qt.resolvedUrl("../CategoryPage.qml"));
						pageStack.push(page, {idx: [arg.cid, 0, 0]});

        }
        onIClicked: {
						mainpage.addNotification({option: "show_detail", title: arg.title, thumbnail: arg.img, value: arg.tid});
						var page = Qt.createComponent(Qt.resolvedUrl("../DetailPage.qml"));
						pageStack.push(page, {videoid: arg.tid});
        }

        onItemClicked:  {
						mainpage.addSwipeSwitcher(arg.title, arg.img, arg.tid, "youku");
						if(settingsObject.defaultPlayer === 0) {
							var page = Qt.createComponent(Qt.resolvedUrl("../PlayerPage.qml"));
							pageStack.push(page, {videoid: arg.tid}, true);
						}else if(settingsObject.defaultPlayer === 1){
							if(arg.tid === 0){
								return;
							}
							dialog.vid = arg.tid;
							function s(obj){
								typemodel.clear();
								dialog.yk.getStreamtypesModel(obj, typemodel);
								dialog.open();
							}
							function f(err){
								setMsg(err);
							}
							Script.getVideoStreamtypes(arg.tid, s, f);
						}
					}
    }

    // banner
    Rectangle{
        id:bannerRect
        width: mainView.width
        height: 225
        color: "#3D3D3D"
        YKScrollList{//banner list
            id: banner
            width: mainView.width
            height: parent.height
            anchors.top: parent.top
            model:ListModel {}
            highlightRangeMode: ListView.StrictlyEnforceRange
            currentIndex: 0
            delegate:
                Component{
                Rectangle{
                    width: banner.width
                    height: banner.height
                    Image { //banner image
                        id:bannerContent
                        width: banner.width
                        height: banner.height
                        source: img
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        smooth: true
                    }

                    Image {//banner logo
                        anchors.left: bannerContent.left;
                        anchors.leftMargin: 6
                        anchors.top: bannerContent.top;
                        anchors.topMargin: 3
												source: Qt.resolvedUrl("../../image/yk/mainPage/image/logo.png");
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
														mainpage.addNotification({option: "show_detail", title: model.title, thumbnail: model.img, value: model.tid});
														if(model.type === "show")
														{
															var page = Qt.createComponent(Qt.resolvedUrl("../ShowDetailPage.qml"));
															pageStack.push(page, {showid: model.tid});
														}
														else
														{
															var page = Qt.createComponent(Qt.resolvedUrl("../DetailPage.qml"));
															pageStack.push(page, {videoid: model.vid});
														}
                        }
                    }
                }
            }
        }

        //banner bottom
        Rectangle {
            id: index
            width: parent.width;
            height: 60
            anchors.bottom: banner.bottom
            color: "black"
            opacity: 0.6

            //banner title
            Text {
                id: name
                anchors.centerIn: parent
                text: (banner.model.get(banner.currentIndex) != undefined ?
                           banner.model.get(banner.currentIndex).title: "" )
                color: "white"
                font.pixelSize: 16 - constants.__pixel_DIFF
            }

            // banner index
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: name.bottom
                anchors.topMargin:  6
                spacing: 6

                Repeater {
                    model: (banner.model.count != undefined ?
                                banner.model.count : 5)
                    Rectangle {
                        id: point
												width: 10; height: 10 // ori is 15
												radius: width / 2;
												smooth: true;
                        state: banner.currentIndex == index ? "highlight" : "normal"

                        states: [
                            State {
                                name: "normal"
                                PropertyChanges {
                                    target: point
                                    color: "#ffffff";
                                    //color: "#eeeeee";
                                }
                            },
                            State {
                                name: "highlight"
                                PropertyChanges {
                                    target: point
                                    color: "#adb2ad";
                                }
                            }
                        ]
                    }
                }
            }
        }
    }// banner end

    //menu
    YKMenu{
        id: menu
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
				z: 999;
        centerSrc: Qt.resolvedUrl("../../image/yk/tapbar/image/icon_home1.png")
        centerPressedSrc: Qt.resolvedUrl("../../image/yk/tapbar/image/icon_home1.png")


        onCenterClicked: {
					/*
            if (channels.indexAt(0,0) < 0) {
                channels.positionViewAtBeginning();
            } else {
                 var obj = {'format': "mp4", 'bannerModel': banner.model, 'channelsModel': channelsmodel};
                loaderWorker.sendMessage(obj);
							}
							*/
						menu.showSubbar(false);
						mainView.state = "navigationshow";
        }

        menuModel: ListModel{
            ListElement{name:"menu"; pressed:"../../image/yk/tapbar/image/icon_menu.png";
                normal: "../../image/yk/tapbar/image/icon_menu.png"}
            ListElement{name:"refresh";pressed:"../../image/yk/tapbar/image/icon_refresh.png";
                normal: "../../image/yk/tapbar/image/icon_refresh.png"}
            ListElement{name:"back";pressed:"../../image/yk/tapbar/image/icon_back.png";
                normal: "../../image/yk/tapbar/image/icon_back.png"}
        }

        subModel:  ListModel {
            ListElement{name:"视频";  pressed:"../../image/yk/tapbar/image/icon_videos.png";
						normal: "../../image/yk/tapbar/image/icon_videos.png"; selected:"../../image/yk/tapbar/image/icon_videos.png";
						qml: "CategoryPage"; data: "{idx: [0, 0, 0]}"; }
            ListElement{name:"节目";  pressed:"../../image/yk/tapbar/image/icon_shows.png";
                normal: "../../image/yk/tapbar/image/icon_shows.png"; selected:"../../image/yk/tapbar/image/icon_shows.png";
								qml: "ShowCategoryPage"; data: "{idx: [0, 0, 0]}"; }
            ListElement{name:"浏览"; pressed:"../../image/yk/tapbar/image/icon_browser.png";
                normal: "../../image/yk/tapbar/image/icon_browser.png"; selected:"../../image/yk/tapbar/image/icon_browser.png";
							qml: "VerenaBrowser"; }
            ListElement{name:"搜索"; pressed:"../../image/yk/tapbar/image/icon_search.png";
                normal: "../../image/yk/tapbar/image/icon_search.png"; selected:"../../image/yk/tapbar/image/icon_search.png";
							qml: "SearchPage"; }
            ListElement{name:"收藏"; pressed:"../../image/yk/tapbar/image/icon_collections.png";
                normal: "../../image/yk/tapbar/image/icon_collections.png"; selected:"../../image/yk/tapbar/image/icon_collections.png";
							qml: "LocalCollectionPage"; }
            ListElement{name:"下载"; pressed:"../../image/yk/tapbar/image/icon_download.png";
                normal: "../../image/yk/tapbar/image/icon_download.png"; selected:"../../image/yk/tapbar/image/icon_download.png";
							qml: "DownloadPage"; }
            ListElement{name:"设置"; pressed:"../../image/yk/tapbar/image/icon_settings.png";
                normal: "../../image/yk/tapbar/image/icon_settings.png"; selected:"../../image/yk/tapbar/image/icon_settings.png";
							qml: "SettingPage"; }
        }

        onSubbarItemClicked: {
            var qml = menu.subModel.get(index).qml;
						var data = menu.subModel.get(index).data;
						var page = Qt.createComponent(Qt.resolvedUrl("../" + qml + ".qml"));
						if(data)
						{
							eval("var init_data = " + data);
							pageStack.push(page, init_data);
						}
						else
							pageStack.push(page);
        }

        onItemClicked: {
            if (menu.menuModel.get(index).name == "menu") {
                menu.showSubbar(!menu.isSubbarShowed());
            } else if (menu.menuModel.get(index).name == "refresh") {
							var obj = {'format': "mp4", 'bannerModel': banner.model, 'channelsModel': channelsmodel};
							loaderWorker.sendMessage(obj);
            } else if (menu.menuModel.get(index).name == "back"){
                pageStack.pop();
            }
        }
        onClickMenuOutside: mainView.state = "navigationshow"
    }

    // menu navigation
    Item {
        id: navigation
        opacity: 0
				width: parent.width;
				height: 32; //24;
				clip: true;
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        //source: "qrc:/tapbar/image/navigationbar_nor.png"

				Rectangle{
					width: 60;
					height: width;
					z: 1;
					anchors.verticalCenter: navline.bottom;
					anchors.horizontalCenter: parent.horizontalCenter;
					smooth: true;
					color: "#212421";
					radius: width / 2;
					Rectangle{
						width: 16;
						height: width;
						anchors.centerIn: parent;
						smooth: true;
						color: "#8c8a8c";
						radius: width / 2;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							menu.showSubbar(false);
							mainView.state = "menushowed";
						}
					}
				}

				Rectangle{
					id: navline;
					anchors.horizontalCenter: parent.horizontalCenter;
					anchors.bottom: parent.bottom;
					width: parent.width;
					height: 2;
					color: "lightskyblue";
				}
    }

    states: [
        State {
            name: "menushowed"

            PropertyChanges {
                target: navigation
                opacity: 0
            }
            PropertyChanges {
                target: menu
                opacity: 1
            }
        },
        State {
            name: "navigationshow"
            PropertyChanges {
                target: menu
                opacity: 0
            }

            PropertyChanges {
                target: navigation
                opacity: 1
            }
        }
    ]

    transitions:[
        Transition {
            NumberAnimation {
                target: menu
                property: "opacity"
                easing.type: Easing.OutCubic
                duration: 600
            }
        },
        Transition {
            NumberAnimation {
                target: navigation
                property: "opacity"
                easing.type: Easing.OutCubic
                duration: 600
            }
        }
    ]

        YKBusy {
            id: busy
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 140
						z: 99;
            //on: true
        }

				function toggleBusy(on)
				{
					busy.on = on;
				}

}
