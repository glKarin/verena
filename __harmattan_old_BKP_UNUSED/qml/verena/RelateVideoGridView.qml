import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/parserengine.js" as Parser

Item{
	id:root;
	property bool error:false;
    property alias model:gridview.model;

	Button{
		id:refresh;
		anchors.centerIn:parent;
		enabled:visible;
		platformStyle:ButtonStyle {
			buttonWidth: buttonHeight; 
		}
		visible:root.error;
		iconSource: "image://theme/icon-m-toolbar-refresh";
		z:5;
		onClicked:{
			if(root.error){
                qobj.getRelateVideo();
			}
		}
	}

	GridView{
		id:gridview;
		z:4;
        anchors.fill:parent;
		clip:true;
		interactive:false;
		delegate: Component{
			Item{
				width:gridview.cellWidth;
				height:gridview.cellHeight;
				Rectangle{
					width:parent.width - 10;
					height:parent.height - 4;
					color:"black";
					anchors.centerIn:parent;
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							if(model.id.length !== 0){
								gridview.visible = false;
								mainpage.addSwipeSwitcher(model.title, model.thumbnail, model.id, "youku");
								qobj.internalVideoId = model.id;
								qobj.getStreamtypes();
							}
						}
					}
					Column{
						anchors.fill:parent;
						Image{
							height:parent.height/6*5;
							width:parent.width;
							source:model.thumbnail;
						}
						Text{
							width:parent.width;
							height:parent.height/6;
							color:"white";
							font.pixelSize:14;
							elide:Text.ElideRight;
							text:model.title;
						}
					}
				}
			}
		}
		cellHeight:height / 4;
        cellWidth:width / 5 - 2;
	}
}
