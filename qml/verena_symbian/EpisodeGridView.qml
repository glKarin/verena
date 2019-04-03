import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/parserengine.js" as Parser
import "../js/main.js" as Script

Item{
	id:root;
	property bool canGetMore:false;
	property alias model:view.model;
	signal more;
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

	GridView{
		id:view;
		anchors.fill:parent;
		header: Component{
			RefreshHeader {
				view: GridView.view;
				onRefresh:{
					root.refresh();
				}
				onHeightChanged:{
					if(height === 0){
						view.positionViewAtBeginning();
					}
				}
			}
		}
		footer:Component{
			GetMoreFooter{
				visible:root.canGetMore;
				width:GridView.view.width;
				onMore:{
					root.more();
				}
			}
		}
		delegate:Component{
			Rectangle{
				width:GridView.view.cellWidth;
				height:GridView.view.cellHeight;
				radius:10;
				smooth:true;
				border.width:4;
				border.color:"green";
				color:GridView.isCurrentItem?"lightskyblue":"#e2e1e2";
				Text{
					id:title;
					anchors.top:parent.top;
					anchors.left:parent.left;
					height:40;
					width:parent.width;
					horizontalAlignment: Text.AlignHCenter;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants.pixel_small;
					elide:Text.ElideRight;
					wrapMode:Text.WrapAnywhere;
					maximumLineCount:2;
					text:model.title;
					color:"black";
					clip:true;
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							view.currentIndex = index;
						}
					}
				}
				Image{
					id:thumbnail;
					anchors{
						top:title.bottom;
						left:parent.left;
						leftMargin:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 0 : 8;
						right:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? parent.right : tool.left;
						bottom:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? tool.top : parent.bottom;
					}
					smooth:true;
					source:model.thumbnail;
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							view.currentIndex = index;
							mainpage.addNotification({option: "video_detail", title: model.title, thumbnail: model.thumbnail, value: model.id});
							var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
							pageStack.push(page, {videoid:model.id});
						}
					}
				}
				Item{
					id:tool;
					anchors.bottom:parent.bottom;
					anchors.right:parent.right;
					height:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 48 : parent.height;
					width:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? parent.width : 48;
					ToolIcon{
						width:40;
						height:width;
						anchors{
							centerIn:parent;
							verticalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 0 : - height / 2 - (parent.height - 2 * height) / 6;
							horizontalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? - width / 2 - (parent.width - 2 * width) / 6 : 0;
						}
						iconId:"toolbar-mediacontrol-play";
						onClicked:{
							view.currentIndex = index;
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
					ToolIcon{
						width:40;
						height:width;
						anchors{
							centerIn:parent;
							verticalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 0 : height / 2 + (parent.height - 2 * height) / 6;
							horizontalCenterOffset:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? width / 2 + (parent.width - 2 * width) / 6 : 0;
						}
						iconId:"toolbar-directory-move-to";
						onClicked:{
							view.currentIndex = index;
							var page = Qt.createComponent(Qt.resolvedUrl("DownloadPage.qml"));
							pageStack.push(page, {videoid: model.id});
						}
					}
				}
			}
        }
		clip:true;
		cellWidth:parent.width / 3 - 2;
		cellHeight:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? cellWidth * 1.2 : cellWidth * 0.6;
		ScrollDecorator{
			flickableItem:parent;
		}
	}
}
