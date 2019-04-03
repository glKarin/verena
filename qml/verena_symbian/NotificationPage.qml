import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id:root;
	anchors.fill:parent;
	property alias model:mainlist.model;
	/*
	 property int notificationAreaTopMargin:4;
	 property int notificationButtonWidth:160;
	 property int notificationButtonHeight:39;
	 property int notificationButtonTopMargin:8;
	 property int notificationButtonBottomMargin:9;
	 property int notificationButtonRightMargin:14;
	 property real clearButtonReactiveTopMargin:4.5;
	 property real clearButtonReactiveBottomMargin:16.5;
	 property int itemIconTopMargin:0;
	 property int itemIconBottomMargin:0;
	 property int itemTimestampTopMargin:4;
	 property int itemSeparatorLeftMargin:4;
	 property int itemSeparatorRightMargin:4;
	 property int itemSeparatorBottomMargin:0;
	 */
	 property int clearAnimationDuration:200;
	 property int clearButtonWidth:120;//160;
	 property int clearButtonHeight:23;//31;
	 property int clearButtonTopMargin:12;
	 property int clearButtonBottomMargin:0;
	 property int clearButtonLeftMargin:6;
	 property int clearButtonRightMargin:10;//14;
	 property string clearButtonTextColor:"#FFFFFF";
	 property string clearButtonPressedTextColor:"#797979";
	 property int notificationLayoutSpacing:5;//8;
	 property string itemFooterColor:"#808080";
	 property int itemFooterSize:12;//16;
	 property string itemTimestampColor:"#808080";
	 property int itemTimestampSize:12;//16;
	 property string itemTitleColor:"#FFFFFF";
	 property int itemTitleSize:16;//22;
	 property int itemSeparatorTopMargin:2;//4;
	 property string itemSeparatorColor:"#808080";
	 property int itemIconLeftMargin:1;//2;
	 property int itemIconRightMargin:12;//16;
	 property int itemIconWidth:48;//64;
	 property int itemIconHeight:48;//64;
	 property int itemImageWidth:157;//210;
	 property int itemImageHeight:89;//120;
	 property int itemBigImageWidth:126;//168;
	 property int itemBigImageHeight:126;//168;
	 property int itemSmallImageWidth:90;//120;
	 property int itemSmallImageHeight:90;//120;
	 property int dayLabelHeight:34;//46;
	 property string dayLabelColor:"#FFFFFF";
	 property int dayLabelFontSize:30;//40;
	 property int dateLabelHeight:29;//40;
	 property string dateLabelColor:"#808080";
	 property int dateLabelFontSize:24;//32;
	 property int itemLabelMaxLineCount:5;
	 property string lineColor:"#4B4A4B";
	 property string backgroundColor:"#181B18";
	 property string notificationsTextColor:"#626262";

	function getImageWidth(o){
		if(o === "user_detail" || o === "user_video" || o === "user_playlist"){
			return itemSmallImageWidth;
		}else if(o === "video_detail" || o === "playlist_detail"){
			return itemImageWidth;
		}else if(o === "show_detail"){
			return itemBigImageWidth;
		}else{
			return itemIconWidth;
		}
	}

	function getImageHeight(o){
		if(o === "user_detail" || o === "user_video" || o === "user_playlist"){
			return itemSmallImageHeight;
		}else if(o === "video_detail" || o === "playlist_detail"){
			return itemImageHeight;
		}else if(o === "show_detail"){
			return itemBigImageHeight;
		}else{
			return itemIconHeight;
		}
	}

	Flickable{
		id:flick;
		anchors.fill:parent;
		contentWidth:parent.width;
		contentHeight:mainlayout.height;
		clip:true;
		Column{
			id:mainlayout;
			width:parent.width;
			spacing:notificationLayoutSpacing;
			Item{
				width:parent.width;
				height:126;///////170 - 36 = 134 - 8
				Column{
					width:parent.width;
					anchors.left:parent.left;
					anchors.verticalCenter:parent.verticalCenter;
					Item{
						width:parent.width;
						height:dayLabelHeight;
						Text{
							anchors.verticalCenter:parent.verticalCenter;
							anchors.left:parent.left;
							color:dayLabelColor;
							font.pixelSize:dayLabelFontSize;
							text:Qt.formatDateTime(new Date(), "dddd");
						}
					}
					Item{
						width:parent.width;
						height:dateLabelHeight;
						Text{
							anchors.verticalCenter:parent.verticalCenter;
							anchors.left:parent.left;
							color:dateLabelColor;
							font.pixelSize:dateLabelFontSize;
							text:Qt.formatDateTime(new Date(), "MMMM d, yyyy");
							font.weight:Font.Light;
						}
					}
				}
			}
			Rectangle{
				width:parent.width - clearButtonRightMargin;
				height:2;
				color:lineColor;
				visible:mainlist.model && mainlist.model.count > 0;
			}
			Item{
				width:parent.width;
				height:48; //////64 - 8 - 8
				visible:mainlist.model && mainlist.model.count > 0;
				Text{
					anchors.left:parent.left;
					anchors.verticalCenter:parent.verticalCenter;
					text:qsTr("Notifications");
					font.weight:Font.Bold;
					color:notificationsTextColor;
					font.pixelSize:20;
				}
				VTHomeButton{
					anchors.verticalCenter:parent.verticalCenter;
					anchors.right:parent.right;
					anchors.rightMargin:clearButtonRightMargin;
					text:qsTr("Clear");
					labelSize: 20;
					textColor: clearButtonTextColor;
					pressedTextColor: clearButtonPressedTextColor;
					backgroundColor:"#525152";
					backgroundColor2:"#181818";
					backgroundPressedColor:"#214563";
					backgroundPressedColor2:"#083C63";
					buttonWidth: clearButtonWidth;
					buttonHeight: clearButtonHeight;
					onClicked:{
						if(mainlist.model){
							mainlist.model.clear();
						}
					}
				}
			}
			Column{
				width:parent.width;
				visible:mainlist.model && mainlist.model.count > 0;
				clip:true;
				add:Transition {
					SpringAnimation {
						property: "y";
						easing.type: Easing.OutQuint;
						duration:clearAnimationDuration;
						spring: 5; 
						damping: 0.3;
					}
				}
				move:Transition {
					SpringAnimation {
						property: "y";
						easing.type: Easing.OutQuint;
						spring: 5;
						damping: 0.3;
						duration:clearAnimationDuration;
					}
					/*
					 duration: 400;
					 y-translation-easing-curve: overshotbezier;
					 opacity-easing-curve: overshotbezier;
					 */
				}
				Repeater{
					id:mainlist;
					Rectangle{
						width:mainlayout.width;
						height:Math.max(icon.height + 2 * notificationLayoutSpacing, sublayout.height + 2 * notificationLayoutSpacing);
                        color:mousearea.pressed ? backgroundColor : "black";
						radius:10;
						smooth:true;
						Image{
							id:icon;
							source:model.icon;
							smooth:true;
							//anchors.verticalCenter:parent.verticalCenter;
							anchors{
								top:parent.top;
								topMargin:notificationLayoutSpacing;
								left:parent.left;
								leftMargin:itemIconLeftMargin;
							}
							width:getImageWidth(model.option);
							height:getImageHeight(model.option);
							fillMode: Image.PreserveAspectCrop;
							clip: true;
						}
						Column{
							id:sublayout;
							anchors{
								top:parent.top;
								topMargin:notificationLayoutSpacing;
								left:icon.right;
								leftMargin:itemIconRightMargin;
								right:parent.right;
								rightMargin:itemIconRightMargin;
							}
							spacing:itemSeparatorTopMargin;
							Text{
								width:parent.width;
								color:itemTitleColor;
								font.weight:Font.Bold;
								font.pixelSize:itemTitleSize;
								maximumLineCount:5;
								elide:Text.ElideRight;
								text:model.content;
								wrapMode:Text.WordWrap;
							}
							Text{
								width:parent.width;
								clip:true;
								color:itemFooterColor;
								font.pixelSize:itemFooterSize;
								text:model.title;
							}
							Text{
								width:parent.width;
								clip:true;
								color:itemFooterColor;
								font.pixelSize:itemFooterSize;
								text:model.timestamp;
							}
						}
						MouseArea{
                            id:mousearea;
                            anchors.fill:parent;
                            onClicked:{
                                var arg = ({});
                                var page = "";
                                if(model.option === "search_video"){
                                    arg = {keyword: model.what};
                                    page = "ResultPage.qml";
                                }else if(model.option === "search_tag"){
                                    arg = {tag: model.what};
                                    page = "TagVideoResultPage.qml";
                                }else if(model.option === "search_show"){
                                    arg = {keyword: model.what};
                                    page = "ShowResultPage.qml";
                                }else if(model.option === "user_detail"){
                                    arg = {username: model.what};
                                    page = "UserDetailPage.qml";
                                }else if(model.option === "user_video"){
                                    arg = {username: model.what};
                                    page = "UserVideoPage.qml";
                                }else if(model.option === "user_video"){
                                    arg = {username: model.what};
                                    page = "UserVideoPage.qml";
                                }else if(model.option === "user_playlist"){
                                    arg = {username: model.what};
                                    page = "UserPlaylistPage.qml";
                                }else if(model.option === "category_video"){
                                    arg = {idx: model.what.split(",")};
                                    page = "CategoryPage.qml";
                                }else if(model.option === "category_show"){
                                    arg = {idx: model.what.split(",")};
                                    page = "ShowCategoryPage.qml";
                                }else if(model.option === "category_playlist"){
                                    arg = {index: model.what};
                                    page = "PlaylistCategoryPage.qml";
                                }else if(model.option === "video_detail"){
                                    arg = {videoid: model.what};
                                    page = "DetailPage.qml";
                                }else if(model.option === "show_detail"){
                                    arg = {showid: model.what};
                                    page = "ShowDetailPage.qml";
                                }else if(model.option === "playlist_detail"){
                                    arg = {playlistid: model.what};
                                    page = "PlaylistDetailPage.qml";
                                }else if(model.option === "download_success"){
                                    arg = {gowhere: model.what};
                                    page = "DownloadPage.qml";
                                }else if(model.option === "download_fail"){
                                    arg = {gowhere: model.what};
                                    page = "DownloadPage.qml";
                                }
                                var comp = Qt.createComponent(Qt.resolvedUrl(page));
                                pageStack.push(comp, arg);
                            }
							onPressAndHold:{
								mainlist.model.remove(index);
							}
						}
					}
				}
			}
		}
	}
	ScrollDecorator{
		opacity:0.5;
		flickableItem:flick;
	}
}
