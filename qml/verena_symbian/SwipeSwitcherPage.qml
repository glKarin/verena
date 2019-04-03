import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id:root;
	anchors.fill:parent;
	signal lockPage(bool yes);

	function reset(){
		editMode = false;
	}

	property alias model:maingrid.model;
	property bool editMode:false;
	property int enterEditModeAnimationDuration:250;//OutExpo
	property real editModeShadow:0.5;
	property int cornerRadius:6;//16
	property int incomingAnimationDuration:400;//overshotbezier
	property int outgoingAnimationDuration:250;//inback
	property int closeButtonIncomingAnimationDuration:400;//overshotbezier
	property int closeButtonOutgoingAnimationDuration:250;//outexpo
	//opacity animation: outexpo
	property int bigCardWidth:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 162 : 288;//216 : 385;
	property int bigCardHeight:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 275 : 150;//368 : 200;
	property int toolbarHeight:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 52 : 41;//70 :55;
	property int toolButtonWidth:135;//180;//160;
	property int toolButtonHeight:29;//40;//39;
	property string toolButtonTextColor:"white";
	property int toolbarLayoutSpacing:6;//8;
	property int closeButtonWidth:36;//48;
	property int closeButtonHeight:36;//48;
	property int closeButtonRightMargin:-6;//-8;
	property int closeButtonTopMargin:-6;//-8;
	property string emptyTextColor:"#323232";
	property int emptyTextSize:46;//62;//light
	property int bigGridSpacing:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 15 : 17;//20 : 24;
	property int bigGridLeftMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 10 : 22;//14 : 30;
	property int bigGridRightMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 10 : 22;//14 :30;
	property int bigGridTopMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 17 : 22;//24 :30;
	property int bigGridBottomMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 10 : 22;//14 :30;
	property int smallCardWidth:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 103 : 185;//138 : 248;
	property int smallCardHeight:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 176 : 96;//235 : 129;
	property int smallGridSpacing:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 14 : 18;//19 : 25;
	property int smallGridLeftMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 10 : 22;//14 : 30;
	property int smallGridRightMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 10 : 22;//14 :30;
	property int smallGridTopMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 17 : 18;//24 :24;
	property int smallGridBottomMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 10 : 18;//14 :24;
	property int cardWidth:settingsObject.cardCountOfLine === 2 ? bigCardWidth : smallCardWidth;
	property int cardHeight:settingsObject.cardCountOfLine === 2 ? bigCardHeight : smallCardHeight;
	property int gridSpacing:settingsObject.cardCountOfLine === 2 ? bigGridSpacing : smallGridSpacing;
	property int gridTopMargin:settingsObject.cardCountOfLine === 2 ? bigGridTopMargin : smallGridTopMargin;
	property int gridBottomMargin:settingsObject.cardCountOfLine === 2 ? bigGridBottomMargin : smallGridBottomMargin;
	property int gridLeftMargin:settingsObject.cardCountOfLine === 2 ? bigGridLeftMargin : smallGridLeftMargin;
	property int gridRightMargin:settingsObject.cardCountOfLine === 2 ? bigGridRightMargin : smallGridRightMargin;
	property int titleHeight:settingsObject.cardCountOfLine === 2 ? 44 : 29;//60 : 40;
	property int titleSize:settingsObject.cardCountOfLine ===2 ? 14 : 12;//16 : 12;
	property int toolSize:settingsObject.cardCountOfLine === 2 ? 45 : 30;//60 : 40;
	property int toolbarSize:settingsObject.cardCountOfLine === 2 ? 59 : 44;//80 : 60;
	property bool sizeBinding:true;

	Text{
		anchors.centerIn:parent;
		anchors.verticalCenterOffset:-36 / 2;
		font.pixelSize:emptyTextSize;
		color:emptyTextColor;
		font.weight:Font.Light;
		text:qsTr("Nothing open yet");
		visible:maingrid.model && maingrid.count <= 0;
	}
	MouseArea{
		anchors.fill:parent;
		enabled:maingrid.model && maingrid.count > 0;
		onPressAndHold:{
			root.editMode = true;
		}
		onClicked:{
			root.editMode = false;
		}
	}
	Flickable{
		id:flick;
		anchors.fill:parent;
		anchors.bottomMargin:toolbar.height;
		z:1;
		contentWidth:width;
		contentHeight:Math.max(grid.height + gridBottomMargin, flick.height);
		clip:true;
		PinchArea{
			property int cardCount;
			property int spacingAbs;
			anchors.fill:parent;
			enabled:maingrid.model && maingrid.count > 0 && !root.editMode;
			//width range: grid.width --- flick.width / 2
			//spacing range: 0 --- cardWidth
			onPinchStarted:{
				cardCount = settingsObject.cardCountOfLine;
				spacingAbs = screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? root.cardWidth : root.cardHeight;
				root.sizeBinding = false;
				lockPage(true);
			}
			onPinchUpdated:{
				if(cardCount === 2){
                    if(pinch.scale < 0.6){
						settingsObject.cardCountOfLine = 3;
						grid.cardWidth = bigCardWidth - (1 - pinch.scale) * (bigCardWidth - smallCardWidth);
						grid.cardHeight = bigCardHeight - (1 - pinch.scale) * (bigCardHeight - smallCardHeight);
						spacingAbs = grid.cardWidth - gridSpacing;
						grid.spacing = - spacingAbs * pinch.scale * 2;
					}else if(pinch.scale > 1.0){
						if(pinch.scale < 1.05){
							grid.cardWidth = bigCardWidth - (1 - pinch.scale) * (bigCardWidth - smallCardWidth);
							grid.cardHeight = bigCardHeight - (1 - pinch.scale) * (bigCardHeight - smallCardHeight);
							spacingAbs = grid.cardWidth - gridSpacing;
							grid.spacing = - spacingAbs * (1 - pinch.scale) * 2;
						}
					}else{
						settingsObject.cardCountOfLine = 2;
						grid.cardWidth = bigCardWidth - (1 - pinch.scale) * (bigCardWidth - smallCardWidth);
						grid.cardHeight = bigCardHeight - (1 - pinch.scale) * (bigCardHeight - smallCardHeight);
						spacingAbs = grid.cardWidth - gridSpacing;
						grid.spacing = - spacingAbs * (1 - pinch.scale) * 2;
					}
					return;
				}else if(cardCount === 3){
					if(pinch.scale > 1.5){
						if(pinch.scale < 2.05){
							settingsObject.cardCountOfLine = 2;
							grid.cardWidth = smallCardWidth + (pinch.scale - 1) * (bigCardWidth - smallCardWidth);
							grid.cardHeight = smallCardHeight + (pinch.scale - 1) * (bigCardHeight - smallCardHeight);
							spacingAbs = grid.cardWidth - gridSpacing;
							grid.spacing = - spacingAbs * (2 - pinch.scale) * 2;
						}
					}else if(pinch.scale < 1.0){
						if(pinch.scale > 0.9){
							grid.cardWidth = smallCardWidth + (pinch.scale - 1) * (bigCardWidth - smallCardWidth);
							grid.cardHeight = smallCardHeight + (pinch.scale - 1) * (bigCardHeight - smallCardHeight);
							spacingAbs = grid.cardWidth - gridSpacing;
							grid.spacing = - spacingAbs * (1 - pinch.scale) * 2;
						}
					}else{
						settingsObject.cardCountOfLine = 3;
						grid.cardWidth = smallCardWidth + (pinch.scale - 1) * (bigCardWidth - smallCardWidth);
						grid.cardHeight = smallCardHeight + (pinch.scale - 1) * (bigCardHeight - smallCardHeight);
						spacingAbs = grid.cardWidth - gridSpacing;
						grid.spacing = - spacingAbs * (pinch.scale - 1) * 2;
					}
					return;
				}
			}
			onPinchFinished:{
				grid.spacing = 0;
				grid.cardWidth = root.cardWidth;
				grid.cardHeight = root.cardHeight;
				root.sizeBinding = true;
				lockPage(false);
			}
		}
		Binding{
			target:grid;
			property:"cardWidth";
			value:root.cardWidth;
			when:root.sizeBinding;
		}
		Binding{
			target:grid;
			property:"cardHeight";
			value:root.cardHeight;
			when:root.sizeBinding;
		}
		Grid{
			id:grid;
			property real cardWidth:root.cardWidth;
			property real cardHeight:root.cardHeight;
			anchors{
				//centerIn:parent;
				top:parent.top;
				left:parent.left;
				right:parent.right;
				topMargin:gridTopMargin - gridSpacing / 2;
				leftMargin:gridLeftMargin - gridSpacing / 2;
				rightMargin:gridRightMargin - gridSpacing / 2;
			}
			//width:parent.width - gridLeftMargin - gridRightMargin + gridSpacing;
			//spacing:gridSpacing;
			columns:settingsObject.cardCountOfLine;
			Behavior on spacing {
				NumberAnimation {
					duration:250;
					easing.type: Easing.Linear;
				}
			}
			add:Transition {
				NumberAnimation {
					properties: "x,y";
					easing.type: Easing.OutExpo;
					duration:incomingAnimationDuration;
				}
			}
			move:Transition {
				NumberAnimation {
					properties: "x,y";
					easing.type: Easing.OutExpo;
					duration:outgoingAnimationDuration;
				}
			}
			clip:true;
			Repeater{
				id:maingrid;
				Item{
					width:grid.cardWidth + gridSpacing;
					height:grid.cardHeight + gridSpacing;
					MouseArea{
						anchors.fill:parent;
						onPressAndHold:{
							root.editMode = true;
						}
					}
					Behavior on width {
						NumberAnimation {
							duration:250;
							easing.type: Easing.Linear;
						}
					}
					Behavior on height {
						NumberAnimation {
							duration:250;
							easing.type: Easing.Linear;
						}
					}
					Rectangle{
						id:card;
						anchors.centerIn:parent;
						width:grid.cardWidth;
						height:grid.cardHeight;
						radius:cornerRadius;
						clip: true;
						color:"#e2e1e2";
						smooth:true;
						Behavior on width {
							NumberAnimation {
								duration:250;
								easing.type: Easing.Linear;
							}
						}
						Behavior on height {
							NumberAnimation {
								duration:250;
								easing.type: Easing.Linear;
							}
						}
						Text{
							id:title;
							anchors.top:parent.top;
							anchors.left:parent.left;
							height:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? titleHeight : titleHeight / 2;
							width:parent.width;
							horizontalAlignment: Text.AlignHCenter;
							verticalAlignment: Text.AlignVCenter;
							font.pixelSize:titleSize;
							elide:Text.ElideRight;
							wrapMode:Text.WrapAnywhere;
							maximumLineCount:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 2 : 1;
							text:model.title;
							color:"black";
							clip:true;
							MouseArea{
								anchors.fill:parent;
								onClicked:{
									if(model.source === "youku"){
										var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
										pageStack.push(page, {videoid:model.vid});
									}
								}
								onPressAndHold:{
									root.editMode = true;
								}
							}
						}
						Image{
							id:thumbnail;
							anchors{
								top:title.bottom;
								left:parent.left;
								leftMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 0 : 8;
								right:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? parent.right : tool.left;
								bottom:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? tool.top : parent.bottom;
							}
							fillMode: Image.PreserveAspectCrop;
							smooth:true;
							clip: true;
							source:model.thumbnail;
							MouseArea{
								anchors.fill:parent;
								onClicked:{
									if(model.source === "youku"){
										var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
										pageStack.push(page, {videoid:model.vid});
									}
								}
								onPressAndHold:{
									root.editMode = true;
								}
							}
						}
						Item{
							id:tool;
							anchors.bottom:parent.bottom;
							anchors.right:parent.right;
							height:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? toolbarSize : parent.height;
							width:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? parent.width : toolbarSize;
							MouseArea{
								anchors.fill:parent;
								onPressAndHold:{
									root.editMode = true;
								}
							}
							Image{
								width:toolSize;
								height:width;
								anchors{
									centerIn:parent;
									verticalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 0 : - height / 2 - (parent.height - 2 * height) / 6;
									horizontalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? - width / 2 - (parent.width - 2 * width) / 6 : 0;
								}
								source: Qt.resolvedUrl("../image/verena-s-play.png");
								smooth:true;
								MouseArea{
									anchors.fill:parent;
									onClicked:{
										var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
										var params = {};
										if(model.source === "youku"){
											params["videoid"] = model.vid;
										}else{
											params["source"] = model.source;
											params["videosource"] = model.vid;
										}
										pageStack.push(page, params, true);
									}
									onPressAndHold:{
										root.editMode = true;
									}
								}
							}
							Image{
								width:toolSize;
								height:width;
								enabled:model.source === "youku";
								anchors{
									centerIn:parent;
									verticalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 0 : height / 2 + (parent.height - 2 * height) / 6;
									horizontalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? width / 2 + (parent.width - 2 * width) / 6 : 0;
								}
								source: Qt.resolvedUrl("../image/verena-s-download.png");
								smooth:true;
								MouseArea{
									anchors.fill:parent;
									onClicked:{
										root.editMode = false;
										var page = Qt.createComponent(Qt.resolvedUrl("DownloadPage.qml"));
										pageStack.push(page, {videoid: model.vid});
									}
									onPressAndHold:{
										root.editMode = true;;
									}
								}
							}
						}
					}
					Rectangle{
						anchors.fill:parent;
						z:1;
						opacity:editModeShadow;
						color:"black";
						visible:root.editMode;
						MouseArea{
							anchors.fill:parent;
						}
					}
					Image{
						id:close;
						anchors{
							horizontalCenter:card.right;
							verticalCenter:card.top;
							horizontalCenterOffset: - closeButtonRightMargin - closeButtonWidth / 2;
							verticalCenterOffset:closeButtonHeight / 2 + closeButtonTopMargin;
						}
						z:2;
						source:Qt.resolvedUrl("../image/verena-m-close.png");
						visible:height !== 0 && width !== 0;
						smooth:true;
						states:[
							State{
								name:"show";
								PropertyChanges {
									target: close;
									width:closeButtonWidth;
									height:closeButtonHeight;
								}
							}
							,
							State{
								name:"noshow";
								PropertyChanges {
									target: close;
									width:0;
									height:0;
								}
							}
						]
						state:root.editMode ? "show" : "noshow";
						transitions: [
							Transition {
								from:"noshow";
								to:"show";
								NumberAnimation{
									target:close;
									properties:"width,height";
									easing.type:Easing.OutExpo;
									duration:closeButtonIncomingAnimationDuration;
								}
							}
							,
							Transition {
								from:"show";
								to:"noshow";
								NumberAnimation{
									target:close;
									properties:"width,height";
									easing.type:Easing.OutExpo;
									duration:closeButtonOutgoingAnimationDuration;
								}
							}
						]
						MouseArea{
							anchors.fill:parent;
							onClicked:{
								parent.opacity = 1.0;
								maingrid.model.remove(index);
								if(maingrid.count <= 0){
									root.editMode = false;
								}
							}
							onCanceled:{
								parent.opacity = 1.0;
							}
							onPressed:{
								parent.opacity = 0.6;
							}
						}
					}
				}
			}
		}
	}
	ScrollDecorator{
		opacity:0.5;
		flickableItem:flick;
	}
	Rectangle{
		id:toolbar;
		anchors.bottom:parent.bottom;
		anchors.left:parent.left;
		width:parent.width;
		z:2;
		color:"black";
		gradient: Gradient {
			GradientStop {
				position: 0.0; 
				color: "#080C08";
			}
			GradientStop { 
				position: 1.0;
				color: "black";
			}
		}
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: toolbar;
					height:toolbarHeight;
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
		state:root.editMode ? "show" : "noshow";
		transitions: [
			Transition {
				NumberAnimation{
					target:toolbar;
					property:"height";
					easing.type:Easing.OutExpo;
					duration:enterEditModeAnimationDuration;
				}
			}
		]
		Rectangle{
			height:1;
			width:parent.width;
			color:"#212421";
			visible:parent.height === toolbarHeight;
		}
		VTHomeButton{
			anchors.centerIn:parent;
			anchors.horizontalCenterOffset:- toolbarLayoutSpacing / 2 - toolButtonWidth / 2;
			visible:parent.height === toolbarHeight;
			text:qsTr("Done");
			textColor: toolButtonTextColor;
			labelSize:20;
			pressedTextColor: toolButtonTextColor;
			backgroundColor:"#211C21";
			backgroundColor2:"#000000";
			backgroundPressedColor:"#313031";
			backgroundPressedColor2:"#181818";
			buttonWidth: toolButtonWidth;
			buttonHeight: toolButtonHeight;
			onClicked:{
				root.editMode = false;
			}
		}
		VTHomeButton{
			anchors.centerIn:parent;
			anchors.horizontalCenterOffset:toolbarLayoutSpacing / 2 + toolButtonWidth / 2;
			visible:parent.height === toolbarHeight;
			text:qsTr("Close all");
			labelSize:20;
			textColor: toolButtonTextColor;
			pressedTextColor: toolButtonTextColor;
			backgroundColor:"#211C21";
			backgroundColor2:"#000000";
			backgroundPressedColor:"#313031";
			backgroundPressedColor2:"#181818";
			buttonWidth: toolButtonWidth;
			buttonHeight: toolButtonHeight;
			onClicked:{
				if(maingrid.model){
					maingrid.model.clear();
				}
				root.editMode = false;
			}
		}
	}

}

