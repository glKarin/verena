import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id:root;
	property alias model:view.model;
	property bool canRecursion:true;
	property bool canGetMore:false;
	property alias max:fheader.max;
	property alias min:fheader.min;
	property alias info:fheader.info;
	signal jump(int page);
	signal refresh;
	signal more;

	ListHeader {
		id:fheader;
		max:root.max;
		anchors.top:parent.top;
		view: view;
		onJump:{
			root.jump(page);
		}
	}
	ListView{
		id:view;
		anchors.fill:parent;
		anchors.topMargin:fheader.height;
		header: RefreshHeader {
			view: ListView.view;
			onRefresh:{
				fheader.hide();
				root.refresh();
			}
		}
		footer:Component{
			GetMoreFooter{
				visible:root.canGetMore;
				width:ListView.view.width;
				onMore:{
					root.more();
				}
			}
		}
		delegate: Component{
			Rectangle{
				height:150;
				width:ListView.view.width;
				color:ListView.isCurrentItem?"lightskyblue":"white";
				Row{
					anchors.fill:parent;
					Image{
						id:image;
						height:parent.height;
						width:height * 4 / 3;
						source:model.thumbnail;
						smooth:true;
					}
					Column{
						width:parent.width - image.width;
						height:parent.height;
						Text{
							width:parent.width;
							height:parent.height / 2;
							color:"black";
							font.pixelSize: constants.pixel_xl;
							wrapMode:Text.WrapAnywhere;
							elide:Text.ElideRight;
							maximumLineCount:2;
							text:model.name;
						}
						Row{
							width:parent.width;
							height:parent.height / 4;
							Image{
								height:parent.height;
								width:height;
								source:Qt.resolvedUrl("../image/verena-s-user.png");
								smooth:true;
							}
							Text{
								width:parent.width - parent.height;
								anchors.verticalCenter:parent.verticalCenter;
								font.pixelSize: constants.pixel_large;
								elide:Text.ElideRight;
								color:"black";
								text: model.username;
							}
						}
						Row{
							width:parent.width;
							height:parent.height / 4;
							Row{
								width:parent.width / 3 * 2;
								height:parent.height;
								Image{
									height:parent.height;
									width:height;
									source:Qt.resolvedUrl("../image/verena-s-calendar.png");
									smooth:true;
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									color:"black";
									clip:true;
									font.pixelSize: constants.pixel_large;
									text:model.published.split(" ")[0];
								}
							}
							Row{
								width:parent.width / 3;
								height:parent.height;
								Image{
									height:parent.height;
									width:height;
									source:Qt.resolvedUrl("../image/verena-s-play.png");
									smooth:true;
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									color:"black";
									font.pixelSize: constants.pixel_large;
									clip:true;
									text:model.video_count;
								}
							}
						}
					}
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						view.currentIndex=index;
						mainpage.addNotification({option: "playlist_detail", title: model.name, thumbnail: model.thumbnail, value: model.id});
						var page = Qt.createComponent(Qt.resolvedUrl("PlaylistDetailPage.qml"));
						pageStack.push(page, {playlistid:model.id, canRecursion:root.canRecursion});
					}
				}
			}
        }
		clip:true;
		spacing:2;
		visible:!show;
		ScrollDecorator{
			flickableItem:parent;
		}
	}

}
