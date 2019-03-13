import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id:root;
	visible:false;
	width: 240;
	height:visible ? 50 : 0;

	signal more;

	Rectangle{
		anchors.fill:parent;
		Button{
			anchors.centerIn:parent;
			enabled:root.visible;
			text:qsTr("More");
			onClicked:{
				more();
			}
		}
	}
}
