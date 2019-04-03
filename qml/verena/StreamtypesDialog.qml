import QtQuick 1.1
import com.nokia.meego 1.1

VerenaDialog {
	id: root

	property alias model:repeater.model;
	property string vid;
	signal requestParse(string type, int part, string url);
	property variant yk: YoukuPlayerHelper{
		id: ykobj;
		vid: root.vid;
	}

	headtitle: qsTr("Stream types");
	width: constants.max_width;
	height: constants.max_height;

	content:Item {
		width: constants.max_width;
		height: width * 1.2;
		Flickable{
			id:flickable;
			anchors.fill:parent;
			clip:true;
			contentWidth:width;
			contentHeight:layout.height;
			Column{
				id:layout;
				width:parent.width;
				spacing: 4;
				Repeater {
					id:repeater;
					Item{
						width:layout.width;
						height:grid.height + header.height;
						Column{
							anchors.fill:parent;
							clip:true;
							LineText{
								id:header;
								textAnchors.horizontalCenter:horizontalCenter;
								width:parent.width;
								textColor:"white";
								text:model.name;
							}
							Grid{
								id:grid;
								//spacing: 4;
								columns:4;
								clip:true;
								property variant submodel:model.part;
								width:parent.width;
								Repeater{
									model:grid.submodel;
									Item{
										width:120;
										height:60;
										Text{
											anchors.fill: parent;
											font.pixelSize:  constants.pixel_xl;
											color: model.url.length ? "white" : "red";
											//text: model.url.length ? model.title + "[" + model.name + "]" : "<s>" + model.title + "[" + model.name + "]</s>";
											text: /* model.title + */ "[" + model.name + "]";
											horizontalAlignment: Text.AlignHCenter;
											verticalAlignment: Text.AlignVCenter;
											elide: Text.ElideLeft;
										}
										MouseArea{
											anchors.fill:parent;
											onClicked:{
												root.requestParse(model.title, model.value, model.url);
												root.close();
											}
										}
									}
								}
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
