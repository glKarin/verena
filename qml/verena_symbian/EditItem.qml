import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id: root;

	width: parent.width;
	height: 64;
	clip: true;

	property bool editable: true;
	property alias text: title.text;
	property alias inputText: input.text;
	property alias placeholderText: input.placeholderText;
	property alias inputMethodHints: input.inputMethodHints;
	signal returnPressed;
	signal typeStopped;
	signal cleared;

	Row{
		anchors.fill: parent;
		spacing: 4;
		Text{
			id: title;
			anchors.verticalCenter: parent.verticalCenter;
			width: 120;
			font.pixelSize: 20;
			elide: Text.ElideRight;
			MouseArea{
				enabled: root.editable;
				anchors.fill: parent;
				onClicked: {
					input.makeFocus();
				}
			}

			color: "white";
			font.family: "Nokia Pure Text";
		}

		TextField {
			id: input;

			anchors.verticalCenter: parent.verticalCenter;
			width: parent.width - parent.spacing - title.width;
			readOnly: !root.editable;
			function makeFocus()
			{
				forceActiveFocus();
				platformOpenSoftwareInputPanel();
			}

			function makeBlur()
			{
				platformCloseSoftwareInputPanel();
			}

			Keys.onReturnPressed:{
				root.returnPressed();
			}

			onTextChanged: {
				inputTimer.restart();
			}

			platformLeftMargin: 24;
			platformRightMargin: clearButton.width;

			Timer {
				id: inputTimer;
				interval: 500;
				onTriggered: root.typeStopped();
			}

			ToolIcon {
				id: clearButton;
				anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
				opacity: input.activeFocus ? 1 : 0;
				iconId: "toolbar-close";
				visible: !input.readOnly;
				width: 48;
				height: width;
				Behavior on opacity {
					NumberAnimation { duration: 100; }
				}
				onClicked: {
					input.text = "";
					root.cleared();
					input.forceActiveFocus();
					input.platformOpenSoftwareInputPanel();
				}
			}
		}
	}
}

