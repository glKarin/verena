import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id:root;
	property alias titleText:dialog.titleText;
	property alias model:dialog.model;
	signal hasSelectedIndex(int i);

	function open(){
		dialog.open();
	}
	SelectionDialog{
		id:dialog;
		onAccepted:{
			if(selectedIndex !== -1){
				root.hasSelectedIndex(selectedIndex);
			}else{
				//close();
				reject();
			}
		}
		/*
		delegate: Component{
			Rectangle{
				height:60;
				width:dialog.width;
				color:"black";
				Text{
					width:parent.width;
					height:parent.height;
					anchors.verticalCenter:parent.verticalCenter;
					color:"white";
					font.pixelSize: constants.pixel_xl;
					elide:Text.ElideRight;
					text:model.value;
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						hasSelectedIndex(index);
						dialog.close();
					}
				}
			}
		}
		*/
	}
}
