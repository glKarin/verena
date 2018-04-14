import QtQuick 1.1

Rectangle{
	id:root;
	property int twidth:200;
	property bool current:false;

	height:80;
	width:0;
	anchors.verticalCenter:parent.verticalCenter;
	anchors.right:parent.right;
	color:"grey";
	radius:10;
	z:2;
	border.width:5;
    border.color:"blue";

	opacity:0.8;
	onCurrentChanged:{
		if(!current)
        {
            animation.complete();
		}
	}

    SequentialAnimation{
        id:animation;
        NumberAnimation{
            target:root;
            property:"width";
            to:twidth;
            easing.type:Easing.OutExpo;
            duration:400;
        }
        PauseAnimation {
            duration: 5000;
        }
        NumberAnimation{
            target:root;
            property:"width";
            to:0;
            easing.type:Easing.InExpo;
            duration:400;
        }
    }

    function openToolBar(){
        animation.restart();
    }

	function showToolBar() {
        if(animation.running) {
            animation.complete();
		} else {
            animation.restart();
		}
	}

}
