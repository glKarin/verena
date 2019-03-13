import QtQuick 1.1
import com.nokia.symbian 1.1

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
			horizontalAlignment: Text.AlignLeft;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize:24;
			font.bold: true;
			color:"blue";
			elide:Text.ElideRight;

			font.family: "Nokia Pure Text";
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
