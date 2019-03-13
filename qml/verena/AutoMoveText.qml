import QtQuick 1.1

Item{
	id: root;

	property string text :"";
	property alias isOver: timer.running;
	property alias color: show.color;
	property alias pixelSize: show.font.pixelSize;
	property int index: 0;
	property int idleInterval: 5000;

	height: parent.height;

	Text{
		id: show;
		width: parent.width;
		anchors.verticalCenter: parent.verticalCenter;
		color: "blue";
		clip: true;
		text: root.text.substring(index);
		font.pixelSize: 18;
	}
	Timer{
		id: timer;
		property int endTime: 0;
		interval: 500;
		running: false;
		repeat: true;
		onTriggered: {
			if(index < root.text.length && show.paintedWidth > show.width){
				index++;
			}else{
				endTime += timer.interval;
				if(endTime >= root.idleInterval)
				{
					endTime = 0;
					index = 0;
				}
			}
		}
	}
}

