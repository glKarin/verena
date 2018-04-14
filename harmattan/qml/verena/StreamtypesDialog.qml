import QtQuick 1.1
import com.nokia.meego 1.1

VerenaDialog {
	id: root

	property alias model:repeater.model;
	property string vid;
	signal requestParse(string type, int part);
	headtitle:qsTr("Stream types");
	width:480;
	height:854;

	content:Item {
		width:480;
		height:600;
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
											anchors.centerIn:parent;
                                            font.pixelSize:20;
											color:"white";
                                            text:model.title + "[" + model.name + "]";
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
