import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	width: parent.width;
	height: mainlayout.height;
	clip: true;
	objectName: "progress_item";
	property alias text: title.text;
	property alias value: progress.value;
	property alias pressed: seekmousearea.pressed;
	property alias enabled: seekmousearea.enabled;
	property bool inverted: false;
	property alias currentText: currentlabel.text;
	property alias totalText: totallabel.text;

	signal clicked(real value);

	Column{
		id: mainlayout;
		anchors{
			top: parent.top;
			left: parent.left;
			right: parent.right;
		}
		width: parent.width;
		spacing: 8;

		LineText{
			id: title;
			anchors.horizontalCenter: parent.horizontalCenter;
		}

		Column{
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			spacing: 2;
			Row{
				width: parent.width;
				height: 20;
				clip: true;
				Text{
					id: currentlabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants.pixel_medium;
					color: root.inverted ? "white" : "black";
					elide: Text.ElideRight;
					text: (progress.value * 100).toFixed(2) + "%";
				}
				Text {
					id: totallabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignRight;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants.pixel_medium;
					color: root.inverted ? "white" : "black";
					elide: Text.ElideRight;
					text: "100%";
				}
			}
			ProgressBar{
				id: progress;
				platformStyle: ProgressBarStyle {
					inverted: root.inverted;
				}
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				MouseArea{
					id: seekmousearea;
					anchors.centerIn: parent;
					width: parent.width;
					height: 5 * parent.height;
					onReleased:{
						root.clicked(mouse.x / width);
					}
				}
			}
		}
	}
}
