import QtQuick 1.1

Item{
	id:root;
	property alias model:lst.model;
	property alias spacing:lst.spacing;

	ListView{
		id:lst;
		anchors.fill:parent;
		clip:true;
        spacing:2;
		delegate:Component{
			Item{
				height:info.height;
				width:ListView.view.width;
				Text{
					id:info;
					width:parent.width;
					font.pixelSize: constants.pixel_large;
					wrapMode:Text.WordWrap;
					text:"<b>" + model.name + ": </b>" + model.value;
					color: "white";
				}
			}
		}
	}


}
