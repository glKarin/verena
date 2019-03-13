import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle{
	id: root;
	property Flickable viewItem;
	property bool current: false;

	width: 240;
	height: 240;
	color: current ? "lightskyblue" : "white";
	MouseArea{
		anchors.fill:parent;
		onClicked:{
			viewItem.currentIndex = index;
			mainpage.addNotification({option: "show_detail", title: model.name, thumbnail: model.poster, value: model.id});
			var page = Qt.createComponent(Qt.resolvedUrl("ShowDetailPage.qml"));
			pageStack.push(page, {showid:model.id});
		}
	}
	Column{
		anchors.fill:parent;
		Image{
			height:parent.height/3*2;
			width:parent.width;
			source: model.thumbnail;
			smooth:true;
		}
		Text{
			width:parent.width;
			height:parent.height/6;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			color:"black";
			font.pixelSize:20;
			elide:Text.ElideRight;
			text:model.name;
			//wrapMode:Text.WrapAnywhere;
			//maximumLineCount: 2;
		}
		Button{
			width:parent.width;
			height:parent.height/6;
			enabled:model.last_play_video_id !== "";
			text:formatUpdateAndTotal(model.episode_updated, model.episode_count);
			onClicked:{
				viewItem.currentIndex = index;
				mainpage.addNotification({option: "video_detail", title: "节目-%1 最近更新".arg(model.name), value: model.last_play_video_id, thumbnail: model.thumbnail});
				var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
				pageStack.push(page, {videoid:model.last_play_video_id});
			}
		}
	}
}
