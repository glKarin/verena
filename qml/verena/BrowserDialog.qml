import QtQuick 1.1
import com.nokia.meego 1.1

VerenaDialog {
	id: root

	property alias model:repeater.model;
	property string url;
	signal request(string option, string source, string vid);

	headtitle:qsTr("Option");
	width: constants.max_width;
	height: constants.max_height;

	content:Item {
		width: constants.max_width;
		height: width * 1.2;
		Column{
			id:header;
			anchors.top:parent.top;
			anchors.left:parent.left;
			width:parent.width;
			height:100;
			Rectangle{
				width:parent.width;
				height:5;
				color:"white";
			}
			Row{
				width:parent.width;
				height:90;
				Text{
					anchors.verticalCenter:parent.verticalCenter;
					font.pixelSize: constants.pixel_xl;
					color:"white";
					text:root.url;
					clip:true;
					width:parent.width - open.width;
				}
				ToolIcon{
					id:open;
					iconId:"toolbar-application-white";
					anchors.verticalCenter:parent.verticalCenter;
					onClicked:{
						root.close();
						//Qt.openUrlExternally(root.url);
						root.request("open", model.source, model.vid);
					}
				}
			}
			Rectangle{
				width:parent.width;
				height:5;
				color:"white";
			}
		}
		Flickable{
			id:flickable;
			anchors.fill:parent;
			anchors.topMargin:header.height;
			clip:true;
			contentWidth:width;
			contentHeight:layout.height;
			Column{
				id:layout;
				width:parent.width;
				Repeater {
					id:repeater;
					Row{
						width:layout.width;
						height:80;
						LineText{
							anchors.verticalCenter:parent.verticalCenter;
                            style:"left";
							width:parent.width - play.width - download.width;
							textColor:"white";
							text:qsTr("Part") + " " + model.part;
						}
						ToolIcon{
							id:play;
							anchors.verticalCenter:parent.verticalCenter;
							iconId:"toolbar-mediacontrol-play-white";
							onClicked:{
								root.close();
								root.request("play", model.source, model.vid);
							}
						}
						ToolIcon{
							id:download;
							anchors.verticalCenter:parent.verticalCenter;
							//visible:false; //to do
							//iconId:"toolbar-directory-move-to-white";
							iconId:"toolbar-trim-white";
							onClicked:{
								root.close();
								//root.request("download", model.source, model.vid);
								root.request("copy", model.source, model.vid);
							}
						}
					}
				}
			}
		}

		ScrollDecorator{
			flickableItem:flickable;
		}

	}
}

