import QtQuick 1.1

Rectangle {
	id:root;
	width: 128;
	height:width;
	color:"black";
	radius: 90;
	border.color: "lightskyblue";
	border.width: 4;
	visible:opacity != 0.0;
	property alias text:info.text;
	opacity:0;
	smooth:true;
	clip: true;

	function show(){
		animation.restart();
	}

	Text{
		id:info;
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		color:"white";
		font.pixelSize: 20;
		font.family: "Nokia Pure Text";
		font.weight: Font.Bold;
	}

	SequentialAnimation{
		id:animation;
		NumberAnimation{
			target:root;
			property:"opacity";
			to:0.8;
			easing.type:Easing.OutExpo;
			duration:400;
		}
		PauseAnimation {
			duration: 2000;
		}
		NumberAnimation{
			target:root;
			property:"opacity";
			to:0.0;
			easing.type:Easing.InExpo;
			duration:400;
		}
	}

	MouseArea{
		anchors.fill:parent;
		onClicked:{
			animation.complete();
		}
	}

}

