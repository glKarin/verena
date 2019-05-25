import QtQuick 1.1
import com.nokia.symbian 1.1

Rectangle{
	id:root;

	property alias model:view.model;

	width:parent.width;
	height:250;

	Column{
		anchors.fill:parent;
		ListView{
			id:view;
			width:parent.width;
			height:parent.height - line.height;
			delegate: Component{
				Rectangle{
					height:ListView.view.height;
					width:height - 40;
					color:ListView.isCurrentItem?"lightskyblue":"white";
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							view.currentIndex=index;
							mainpage.addNotification({option: "show_detail", title: model.name, thumbnail: model.poster, value: model.id});
							var page = Qt.createComponent(Qt.resolvedUrl("ShowDetailPage.qml"));
							pageStack.push(page, {showid:model.id});
						}
					}
					Column{
						anchors.fill:parent;
						Image{
							height:parent.height/4*3;
							width:parent.width;
							source:model.poster;
						}
						Text{
							width:parent.width;
							height:parent.height/8;
							color:"black";
                            font.pixelSize:14;
							font.family: "Nokia Pure Text";
							elide:Text.ElideRight;
							text:model.name;
						}
                        ToolButton{
                            platformInverted: true;
							width:parent.width;
							height:parent.height/8;
							enabled:model.last_play_video_id.length !== 0;
							text:formatUpdateAndTotal(model.episode_updated, model.episode_count);
							onClicked:{
								view.currentIndex=index;
								mainpage.addNotification({option: "show_detail", title: model.name, thumbnail: model.poster, value: model.id});///////???????
								var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
								pageStack.push(page, {videoid:model.last_play_video_id});
							}
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
