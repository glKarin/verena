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

	function load() {
		video.source = root.source;
		if(video.source.length !== 0){
			video.play();
			video.fillMode = Video.PreserveAspectFit;
			fillmodellist.currentIndex = 0;
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
				setMsg(error + " : " + errorString);
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
		property int theight:60;
		anchors.top:parent.top;
		width:parent.width;
		color:"black";
		z:1;
		opacity:0.8
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: headbar;
					height:theight;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: headbar;
					height:0;
				}
			}
		]
        state:toolbar.state;
        transitions: [
            Transition {
                from:"noshow";
                to:"show";
                NumberAnimation{
                    target:headbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.OutExpo;
                }
            }
            ,
            Transition {
                from:"show";
                to:"noshow";
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
			visible:parent.height === parent.theight;
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
				if(settingbar.state === "noshow"){
					settingbar.state = "show";
				}else if(settingbar.state === "show"){
					settingbar.state = "noshow";
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
        property int twidth:180;
		anchors.left:parent.left;
		anchors.verticalCenter:parent.verticalCenter;
        height:170;
		color:"black";
		z:1;
        opacity:0.8;
        state:"noshow";
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: settingbar;
					width:twidth;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: settingbar;
					width:0;
				}
			}
        ]
        transitions: [
            Transition {
                from:"noshow";
                to:"show";
                NumberAnimation{
                    target:settingbar;
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
                    target:settingbar;
                    property:"width";
                    duration:400;
                    easing.type:Easing.InExpo;
                }
            }
        ]
		Text{
			id:fillmodellabel;
			anchors.top:parent.top;
			width:parent.width;
			height:30;
            font.pixelSize:22;
			text:qsTr("Fill Mode");
			color:"white";
			visible:parent.width === parent.twidth;
			clip:true;
		}
		ListView{
			id:fillmodellist;
			anchors.fill:parent;
			anchors.topMargin:fillmodellabel.height;
			visible:parent.width === parent.twidth;
			interactive:false;
			opacity:parent.opacity;
			clip:true;
			model:ListModel{
				ListElement{
					name: "Fit";
					value: Video.PreserveAspectFit;
				}
				ListElement{
					name: "Crop";
					value: Video.PreserveAspectCrop;
				}
				ListElement{
					name: "Stretch";
					value: Video.Stretch;
				}
			}
			delegate:Component{
				Rectangle{
					width:ListView.view.width;
					height:ListView.view.height / 3;
					opacity:ListView.view.opacity;
					color:ListView.isCurrentItem ? "white" : "black";
					Text{
						color:parent.ListView.isCurrentItem ? "black" : "white";
                        font.pixelSize:24;
						anchors.centerIn:parent;
						text:model.name;
					}
					MouseArea{
						anchors.fill:parent;
                        onClicked:{
                            timer.restart();
							video.fillMode = model.value;
							fillmodellist.currentIndex = index;
						}
					}
				}
			}
		}
	}

	Rectangle{
		id:toolbar;
		property int theight:60;
		anchors.bottom:parent.bottom;
		width:parent.width;
		color:"black";
		z:1;
		opacity:0.8
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: toolbar;
					height:theight;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: toolbar;
					height:0;
				}
			}
		]
        state:"noshow";
        transitions: [
            Transition {
                from:"noshow";
                to:"show";
                NumberAnimation{
                    target:toolbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.OutExpo;
                }
            }
            ,
            Transition {
                from:"show";
                to:"noshow";
                NumberAnimation{
                    target:toolbar;
                    property:"height";
                    duration:400;
                    easing.type:Easing.InExpo;
                }
            }
        ]
		onStateChanged:{
			if(state === "noshow"){
				settingbar.state = "noshow";
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
				// 2017
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
				root.requestPlayPart("prev");
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
				root.requestPlayPart("next");
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
		running:toolbar.state === "show";
		onTriggered:{
			toolbar.state = "noshow";
		}
	}
	MouseArea{
		anchors.fill:parent;
		onClicked:{
			if(toolbar.state === "noshow") {
				toolbar.state="show";
			} else if(toolbar.state === "show") {
				toolbar.state="noshow";
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
