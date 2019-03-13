import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/parserengine.js" as Parser
import "../js/main.js" as Script

Item{
	id:root;
	property alias model:view.model;
	property bool canRecursion:true;
	property alias max:fheader.max;
	signal jump(int page);
	signal refresh;

	StreamtypesDialog{
		id:dialog;
		model:ListModel{id:typemodel;}
		onRequestParse:{
			if(settingsObject.youkuVideoUrlLoadOnce)
			{
				if(url.length)
				{
					vplayer.load(url);
				}
				else
				{
					setMsg(qsTr("Video is a preview."));
				}
			}
			else
			{
				Parser.loadSource(vid, "youku", vplayer, [type], [part], {settings: settingsObject});
			}
		}
	}

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
		header: Component{
			RefreshHeader {
				view: ListView.view;
				onRefresh:{
					fheader.hide();
					root.refresh();
				}
			}
		}
		delegate:Component{
			Rectangle{
				height:120;
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
						MouseArea{
							anchors.fill:parent;
							onClicked:{
								view.currentIndex=index;
								mainpage.addSwipeSwitcher(model.title, model.thumbnail, model.id, "youku");
								if(settingsObject.defaultPlayer === 0) {
									var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
									pageStack.push(page, {videoid: model.id}, true);
								}else if(settingsObject.defaultPlayer === 1){
									if(model.id.length === 0){
										return;
									}
									dialog.vid = model.id;
									function s(obj){
										typemodel.clear();
										dialog.yk.getStreamtypesModel(obj, typemodel);
										dialog.open();
									}
									function f(err){
										setMsg(err);
									}
									Script.getVideoStreamtypes(model.id, s, f);
								}
							}
						}
					}
					Column{
						width:parent.width - image.width;
						height:parent.height;
						Text{
							width:parent.width;
							height:parent.height / 4 * 3;
							color:"black";
							font.pixelSize:18;
							maximumLineCount:3;
							elide:Text.ElideRight;
							text:model.title;
							wrapMode:Text.WrapAnywhere;

							font.family: "Nokia Pure Text";
							MouseArea{
								anchors.fill:parent;
								onClicked:{
									view.currentIndex=index;
									mainpage.addNotification({option: "video_detail", title: model.title, thumbnail: model.thumbnail, value: model.id});
									var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
									pageStack.push(page, {videoid:model.id, canRecursion: root.canRecursion});
								}
							}
						}
						Row{
							width:parent.width;
							height:parent.height / 4;
							Row{
								width:parent.width / 2;
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
									font.pixelSize:16;
									text:model.published.split(" ")[0];

									font.family: "Nokia Pure Text";
								}
							}
							Row{
								width:parent.width / 2;
								height:parent.height;
								visible:model.view_count >= 0;
								Image{
									height:parent.height;
									width:height;
									source:Qt.resolvedUrl("../image/verena-s-play.png");
									smooth:true;
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									font.pixelSize:16;
									clip:true;
									color:"black";
									text:model.view_count;

									font.family: "Nokia Pure Text";
								}
							}
						}
					}
				}
			}
        }
		clip:true;
		spacing:2;

		ScrollDecorator{
			flickableItem:parent;
		}
	}
}
