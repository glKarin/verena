import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	objectName: "button_item";
	width: parent.width;
	height: mainlayout.height;
	clip: true;

	property alias text: title.text;
	property alias buttonText: btn.text;
	signal clicked;

	Column{
		id: mainlayout;
		anchors{
			top: parent.top;
			left: parent.left;
			right: parent.right;
		}
		width: parent.width;
		spacing: 2;

		LineText{
			id: title;
			anchors.horizontalCenter: parent.horizontalCenter;
		}
		Button{
			id: btn;
			anchors.horizontalCenter: parent.horizontalCenter;
			onClicked: root.clicked();
		}
	}
}
