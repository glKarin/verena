import QtQuick 1.1
import com.nokia.symbian 1.1

Rectangle{
	id:root;
	anchors.fill:parent;
	property alias model:maingrid.model;

    property int desktopWidth:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 89 : 90;//120 : 122;
	property int iconHorizontalMargin:(desktopWidth - iconWidth) / 2;
    property int desktopHeight:80;//118;
	property int iconTopMargin:(desktopHeight - iconHeight) / 2;
    property int textHeight:22;//30;
    property int iconWidth:60;//80;
    property int iconHeight:60;//80;
	property real frontBackgroundOpacity:0.5;
    property int folderContentMinTopMargin:60;//80;
	property int folderContentMinBottomMargin:147;
	property int folderBorderLineWidth:1;
	//folder-content-vertical-offset-from-button-top: 8.0mm;
    property int folderContentMinHeight:88;//118 ;
    property int folderContentMaxHeight:screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 394 : 114;//527 : 153;
	property int folderSizeChangeAnimationDuration:250;//outexpo
	property int folderOpacityChangeAnimationDuration:250;
    property int desktopLabelSize:14;//18;//normal //zh 20 light
	property string desktopLabelColor:"#FFFFFF";
    property int folderTopPadding:4;//6;
    property int folderBottomPadding:4;//6;

	function setHeight(count){
		var columns = screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 4 : 7;
		var max = screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 3 : 1;
		if(count > columns * max){
			return folderContentMaxHeight;
		}else if(count === 0){
			return folderContentMinHeight;
		}else{
			return (count / columns + (count % columns !== 0 ? 1 : 0)) * desktopHeight;
		}
	}

	color:"black";
	GridView{
		id:maingrid;
		anchors.fill:parent;
		clip:true;
		model:hsmodel;
		cellWidth:desktopWidth;
		cellHeight:desktopHeight + textHeight;
		delegate:Component{
			Item{
				width:GridView.view.cellWidth;
				height:GridView.view.cellHeight;
				Image{
					id:icon;
					anchors.top:parent.top;
					anchors.topMargin:iconTopMargin;
					height:iconHeight;
					width:iconWidth;
					anchors.horizontalCenter:parent.horizontalCenter;
					source:model.actions === "category" ? Qt.resolvedUrl("../image/verena-l-folder.png") : model.icon;
					smooth:true;
					Image{
						anchors.centerIn:parent;
						width:30;
						height:width;
						smooth:true;
						z:1;
						source:model.actions === "category" ? model.icon : "";
						visible:model.actions === "category";
					}
				}
				Text{
					anchors.topMargin:iconTopMargin;
					anchors.top:icon.bottom;
					font.pixelSize:desktopLabelSize + 2;
					font.weight:Font.Light;
					font.family: "Nokia Pure Text";
					color:desktopLabelColor;
					elide:Text.ElideRight;
					anchors.horizontalCenter:parent.horizontalCenter;
					clip:true;
					text:model.name;
				}
				Rectangle{
					id:shadow;
					anchors.fill:parent;
					color:"black";
					opacity:0.5;
                    visible:mousearea.pressed;
				}
				MouseArea{
                    id:mousearea;
					anchors.topMargin:iconTopMargin;
                    anchors.fill:parent;
					onClicked:{
                        maingrid.currentIndex = index;
							if(model.actions === "category"){
								//maingrid.contentY = - maingrid.currentItem.y + iconTopMargin;
								foldergrid.model = model.childModel;
								folderlabel.text = model.name;
								foldercontenticon.source = model.icon;
								foldergrid.positionViewAtBeginning();
								subgrid.state = "show";
							}else if(model.actions === "refresh"){
								qobj.refresh();
							}else if(model.actions === "quit"){
								Qt.quit();
							}else if(model.actions === "unfinished"){
								setMsg(qsTr("Comimg soon!"));
							}else{
                                var page = Qt.createComponent(Qt.resolvedUrl(model.actions + ".qml"));
                                pageStack.push(page);
                            }
					}
				}
			}
		}
	}
	ScrollDecorator{
		opacity:0.5;
        flickableItem:maingrid;
	}
	Item{
		id:folder;
		anchors.fill:parent;
		visible:subgrid.height !== 0;
		z:1;
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: folder;
					opacity:1.0;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: folder;
					opacity:0;
				}
			}
		]
		state:subgrid.state;
		transitions: [
			Transition {
				from:"noshow";
				to:"show";
				NumberAnimation{
					target:folder;
					property:"opacity";
					duration:folderOpacityChangeAnimationDuration;
					easing.type:Easing.OutExpo;
				}
			}
			,
			Transition {
				from:"show";
				to:"noshow";
				NumberAnimation{
					target:folder;
					property:"opacity";
					duration:folderOpacityChangeAnimationDuration;
					easing.type:Easing.OutSine;
				}
			}
		]
		Image{
			id:foldericon;
			z:2;
			x:maingrid.currentItem.x + iconHorizontalMargin;
			y:maingrid.currentItem.y + iconTopMargin;
			height:iconHeight;
			width:iconWidth;
			source:Qt.resolvedUrl("../image/verena-l-folder.png");
			smooth:true;
			Image{
				id:foldercontenticon;
				anchors.centerIn:parent;
				width:30;
				height:width;
				smooth:true;
				z:1;
			}
		}
		Rectangle{
			opacity:frontBackgroundOpacity;
			width:parent.width;
			anchors.top:parent.top;
			anchors.left:parent.left;
			anchors.bottom:line.top;
			color:"black";
			MouseArea{
				anchors.fill:parent;
				onClicked:{
					subgrid.state = "noshow";
				}
			}
		}
		Rectangle{
			id:corner;
			anchors.verticalCenter:line.verticalCenter;
			anchors.verticalCenterOffset:1;
			anchors.horizontalCenter:foldericon.horizontalCenter;
			opacity:parent.opacity;
			rotation:45;
			border.width:folderBorderLineWidth;
			border.color:"white";
			color:"black";
			width:15;
			height:width;
			z:2;
			smooth:true;
			MouseArea{
				anchors.fill:parent;
			}
		}
		Rectangle{
			id:line;
			anchors.top:foldericon.bottom;
			anchors.left:parent.left;
			z:1;
			width:parent.width;
			height:folderBorderLineWidth;
			opacity:parent.opacity;
			color:"white";
			MouseArea{
				anchors.fill:parent;
			}
		}
		Rectangle{
			id:label;
			anchors.top:line.bottom;
			anchors.left:parent.left;
			width:parent.width;
			height:60;
			color:"black";
			opacity:parent.opacity;
			z:3;
			MouseArea{
				anchors.fill:parent;
			}
			Text{
				id:folderlabel;
				anchors.left:parent.left;
				anchors.verticalCenter:parent.verticalCenter;
				width:parent.width;
                font.pixelSize:20;//18;
				font.family: "Nokia Pure Text";
				color:"white";
				elide:Text.ElideRight;
				clip:true;
			}
		}
		Rectangle{
			id:subgrid;
			anchors.top:label.bottom;
			anchors.left:parent.left;
			width:parent.width;
			opacity:parent.opacity;
			color:"black";
			states:[
				State{
					name:"show";
					PropertyChanges {
						target: subgrid;
						height:setHeight(foldergrid.count);
					}
				}
				,
				State{
					name:"noshow";
					PropertyChanges {
						target: subgrid;
						height:0;
					}
				}
			]
			state:"noshow";
			transitions: [
				Transition {
                    from:"noshow";
                    to:"show";
					NumberAnimation{
						target:subgrid;
						property:"height";
						easing.type: Easing.OutExpo;
						duration:folderSizeChangeAnimationDuration;
					}
				}
                ,
                Transition {
                    from:"noshow";
                    to:"show";
                    NumberAnimation{
                        target:subgrid;
                        property:"height";
                        easing.type: Easing.InExpo;
                        duration:folderSizeChangeAnimationDuration;
                    }
                }
			]
			GridView{
				id:foldergrid;
				anchors.fill:parent;
				anchors.bottomMargin:folderBottomPadding;
				anchors.topMargin:folderTopPadding;
				cellWidth:desktopWidth;
				cellHeight:desktopHeight + textHeight;
				clip:true;
				delegate:Component{
					Item{
						width:GridView.view.cellWidth;
						height:GridView.view.cellHeight;
						Image{
							id:icon2;
							anchors.top:parent.top;
							anchors.topMargin:iconTopMargin;
							height:iconHeight;
							width:iconWidth;
							anchors.horizontalCenter:parent.horizontalCenter;
							source:model.icon;
							smooth:true;
						}
						Text{
							anchors.topMargin:iconTopMargin;
							anchors.top:icon2.bottom;
							font.pixelSize:desktopLabelSize + 2;
							font.weight:Font.Light;
							font.family: "Nokia Pure Text";
							color:desktopLabelColor;
							elide:Text.ElideRight;
							anchors.horizontalCenter:parent.horizontalCenter;
							clip:true;
							text:model.name;
						}
						Rectangle{
							id:subshadow;
							anchors.fill:parent;
							color:"black";
							opacity:0.5;
                            visible:submousearea.pressed;
						}
						MouseArea{
                            id:submousearea;
							anchors.topMargin:iconTopMargin;
                            anchors.fill:parent;
							onClicked:{
                                //subgrid.state = "noshow";
									if(model.category === "video"){
										mainpage.addNotification({option: "category_video", value: "%1,%2,%3".arg(model.index).arg(0).arg(0)});
										var page = Qt.createComponent(Qt.resolvedUrl("CategoryPage.qml"));
										pageStack.push(page, {idx: [model.index, 0, 0]});
									}else if(model.category === "show"){
										mainpage.addNotification({option: "category_show", value: "%1,%2,%3".arg(model.index).arg(0).arg(0)});
										var page = Qt.createComponent(Qt.resolvedUrl("ShowCategoryPage.qml"));
										pageStack.push(page, {idx: [model.index, 0, 0]});
									}else if(model.category === "playlist"){
										mainpage.addNotification({option: "category_playlist", value: model.index});
										var page = Qt.createComponent(Qt.resolvedUrl("PlaylistCategoryPage.qml"));
										pageStack.push(page, {index: model.index});
                                    }
							}
						}
					}
				}
				ScrollDecorator{
					opacity:0.5;
					flickableItem:parent;
				}
			}
		}
		Rectangle{
			id:line2;
			anchors.top:subgrid.bottom;
			anchors.left:parent.left;
			width:parent.width;
			height:folderBorderLineWidth;
			opacity:parent.opacity;
			color:"white";
			MouseArea{
				anchors.fill:parent;
			}
		}
		Rectangle{
			opacity:parent.opacity;
			width:parent.width;
			anchors.top:line2.bottom;
			anchors.bottom:parent.bottom;
			anchors.left:parent.left;
			color:"black";
			MouseArea{
				anchors.fill:parent;
				onClicked:{
					subgrid.state = "noshow";
				}
			}
		}
	}

}
