import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	width: parent.width;
	height: 64;
	clip: true;

	property bool editable: true;
	property alias text: title.text;
	property alias inputText: input.text;
	property alias actionKeyLabel: sip.actionKeyLabel;
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
			font.pixelSize: 24;
			elide: Text.ElideRight;
			MouseArea{
				enabled: root.editable;
				anchors.fill: parent;
				onClicked: {
					input.makeFocus();
				}
			}
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

			platformSipAttributes:SipAttributes {
				id: sip;
				actionKeyHighlighted: actionKeyEnabled;
				actionKeyEnabled: input.text.length !== 0;
			}
			Keys.onReturnPressed:{
				root.returnPressed();
			}

			onTextChanged: {
				inputTimer.restart();
			}

			platformStyle: TextFieldStyle {
				paddingLeft: 24;
				paddingRight: clearButton.width;
			}

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

