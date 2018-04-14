import QtQuick 1.1
import com.nokia.symbian 1.1

VerenaDialog {
	id: root

	property alias model:repeater.model;
	property string vid;
	signal requestParse(string type, int part);
	headtitle:qsTr("Stream types");
	width:480;
	height:854;

	content:Item {
        width:360;
        height:400;
		Flickable{
			id:flickable;
			anchors.fill:parent;
			clip:true;
			contentWidth:width;
			contentHeight:layout.height;
			Column{
				id:layout;
				width:parent.width;
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
								width:parent.width;
								textColor:"white";
								text:model.name;
							}
							Grid{
								id:grid;
								spacing: 10;
                                columns:3;
								clip:true;
								property variant submodel:model.part;
								width:parent.width;
								Repeater{
									model:grid.submodel;
									Item{
										width:110;
										height:60;
										Text{
											anchors.centerIn:parent;
                                            font.pixelSize:18;
											font.family: "Nokia Pure Text";
											color:"white";
											text:model.title + " [" + model.name + "]";
										}
										MouseArea{
											anchors.fill:parent;
											onClicked:{
												root.requestParse(model.title, model.name);
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
