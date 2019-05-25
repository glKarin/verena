import QtQuick 1.1

Item{
	id:root;

	property string text:"";
	property alias isOver:timer.running;
	property alias color:show.color;
    property alias pixelSize:show.font.pixelSize;
	property int index:0;
	height:parent.height;

	Text{
		id:show;
		width:parent.width;
		anchors.verticalCenter:parent.verticalCenter;
		color:"blue";
		clip:true;
        font.pixelSize:18;
        font.family: "Nokia Pure Text";
		text:root.text.substring(index);
	}
	Timer{
		id:timer;
		interval:300;
		running:false;
		repeat:true;
		onTriggered:{
			if(index<root.text.length && show.paintedWidth>show.width){
				index++;
			}else{
				index=0;
			}
		}
	}
}

