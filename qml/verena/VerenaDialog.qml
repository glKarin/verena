import QtQuick 1.1
import com.nokia.meego 1.1

Dialog {
	id: root

	property alias headtitle:titletext.text;
	property alias headheight:head.height;
	property alias footheight:foot.height;
	property alias buttontext:button.text;
	property int headLineWidth: 2;

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
					height: parent.height;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					maximumLineCount: 2;
					elide: Text.ElideRight;
					wrapMode: Text.WordWrap;
					font.pixelSize:28;
					font.bold: true;
					color:"deeppink";
				}
				Rectangle{
					id:space;
					anchors.verticalCenter:parent.verticalCenter;
					width: root.headLineWidth;
					height:parent.height;
					color:"white"
				}
				ToolIcon{
					id:tool;
					height:parent.height;
					width:height;
					iconId: "toolbar-close-white";
					anchors.verticalCenter:parent.verticalCenter;
					onClicked:{
						root.reject();
					}
				}
			}
			Rectangle{
				width: parent.width;
				height: root.headLineWidth;
				color: "white"
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
}

