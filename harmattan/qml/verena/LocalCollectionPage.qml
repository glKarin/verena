import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/parserengine.js" as Parser
import "../js/main.js" as Script

VerenaPage{
	id:root;

	title:"<b>" + qsTr("Local Collection") + "</b>";

	QtObject{
		id:qobj;
		property variant videoArray:[];
		property variant showArray:[];
		property variant playlistArray:[];
		property variant userArray:[];
	}

	TabButton{
		id:tabbutton;
		width:parent.width;
		anchors.top:headbottom;
		ButtonRow{
			width:parent.width;
			TabButton{
				width:parent.width/4;
				text:qsTr("Video") + "\n[" + videomodel.count + "]";
				tab:videolist;
			}
			TabButton{
				width:parent.width/4;
				text:qsTr("Show") + "\n[" + showmodel.count + "]";
				tab:showlist;
			}
			TabButton{
				width:parent.width/4;
				text:qsTr("Playlist") + "\n[" + playlistmodel.count + "]";
				tab:playlistlist;
			}
			TabButton{
				width:parent.width/4;
				text:qsTr("User") + "\n[" + usermodel.count + "]";
				tab:userlist;
			}
		}
	}

	TabGroup{
		id:tabgroup;
		anchors.fill:parent;
		anchors.topMargin:tabbutton.height + headheight;
		visible:!root.show;
		currentTab:videolist;
		ListView{
			id:videolist;
			property string order:"collect_time";
			function makeListModel(o){
				if(o){
					order = o;
				}
				qobj.videoArray = qobj.videoArray.sort(function(a, b){
					return parseInt(b[order]) - parseInt(a[order]);
				});
				videomodel.clear();
				qobj.videoArray.forEach(function(e){
					e.collect_time = Qt.formatDate(new Date(parseInt(e.collect_time)), "yyyy-MM-dd");
					videomodel.append(e);
				});
			}
			anchors.fill:parent;
			model:ListModel{id: videomodel}
			clip:true;
			delegate:Component{
				Rectangle{
					height:120;
					width:ListView.view.width;
					color:ListView.isCurrentItem?"lightskyblue":"white";
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							videolist.currentIndex=index;
							mainpage.addNotification({option: "video_detail", value: model.vid, thumbnail: model.thumbnail, title: model.name});
							var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
							pageStack.push(page, {videoid:model.vid});
						}
					}
					Row{
						anchors.fill:parent;
						Image{
							id:image1;
							height:parent.height;
							width:height + 30;
							source:model.thumbnail;
							smooth:true;
							ToolIcon{
								anchors.left:parent.left;
								anchors.top:parent.top;
								width:50;
								height:width;
								iconId: "toolbar-delete";
								onClicked:{
									videolist.currentIndex=index;
									Script.removeCollection('VideoCollection', 'vid', model.vid);
									setMsg(qsTr("Uncollect"));
									qobj.videoArray = Script.makeCollectionList('VideoCollection');
									videolist.makeListModel();
								}
							}
						}
						Column{
							width:parent.width - image1.width;
							height:parent.height;
							Text{
								width:parent.width;
								height:parent.height / 4 * 3;
								color:"black";
								font.pixelSize:22;
								maximumLineCount:3;
								elide:Text.ElideRight;
								text:model.name;
								wrapMode:Text.WrapAnywhere;
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
										clip:true;
										font.pixelSize:20;
										text:model.collect_time;
									}
								}
								Row{
									width:parent.width / 3;
									height:parent.height;
									Image{
										height:parent.height;
										width:height;
										smooth:true;
										source:Qt.resolvedUrl("../image/verena-s-mark.png");
									}
									Text{
										anchors.verticalCenter:parent.verticalCenter;
										width:parent.width - parent.height;
										font.pixelSize:20;
										clip:true;
										text:model.rank;
									}
								}
							}
						}
					}
				}
			}
			section.property: order;
			section.delegate: ListItemHeader {
				text: section;
			}
			FastScroll {
				listView: parent;
			}
			spacing:2;
			ScrollDecorator{
				flickableItem:parent;
			}
		}

		ListView{
			id:showlist;
			property string order:"collect_time";
			function makeListModel(o){
				if(o){
					order = o;
				}
				qobj.showArray = qobj.showArray.sort(function(a, b){
					return parseInt(b[order]) - parseInt(a[order]);
				});
				showmodel.clear();
				qobj.showArray.forEach(function(e){
					e.collect_time = Qt.formatDate(new Date(parseInt(e.collect_time)), "yyyy-MM-dd");
					showmodel.append(e);
				});
			}
			anchors.fill:parent;
			model:ListModel{id: showmodel}
			clip:true;
			spacing:2;
			delegate:Component{
				Rectangle{
					height:150;
					width:ListView.view.width;
					color:ListView.isCurrentItem?"lightskyblue":"white";
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							showlist.currentIndex=index;
							mainpage.addNotification({option: "show_detail", value: model.vid, thumbnail: model.thumbnail, title: model.name});
							var page = Qt.createComponent(Qt.resolvedUrl("ShowDetailPage.qml"));
							pageStack.push(page, {showid:model.vid});
						}
					}
					Row{
						anchors.fill:parent;
						Image{
							id:image2;
							height:parent.height;
							width:height - 20;
							source:model.thumbnail;
							smooth:true;
							ToolIcon{
								anchors.left:parent.left;
								anchors.top:parent.top;
								width:50;
								height:width;
								iconId: "toolbar-delete";
								onClicked:{
									showlist.currentIndex=index;
									Script.removeCollection('ShowCollection', 'vid', model.vid);
									setMsg(qsTr("Uncollect"));
									qobj.showArray = Script.makeCollectionList('ShowCollection');
									showlist.makeListModel();
								}
							}
						}
						Column{
							width:parent.width - image2.width;
							height:parent.height;
							Text{
								width:parent.width;
								height:parent.height / 2;
								color:"black";
								font.pixelSize:24;
								maximumLineCount:2;
								elide:Text.ElideRight;
								text:model.name;
								wrapMode:Text.WrapAnywhere;
							}
							Row{
								width:parent.width;
								height:parent.height / 4;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-calendar.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									clip:true;
									font.pixelSize:24;
									text:model.collect_time;
								}
							}
							Row{
								width:parent.width;
								height:parent.height / 4;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-mark.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									font.pixelSize:24;
									clip:true;
									text:model.rank;
								}
							}
						}
					}
				}
			}
			section.property: order;
			section.delegate: ListItemHeader {
				text: section;
			}
			FastScroll {
				listView: parent;
			}
			ScrollDecorator{
				flickableItem:parent;
			}
		}

		ListView{
			id:playlistlist;
			property string order:"collect_time";
			function makeListModel(o){
				if(o){
					order = o;
				}
				qobj.playlistArray = qobj.playlistArray.sort(function(a, b){
					return parseInt(b[order]) - parseInt(a[order]);
				});
				playlistmodel.clear();
				qobj.playlistArray.forEach(function(e){
					e.collect_time = Qt.formatDate(new Date(parseInt(e.collect_time)), "yyyy-MM-dd");
					playlistmodel.append(e);
				});
			}
			anchors.fill:parent;
			model:ListModel{id: playlistmodel}
			clip:true;
			delegate:Component{
				Rectangle{
					height:150;
					width:ListView.view.width;
					color:ListView.isCurrentItem?"lightskyblue":"white";
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							playlistlist.currentIndex=index;
							mainpage.addNotification({option: "playlist_detail", value: model.vid, thumbnail: model.thumbnail, title: model.name});
							var page = Qt.createComponent(Qt.resolvedUrl("PlaylistDetailPage.qml"));
							pageStack.push(page, {playlistid: model.vid});
						}
					}
					Row{
						anchors.fill:parent;
						Image{
							id:image3;
							height:parent.height;
							width:height + 40;
							source:model.thumbnail;
							smooth:true;
							ToolIcon{
								anchors.left:parent.left;
								anchors.top:parent.top;
								width:50;
								height:width;
								iconId: "toolbar-delete";
								onClicked:{
									playlistlist.currentIndex=index;
									Script.removeCollection('PlaylistCollection', 'vid', model.vid);
									setMsg(qsTr("Uncollect"));
									qobj.playlistArray = Script.makeCollectionList('PlaylistCollection');
									playlistlist.makeListModel();
								}
							}
						}
						Column{
							width:parent.width - image3.width;
							height:parent.height;
							Text{
								width:parent.width;
								height:parent.height / 2;
								color:"black";
								font.pixelSize:24;
								maximumLineCount:2;
								elide:Text.ElideRight;
								text:model.name;
								wrapMode:Text.WrapAnywhere;
							}
							Row{
								width:parent.width;
								height:parent.height / 4;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-calendar.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									clip:true;
									font.pixelSize:24;
									text:model.collect_time;
								}
							}
							Row{
								width:parent.width;
								height:parent.height / 4;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-mark.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									font.pixelSize:24;
									clip:true;
									text:model.rank;
								}
							}
						}
					}
				}
			}
			section.property: order;
			section.delegate: ListItemHeader {
				text: section;
			}
			FastScroll {
				listView: parent;
			}
			spacing:2;
			ScrollDecorator{
				flickableItem:parent;
			}
		}

		ListView{
			id:userlist;
			property string order:"collect_time";
			function makeListModel(o){
				if(o){
					order = o;
				}
				qobj.userArray = qobj.userArray.sort(function(a, b){
					return parseInt(b[order]) - parseInt(a[order]);
				});
				usermodel.clear();
				qobj.userArray.forEach(function(e){
					e.collect_time = Qt.formatDate(new Date(parseInt(e.collect_time)), "yyyy-MM-dd");
					usermodel.append(e);
				});
			}
			anchors.fill:parent;
			model:ListModel{id: usermodel}
			clip:true;
			delegate:Component{
				Rectangle{
					height:120;
					width:ListView.view.width;
					color:ListView.isCurrentItem?"lightskyblue":"white";
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							userlist.currentIndex=index;
							mainpage.addNotification({option: "user_detail", value: model.name, thumbnail: model.thumbnail});
							var page = Qt.createComponent(Qt.resolvedUrl("UserDetailPage.qml"));
							pageStack.push(page, {userid:model.vid, username: model.name});
						}
					}
					Row{
						anchors.fill:parent;
						Image{
							id:image4;
							height:parent.height;
							width:height;
							source:model.thumbnail;
							smooth:true;
							ToolIcon{
								anchors.left:parent.left;
								anchors.top:parent.top;
								width:50;
								height:width;
								iconId: "toolbar-delete";
								onClicked:{
									userlist.currentIndex=index;
									Script.removeCollection('UserCollection', 'vid', model.vid);
									setMsg(qsTr("Uncollect"));
									qobj.userArray = Script.makeCollectionList('UserCollection');
									userlist.makeListModel();
								}
							}
						}
						Column{
							width:parent.width - image4.width;
							height:parent.height;
							Text{
								width:parent.width;
								height:parent.height / 4;
								color:"black";
								font.pixelSize:22;
								elide:Text.ElideRight;
								text: "<b>" + qsTr("User") + ": </b>" + model.name;
							}
							Text{
								width:parent.width;
								height:parent.height / 4;
								color:"black";
								font.pixelSize:24;
								elide:Text.ElideRight;
								text:"<b>ID: </b>" + model.vid;
							}
							Row{
								width:parent.width;
								height:parent.height / 4;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-calendar.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									clip:true;
									font.pixelSize:24;
									text:model.collect_time;
								}
							}
							Row{
								width:parent.width;
								height:parent.height / 4;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-mark.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									font.pixelSize:24;
									clip:true;
									text:model.rank;
								}
							}
						}
					}
				}
			}
			section.property: order;
			section.delegate: ListItemHeader {
				text: section;
			}
			FastScroll {
				listView: parent;
			}
			spacing:2;
			ScrollDecorator{
				flickableItem:parent;
			}
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		Button{
			text:qsTr("Sort by time");
			platformStyle:ButtonStyle{
				fontPixelSize:20;
				buttonHeight:40
				buttonWidth:180;
			}
			onClicked:{
				tabgroup.currentTab.makeListModel("collect_time");
			}
		}
		Button{
			text:qsTr("Sort by rank");
			platformStyle:ButtonStyle{
				fontPixelSize:20;
				buttonHeight:40
				buttonWidth:180;
			}
			onClicked:{
				tabgroup.currentTab.makeListModel("rank");
			}
		}
		/*
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				root.show = true;
				qobj.videoArray = Script.makeCollectionList('VideoCollection');
				qobj.showArray = Script.makeCollectionList('ShowCollection');
				qobj.playlistArray = Script.makeCollectionList('PlaylistCollection');
				qobj.userArray = Script.makeCollectionList('UserCollection');
				videolist.makeListModel();
				showlist.makeListModel();
				playlistlist.makeListModel();
				userlist.makeListModel();
				root.show = false;
			}
		}
		*/
	}
	onStatusChanged: {
		if (status === PageStatus.Active){
			root.show = true;
			qobj.videoArray = Script.makeCollectionList('VideoCollection');
			qobj.showArray = Script.makeCollectionList('ShowCollection');
			qobj.playlistArray = Script.makeCollectionList('PlaylistCollection');
			qobj.userArray = Script.makeCollectionList('UserCollection');
			videolist.makeListModel();
			showlist.makeListModel();
			playlistlist.makeListModel();
			userlist.makeListModel();
			root.show = false;
		}
	}
}

