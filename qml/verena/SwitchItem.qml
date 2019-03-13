import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	width: parent.width;
	height: 64;
	clip: true;
	objectName: "switch_item";

	property alias text: title.text;
	property alias checked: switcher.checked;
	property bool enabled: true;

	Row{
		anchors.fill: parent;
		LineText{
			id: title;
			anchors.verticalCenter: parent.verticalCenter;
			style: "left";
			width: parent.width - switcher.width;
		}
		Switch{
			id: switcher;
			anchors.verticalCenter: parent.verticalCenter;
			// checked: 
			// onCheckedChanged:{ }
			MouseArea{
				anchors.fill: parent;
				enabled: !root.enabled;
			}
		}
	}
}
