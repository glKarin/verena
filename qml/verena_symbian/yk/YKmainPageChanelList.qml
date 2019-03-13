/*
 * This file included a define of "Channel" list component.
 */
import QtQuick 1.0
import "../../js/main.js" as Script
import "../../js/utility.js" as Utility

Rectangle {
    id: channelItem
    color: "#00ffff00"
    property alias model: channelsView.model
    property alias currentIndex: channelsView.currentIndex

		QtObject{
			id: qobj;

			function makeCategoryVideoModel(obj, model)
			{
				if(Array.isArray(obj.videos)){
					obj.videos.forEach(function(element){
						var item = {
							tid: element.id,
							title: element.title,
							img: element.thumbnail,
							duration: element.hasOwnProperty("duration") ? Utility.castMS2S(element.duration * 1000) : "00:00",
							stars: element.view_count ? (Math.ceil(element.view_count / 1000)) % 5 + 1 : 0,
							type: "video",
							cid: element.category,
							stripe_top: "",
						};
						model.append(item);
					});
				}
			}

			function request_main_videos(cid, model)
			{
				model.clear();
				var opt = {
					category: cid, // name
					period: "today",
					orderby: loaderWorker.orderby === "new" ? "published" : "view-count",
					page: 1,
					count: 20,
				};
				function s(obj){
					if(!onFail(obj))
					{
						makeCategoryVideoModel(obj, model);
					}
				}
				function f(err){
					setMsg(err);
				}
				Script.callAPI("GET", "videos_by_category", opt, s, f);
			}
		}

    function positionViewAtBeginning() {
        channelsView.positionViewAtBeginning();
    }

    function indexAt(x, y) {
        return channelsView.indexAt(x, y);
    }

    signal moreDetail(variant arg);
    signal itemClicked(variant arg);
    signal iClicked(variant arg);
    property alias header: channelsView.header

    Component {
        id: channelDelegate
        Column {
            id: channel
            width: channelItem.width
            spacing: 6
            Rectangle {
                width: parent.width
                height: 39
                color: "#00ffff00"
                Rectangle {
                    id: titlebarback
                    anchors.fill: parent
                    //source:"qrc:/mainPage/image/titlebar1.png"
										//k anchors.topMargin: 2;
										//k anchors.leftMargin: 4;
										opacity: 0.8;
										color: "#ffffff";
                }

                Rectangle {
                    id: titlebarshadow
                    anchors.fill: parent
                    //source:"qrc:/mainPage/image/titlebar_shadow.png"
										//k anchors.bottomMargin: 2;
										//k anchors.rightMargin: 4;
										opacity: 0.4;
										color: "#212421";
                }

                Text{
                    id: tx_channelname
                    anchors.left: parent.left; anchors.leftMargin: 9
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: title
                    font.pixelSize: 22
                    color: "white"
                }

                //more
                Image {
                    id: point
                    height: 30
                    anchors.right: parent.right;
                    anchors.rightMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    state: "released"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var arg = new Object();
                            arg.type = channelview.model.get(index).type;
                            arg.cid = channelsView.model.get(index).cid;
                            channelItem.moreDetail(arg);
                        }
                        onPressed:  point.state = "pressed"
                        onReleased: point.state = "released"
                        onCanceled: point.state = "released"
                    }

                    states:  [
                        State {
                            name: "released"
                            PropertyChanges {
                                target: point
                                source: Qt.resolvedUrl("../../image/yk/mainPage/image/icon_point.png");
                            }
                        },
                        State {
                            name: "pressed"
                            PropertyChanges {
                                target: point
                                source: Qt.resolvedUrl("../../image/yk/mainPage/image/icon_point_press.png");
                            }
                        }
                    ]
                } // end of point
            }
            Component {
                id: listdelegate

                Rectangle {
                    width: 146
                    height: channelview.height
                    color: "#00ffff00"
                    Rectangle {
                        id: backimg
                        width: 146
												height: 146
												border.width: 6;
												border.color: "#525552";
												color: "#d6d7d6";
												radius: 4;
                        anchors.horizontalCenter:  parent.horizontalCenter
                        anchors.top: parent.top
                        //source: "qrc:/listView/image/background_video.png"

                        Image {
                            id: contentImg
                            source: img
                            width: 140; // org 134
                            height: 140; // org 134
														anchors.centerIn: parent;
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var arg = new Object();
                                    arg.tid = channelview.model.get(index).tid;
                                    arg.cid = channelview.model.get(index).cid;
                                    arg.type = channelview.model.get(index).type;

																		arg.img = channelview.model.get(index).img;
																		arg.title = channelview.model.get(index).title;

                                    channelItem.itemClicked(arg);
                                }
                            }

                            states: [
                                State {
                                    name: "loaded"
                                    when: contentImg.status == Image.Ready
                                    PropertyChanges {
                                        target: contentNotReady
                                        opacity: 0
                                    }
                                }
                            ]
                        }

                        Image {
                            id: contentNotReady
                            width: 134
                            height: 134
                            anchors.left: parent.left
                            anchors.leftMargin:  6
                            anchors.top: parent.top
                            anchors.topMargin: 6
                            source: Qt.resolvedUrl("../../image/yk/mis/image/loding.png");
                        }

                        Image {
                            id: recommend
                            //source: "qrc:/mainPage/image/icon_Recommend.png"
                            anchors.top: parent.top
                            anchors.left: parent.left
                            Text {
                                x: parent.width  * 3 / 16
                                y: parent.height  *3 / 16
                                text: stripe_top
                                color: "white"
                                font.pixelSize: 15
                                font.bold: true
                                rotation: 315
                            }
                            opacity: stripe_top == "" ? 0 : 1;
                        }

                        Rectangle {
                            id: shadow
                            anchors.left: backimg.left
                            width: backimg.width
                            height: 70
                            anchors.bottom:  backimg.bottom
                            color:"black"
                            opacity: 0.6
                        }

                        Row {
                            id: reputation
                            anchors.top: shadow.top
                            anchors.topMargin: 3
                            anchors.left: shadow.left
                            anchors.leftMargin: 3
                            width: shadow.width
                            height: 35
                            spacing:  4
                            YKStarCom {
                                score: stars
                                numStar: 5
                            }
                        }

                        Text {//video title
                            anchors.left: contentImg.left
                            anchors.leftMargin: 3
                            anchors.top: shadow.top
                            anchors.topMargin: 20
                            id: tx_title
                            text: title
                            elide: Text.ElideRight
                            font.pixelSize: 22
                            width: contentImg.width
                            height: 22
                            color: "white"
                        }

                        Text {// duration
                            id: tx_time
                            text:duration
                            elide: Text.ElideRight
                            font.pixelSize: 17
                            color: "white"
                            width: contentImg.width
                            height: 17
                            anchors.top: tx_title.bottom
                            anchors.topMargin: 3
                            anchors.left:  tx_title.left
                            anchors.leftMargin: 3
                            opacity: 0.5
                        }
                    }

                    // detail icon
                    Image {
                        id: iimg
                        state: "released"
                        anchors.top: backimg.bottom
                        anchors.right: backimg.right; anchors.rightMargin: 9 + (76 - 33) / 2;
                        width: 33; //ori 76
                        height: 33; // ori 46
												anchors.topMargin: (46 - 33) / 2;

                        MouseArea{
                            anchors.fill: parent
                            onPressed: iimg.state = "pressed"
                            onReleased: iimg.state = "released"
                            onCanceled: iimg.state = "released"
                            onClicked:  {
                                var arg = new Object();
                                arg.type = channelview.model.get(index).type;
                                arg.tid = channelview.model.get(index).tid;
                                arg.cid = channelview.model.get(index).cid;

																arg.img = channelview.model.get(index).img;
																arg.title = channelview.model.get(index).title;

                                channelItem.iClicked(arg);
                            }
                        }

                        states: [
                            State {
                                name: "pressed"
                                PropertyChanges {
                                    target: iimg
																		source: Qt.resolvedUrl("../../image/yk/mainPage/image/i_press.png");
                                }
                            },
                            State {
                                name: "released"
                                PropertyChanges {
                                    target: iimg
																		source: Qt.resolvedUrl("../../image/yk/mainPage/image/i.png");
                                }
                            }
                        ]
                    }
                }
            }
            YKScrollList {
                id: channelview
                spacing: 9
                delegate: listdelegate
                width: parent.width
                height: 192
								clip: true;
                model : ListModel{}
                Component.onCompleted: {
                    qobj.request_main_videos(channelsView.model.get(index).title, channelview.model);
                }
            }
        }
    }

    ListView {
        id: channelsView
        cacheBuffer: channelsView.model ? channelsView.model.count * 192 : 0;
        anchors.fill: parent
        delegate: channelDelegate
				clip: true;
        footer: Component {
            Rectangle{
                width: parent.width
                height: 109
                color: "#00ffff00"
                Image {
                    id: channelsfooter
                    anchors.top: parent.top
                    anchors.topMargin: 18
										anchors.horizontalCenter: parent.horizontalCenter;
                    //source: "qrc:/mainPage/image/shadow1.png"
										source: Qt.resolvedUrl("../../image/yk_shadow1.png");
                }
            }
        }
    }
}




