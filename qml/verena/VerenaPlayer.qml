import QtQuick 1.1
import com.nokia.meego 1.1
import QtMultimediaKit 1.1
import QtMobility.systeminfo 1.1
import "../js/utility.js" as Utility

Rectangle{
	id:root;

	color:"black";
	property url source;
	property alias tableEnabled:table.enabled;
	property alias title:titletext.text;
	property bool canPrev:false;
	property bool canNext:false;
	property int topBarHeight: constants.player_top_bar_height;
	property int bottomBarHeight: constants.player_bottom_bar_height;
	property int orientation: 1;
	property int playedMS: 0;
	property int totalMS: 0;
	property alias duration: video.duration;
	property alias position: video.position;

	property int _totalMS: totalMS === 0 ? video.duration : totalMS;
	property int _playedMS: playedMS + video.position;

	signal seek(real value);
	signal exit;
	signal stopped;
	signal endOfMedia;
	signal requestShowType;
	signal requestPlayPart(string where);

	function stop() {
		video.stop();
		video.position = 0;
		root.exit();
	}

	function stopOnly() {
		video.stop();
		video.source = "";
		video.position = 0;
	}

	function load(pos) {
		video.source = root.source;
		if(video.source != "")
		{
			video.fillMode = Video.PreserveAspectFit;
			fillmodellist.currentValue = Video.PreserveAspectFit;
			video.play();

			if(pos && video.seekable)
				video.position = pos;
		}
	}

	function setPosition(pos)
	{
		if(!video.seekable)
			return;

		var p = pos === undefined ? 0 : pos;
		if(video.source != "")
		{
			video.position = p;
		}
	}

	function setPercent(per)
	{
		if(video.source != "")
		{
			var p = video.duration * per;
			video.position = p;
		}
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn:parent;
		z:3;
		platformStyle:BusyIndicatorStyle{
			size:"large";
			inverted:true;
		}
		visible:video.playing && video.bufferProgress !== 1.0;
		running:visible;
	}
	Connections{
		target:screen;
		onMinimizedChanged:{
			if(screen.minimized){
				video.paused = true;
			}
		}
	}

	Video {
		id: video;
		anchors.fill:parent;
		onError:{
			if(error !== Video.NoError){
				setMsg(error + " : " + errorString + (error === Video.NetworkError ? ", " + qsTr("suggest to play with system media player") : ""));
				root.stopOnly();
			}
		}
		/*
		 onStopped:{
			 video.position = 0;
			 root.exit();
		 }
		 */
		onStatusChanged:{
			if(status === Video.EndOfMedia){
				root.endOfMedia();
				video.position = 0;
			}
		}
        volume: (devinfo.voiceRingtoneVolume > 50 ? 50 : devinfo.voiceRingtoneVolume < 20 ? 20 : devinfo.voiceRingtoneVolume) / 100;
        focus: true
		Keys.onSpacePressed: video.paused = !video.paused
		Keys.onLeftPressed: video.position -= 5000
		Keys.onRightPressed: video.position += 5000

		function setFillMode(value)
		{
			switch(value)
			{
				case 0:
				video.fillMode = Video.Stretch;
				break;
				case 2:
				video.fillMode = Video.PreserveAspectCrop;
				break;
				case 1:
				default:
				video.fillMode = Video.PreserveAspectFit;
				break;
			}

		}
	}

	ScreenSaver{
		id:screensaver;
		screenSaverDelayed:video.playing && !video.paused;
	}
    DeviceInfo {
        id: devinfo;
    }

	Rectangle{
		id:headbar;
		property int theight: root.topBarHeight;
		anchors.top:parent.top;
		width:parent.width;
		color:"black";
		z:1;
		opacity:0.8
		states:[
			State{
				name:constants.state_show;
				PropertyChanges {
					target: headbar;
					height:theight;
				}
			}
			,
			State{
				name:constants.state_hide;
				PropertyChanges {
					target: headbar;
					height:0;
				}
			}
		]
        state:toolbar.state;
        transitions: [
            Transition {
                from:constants.state_hide;
                to:constants.state_show;
                NumberAnimation{
                    target:headbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.OutExpo;
                }
            }
            ,
            Transition {
                from:constants.state_show;
                to:constants.state_hide;
                NumberAnimation{
                    target:headbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.InExpo;
                }
            }
        ]

		AutoMoveText{
			id:titletext;
			anchors.left:parent.left;
			anchors.right:table.left;
			anchors.verticalCenter:parent.verticalCenter;
			color:"white";
			pixelSize:22;
			isOver: visible;
			visible:parent.height === parent.theight;
		}

		ToolIcon{
			id:table;
			iconId: "toolbar-list";
			anchors.right:fillmode.left;
			anchors.verticalCenter:parent.verticalCenter;
			visible:parent.height === parent.theight && enabled;
			onClicked:{
                timer.restart();
				root.requestShowType();
			}
		}
		ToolIcon{
			id:fillmode;
			iconId: "toolbar-settings";
			anchors.right:close.left;
			anchors.verticalCenter:parent.verticalCenter;
			visible:parent.height === parent.theight;
            onClicked:{
                timer.restart();
				if(settingbar.state === constants.state_hide){
					settingbar.state = constants.state_show;
				}else if(settingbar.state === constants.state_show){
					settingbar.state = constants.state_hide;
				}
			}
		}

		ToolIcon{
			id:close;
			iconId: "toolbar-close";
			anchors.right:parent.right;
			anchors.verticalCenter:parent.verticalCenter;
			visible:parent.height === parent.theight;
			onClicked:{
				root.stop();
			}
		}
	}

	Rectangle{
		id:settingbar;
		property int twidth: constants.player_left_bar_width;
		anchors{
			//k verticalCenter: parent.verticalCenter;
			top: parent.top;
			left: parent.left;
			topMargin: root.topBarHeight;
			bottom: parent.bottom;
			bottomMargin: root.bottomBarHeight;
		}
		color:"black";
		z:1;
        opacity:0.8;
        state:constants.state_hide;
		states:[
			State{
				name:constants.state_show;
				PropertyChanges {
					target: settingbar;
					width:twidth;
				}
			}
			,
			State{
				name:constants.state_hide;
				PropertyChanges {
					target: settingbar;
					width:0;
				}
			}
        ]
        transitions: [
            Transition {
                from:constants.state_hide;
                to:constants.state_show;
                NumberAnimation{
                    target:settingbar;
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
                    target:settingbar;
                    property:"width";
                    duration:400;
                    easing.type:Easing.InExpo;
                }
            }
        ]

				Rectangle{
					id: settingrect;
					anchors.fill: parent;
					color: "#eeeeee";
					radius: 4;
					smooth: true;
					opacity: 0.8;
					visible: parent.width === parent.twidth;
					Flickable{
						id: settingsflick;
						anchors.fill: parent;
						contentWidth: width;
						clip: true;
						contentHeight: mainlayout.height;
						onContentYChanged: {
							if(moving /* flicking*/)
								timer.restart();
						}
						Column{
							id: mainlayout;
							width: parent.width;
							spacing: 4;
							SelectionItem{
								id:fillmodellist;
								text: qsTr("Fill Mode");
								subitems: [
									{
										text: qsTr("Fit"),
										value: Video.PreserveAspectFit
									},
									{
										text: qsTr("Crop"),
										value: Video.PreserveAspectCrop
									},
									{
										text: qsTr("Stretch"),
										value: Video.Stretch
									},
								]
								currentValue: Video.PreserveAspectFit;
								onClicked:{
									timer.restart();
									video.setFillMode(value);
								}
							}
							ProgressItem{
								id: fullprogressbar;
								text: qsTr("Full Progress");
								enabled: video.duration !== 0;
								currentText: settingrect.visible ? Utility.castMS2S(root._playedMS) : "00:00";
								totalText: settingrect.visible ? Utility.castMS2S(root._totalMS) : "59:59";
								value: root._totalMS == 0 ? 0 : (root._playedMS) / root._totalMS;
								onClicked: {
									timer.restart();
									root.seek(value);
								}
							}
							SwitchItem{
								text: qsTr("Mute");
								checked: video.muted;
								onCheckedChanged: {
									timer.restart();
									video.muted = checked;
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
								currentValue: root.orientation;
								onClicked: {
									timer.restart();
									root.orientation = value;
								}
							}
							Button{
								anchors.horizontalCenter: parent.horizontalCenter;
								text: qsTr("External player");
								enabled: root.source != "";
								platformStyle: ButtonStyle {
									buttonWidth: 200; 
								}
								onClicked: {
									timer.restart();
									if(root.source != "")
									{
										setMsg(qsTr("Open video with external player"));
										vplayer.load(root.source);
									}
									else
									{
										setMsg(qsTr("Video source is empty"));
									}
								}
							}
							Button{
								anchors.horizontalCenter: parent.horizontalCenter;
								text: qsTr("Copy url");
								enabled: root.source != "";
								platformStyle: ButtonStyle {
									buttonWidth: 200; 
								}
								onClicked: {
									timer.restart();
									if(root.source != "")
									{
										vut.copyToClipboard(root.source.toString());
										setMsg(qsTr("Copy video url to clipboard"));
									}
									else
									{
										setMsg(qsTr("Video source is empty"));
									}
								}
							}
						}
					}
					ScrollDecorator{
						flickableItem: settingsflick;
					}
				}
		}

	Rectangle{
		id:toolbar;
		property int theight: root.bottomBarHeight;
		anchors.bottom:parent.bottom;
		width:parent.width;
		color:"black";
		z:1;
		opacity:0.8
		states:[
			State{
				name:constants.state_show;
				PropertyChanges {
					target: toolbar;
					height:theight;
				}
			}
			,
			State{
				name:constants.state_hide;
				PropertyChanges {
					target: toolbar;
					height:0;
				}
			}
		]
        state:constants.state_hide;
        transitions: [
            Transition {
                from:constants.state_hide;
                to:constants.state_show;
                NumberAnimation{
                    target:toolbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.OutExpo;
                }
            }
            ,
            Transition {
                from:constants.state_show;
                to:constants.state_hide;
                NumberAnimation{
                    target:toolbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.InExpo;
                }
            }
        ]
		onStateChanged:{
			if(state === constants.state_hide){
				settingbar.state = constants.state_hide;
			}
		}

		ToolIcon{
			id:play;
			iconId: video.paused ? "toolbar-mediacontrol-play" : "toolbar-mediacontrol-pause";
			anchors.left:parent.left;
			anchors.verticalCenter:parent.verticalCenter;
			enabled:video.playing;
			visible:parent.height === parent.theight;
			onClicked:{
                timer.restart();
				video.paused = !video.paused;
			}
		}

		Text{
			anchors.left:progressBar.left;
			anchors.top:parent.top;
			anchors.bottom:progressBar.top;
			color:"white";
			width:60;
			font.pixelSize:20;
			visible:parent.height === parent.theight;
			text:visible ? Utility.castMS2S(video.position) : "";
		}

		ProgressBar {
			id: progressBar
			anchors{
				left:play.right;
				right:prevpart.left;
				verticalCenter:toolbar.verticalCenter;
			}
			visible:parent.height === parent.theight;
			minimumValue: 0;
			maximumValue: video.duration || 0;
			value: video.position || 0;
			MouseArea{
				anchors.centerIn:parent;
				enabled:video.duration !== 0;
				width:parent.width;
				height:5 * parent.height;
				onClicked:{
                    timer.restart();
					if(video.seekable) {
						video.position = video.duration * mouse.x / parent.width;
					} else {
						setMsg(qsTr("Can not support seek for this video"));
					}
				}
				onPositionChanged:{
                    timer.restart();
					if(video.seekable) {
						video.position = video.duration * mouse.x / parent.width;
					} else {
						setMsg(qsTr("Can not support seek for this video"));
					}
				}
			}
		}

		Text{
			id:durationtext;
			anchors.right:progressBar.right;
			anchors.top:parent.top;
			anchors.bottom:progressBar.top;
			color:"white";
			width:60;
			font.pixelSize:20;
			visible:parent.height === parent.theight;
			text:visible ? Utility.castMS2S(video.duration) : "";
		}
		ToolIcon{
			id:prevpart;
			visible:parent.height === parent.theight && root.canPrev;
			iconId: "toolbar-mediacontrol-previous";
			anchors.right:nextpart.left;
			anchors.verticalCenter:parent.verticalCenter;
			onClicked:{
                timer.restart();
				root.requestPlayPart(constants.play_prev);
			}
		}
		ToolIcon{
			id:nextpart;
			visible:parent.height === parent.theight && root.canNext;
			iconId: "toolbar-mediacontrol-next";
			anchors.right:stop.left;
			anchors.verticalCenter:parent.verticalCenter;
			onClicked:{
                timer.restart();
				root.requestPlayPart(constants.play_next);
			}
		}

		ToolIcon{
			id:stop;
			iconId: "toolbar-mediacontrol-stop";
			anchors.right:parent.right;
			anchors.verticalCenter:parent.verticalCenter;
			visible:parent.height === parent.theight;
			enabled:video.playing;
			onClicked:{
                timer.restart();
				root.stopOnly();
				root.stopped();
			}
		}
	}

	Timer{
		id:timer;
		interval:8000;
        repeat: false;
		running:toolbar.state === constants.state_show;
		onTriggered:{
			toolbar.state = constants.state_hide;
		}
	}
	MouseArea{
		anchors.fill:parent;
		onClicked:{
			if(toolbar.state === constants.state_hide) {
				toolbar.state=constants.state_show;
			} else if(toolbar.state === constants.state_show) {
				toolbar.state=constants.state_hide;
			}
		}
		onDoubleClicked:{
			if(video.playing){
				video.paused = ! video.paused;
			}
		}
	}

	Component.onDestruction:{
		video.stop();
	}
}
