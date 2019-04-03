import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	width: parent.width;
	height: mainlayout.height;
	clip: true;
	objectName: "slider_item";
	property alias text: title.text;
	property string minText: "";
	property string maxText: "";
	property alias minimumValue: slider.minimumValue;
	property alias maximumValue: slider.maximumValue;
	property alias stepSize: slider.stepSize;
	property alias value: slider.value;
	property bool inverted: false;
	property bool autoLabel: false;
	property alias pressed: slider.pressed;

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
			width: parent.width;
			spacing: 2;
			Item{
				width: parent.width;
				height: minlabel.height;
				Text{
					id: minlabel;
					anchors.left: parent.left;
					anchors.leftMargin: 30;
					anchors.top: parent.top;
					anchors.bottom: parent.bottom;
					width: parent.width / 2;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize:  constants.pixel_medium;
					color: root.inverted ? "white" : "balck";
					elide: Text.ElideRight;
					text: root.autoLabel ? slider.minimumValue : root.minText;
				}
				Text{
					id: maxlabel;
					anchors.right: parent.right;
					anchors.rightMargin: 30;
					anchors.top: parent.top;
					anchors.bottom: parent.bottom;
					width: parent.width / 2;
					horizontalAlignment: Text.AlignRight;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize:  constants.pixel_medium;
					color: root.inverted ? "white" : "balck";
					elide: Text.ElideRight;
					text: root.autoLabel ? slider.maximumValue : root.maxText;
				}
			}
			Slider{
				id: slider;
				width: parent.width;
				anchors.horizontalCenter: parent.horizontalCenter;
				minimumValue: 0;
				maximumValue: 100;
				stepSize: 1;
				value: 1;
				valueIndicatorText: value.toString();
			}
		}
	}
}
