import QtQuick 1.1
import com.nokia.symbian 1.1

Dialog {
	id: root

	property alias headtitle:titletext.text;
	property alias headheight:head.height;
	property alias footheight:foot.height;
	property alias buttontext:button.text;

	title: Rectangle {
		id:head;
		height: 60;
		width: parent.width;
		color: "black";
		z:2;
		Column{
			anchors.fill:parent;
			Row{
				height:55;
				width:parent.width;
				Text{
					id:titletext;
					width:parent.width - space.width - tool.width;
					anchors.verticalCenter:parent.verticalCenter;
					font.family: "Nokia Pure Text";
                    font.pixelSize:24;
					color:"deeppink";
				}
				Rectangle{
					id:space;
					anchors.verticalCenter:parent.verticalCenter;
					width:5;
					height:parent.height;
					color:"white"
				}
				ToolIcon{
					id:tool;
					height:parent.height;
					width:height;
                    iconId: Qt.resolvedUrl("../image/verena-m-close.png");
					anchors.verticalCenter:parent.verticalCenter;
					onClicked:{
						root.reject();
					}
				}
			}
			Rectangle{
				width:parent.width;
				height:5;
				color:"white"
			}
		}
	}


	buttons:Item{
		id:foot;
		width:parent.width;
		height:50;
		Button {
			id:button;
			anchors.horizontalCenter: parent.horizontalCenter
			text:qsTr("OK");
			onClicked:{
				root.accept();
			}
		}
	}
    onStatusChanged: {
        if (status === DialogStatus.Closed)
            app.forceActiveFocus();
    }
}

