import QtQuick 1.1

Rectangle{
	id:root;

	property variant videos:model.videos;

	width:layout.width;
	height:150;

	Column{
		anchors.fill:parent;
		ListView{
			id:lst;
			width:parent.width;
			height:parent.height - line.height;
			model:videos;
			delegate:Component{
				Rectangle{
					height:ListView.view.height;
					width: height * 4 / 3;
					color:ListView.isCurrentItem?"lightskyblue":"white";
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
							horizontalAlignment: Text.AlignHCenter;
							verticalAlignment: Text.AlignVCenter;
							color:"black";
							font.pixelSize:12;
							elide:Text.ElideRight;
							text:model.title;

							font.family: "Nokia Pure Text";
						}
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							lst.currentIndex=index;
							mainpage.addNotification({option: "video_detail", title: model.title, thumbnail: model.thumbnail, value: model.id});
							var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
							pageStack.push(page, {videoid:model.id});
						}
					}
				}
			}
			clip:true;
			spacing:2;
			orientation:ListView.Horizontal;
		}

		Rectangle{
			id:line;
			width:parent.width;
			height:5;
			color:"orange";
		}

	}
}
