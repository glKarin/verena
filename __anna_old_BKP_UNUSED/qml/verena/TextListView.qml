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
                    font.pixelSize:20;
                    color:"white";
					font.family: "Nokia Pure Text";
					wrapMode:Text.WordWrap;
					text:"<b><big>" + model.name + ": </big></b>" + model.value;
				}
			}
		}
	}


}
