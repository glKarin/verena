import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle{
	id:root;

	property alias text:label.text;
	property alias enabled:button.enabled;
	signal trigger;

	width:parent.width;
	height:40;
	color:"lightgreen";
	Row{
		anchors.fill:parent;
		Text{
			id:label;
			height:parent.height;
			width:parent.width / 4 * 3;
			font.pixelSize:28;
			color:"blue";
			elide:Text.ElideRight;
		}
		Button{
			id:button;
			height:parent.height;
			width:parent.width / 4;
			text:qsTr("More") + ">>";
			onClicked:{
				root.trigger();
			}
		}
	}
}
