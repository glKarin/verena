import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id:root;
	width:parent.width;
	height:50;
	property string text;
	property alias color:line.color;
	property VerenaRectangle item;

	Column{
		anchors.fill:parent;
		Rectangle{
			id:line;
			width:parent.width;
			height:4;
			color:"grey";
		}
		Row{
			width:parent.width;
			height:parent.height - line.height - line2.height;
			Text{
				id:title;
				width:parent.width - space.width - down.width;
				height: parent.height;
				horizontalAlignment: Text.AlignLeft;
				verticalAlignment: Text.AlignVCenter;
				font.pixelSize: constants.pixel_xl;
				color:"blue";
				font.bold: true;
				text: root.text;
			}
			Rectangle{
				id:space;
				height:parent.height;
				width:4;
				color:line.color;
			}
			ToolIcon{
				id:down;
				iconId: root.item !== null && root.item.state === "show" ? "toolbar-up" : "toolbar-down" ;
				height:parent.height;
				width:height;
				enabled:root.item !== null;
				onClicked:{
					if(root.item !== null){
						if(item.state === "noshow"){
							root.item.state = "show";
						}else if(root.item.state === "show"){
							root.item.state = "noshow";
						}
					}
				}
			}
		}
		Rectangle{
			id:line2;
			width:parent.width;
			height:2;
			color:"grey";
		}
	}
}
