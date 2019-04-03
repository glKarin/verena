import QtQuick 1.1

Rectangle{
	id:root;

	property alias model:view.model;

	width:parent.width;
	height:200;

	Column{
		anchors.fill:parent;
		ListView{
			id:view;
			width:parent.width;
			height:parent.height - line.height;
			delegate: Component{
				Rectangle{
					height:ListView.view.height;
					width:height;
					color:ListView.isCurrentItem?"lightskyblue":"white";
					Column{
						anchors.fill:parent;
						Image{
							id:image;
							height:parent.height / 4 * 3;
							width:parent.width;
							source:model.thumbnail;
						}
						Text{
							width:parent.width;
							height:parent.height / 8;
							horizontalAlignment: Text.AlignHCenter;
							verticalAlignment: Text.AlignVCenter;
							color:"black";
							font.pixelSize: constants.pixel_medium;
							elide:Text.ElideRight;
							text:model.name;
						}
						Text{
							width:parent.width;
							height:parent.height / 8;
							color:"black";
							font.pixelSize: constants.pixel_medium;
							elide:Text.ElideRight;
							text:qsTr("Video Count") + ": " + model.video_count;
						}
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							view.currentIndex=index;
							mainpage.addNotification({option: "playlist_detail", title: model.name, thumbnail: model.thumbnail, value: model.id});
							var page = Qt.createComponent(Qt.resolvedUrl("PlaylistDetailPage.qml"));
							pageStack.push(page, {playlistid:model.id, canRecursion:true});
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
