import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;

	property int index;

	title:"<b>" + qsTr("Playlist Category") + "</b>";

	QtObject{
		id:qobj;
		property string internalCategory:schemas.playlistCategoryList.get(root.index).name;
		property int playlistPage:1;
		property int playlistMaxPage:0;
		property int count:100;
		property int total:0;
		property string orderby:schemas.playlistOrderbyList[0];

		onTotalChanged:{
			setMsg(qsTr("Matched Playlists") + ": " + total);
		}
		function reOrder(o) {
			playlistPage = 1;
			orderby = schemas.playlistOrderbyList[o];
			match();
		}
		function match(o){
			root.show = true;
			if(o === "more"){
				playlistPage++;
			}else{
				playlistPage = 1;
				listmodel.clear();
			}
			var opt = {
				category: internalCategory,
				//period: "today",
				orderby: orderby,
				page: playlistPage,
				count: count
			};
			function s(obj){
				if(!onFail(obj))
				{
					total = obj.total;
					var i = total / count;
					playlistMaxPage = Math.ceil(i);
					Script.makePlaylistResultList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				playlistMaxPage = 0;
				setMsg(err);
			}
			Script.callAPI("GET", "playlists_by_category", opt, s, f);
		}
	}

	Rectangle{
		id:rect;
		anchors.top:headbottom;
		height:100;
		width:parent.width;
		z:1;
		Column{
			anchors.fill:parent;
			ListView{
				id:selectionlist;
				width:parent.width;
				height:50;
				model:schemas.playlistCategoryList;
				delegate:Component{
					Item{
						height:ListView.view.height;
						width:100;
						Rectangle{
							anchors.fill:parent;
							anchors.margins:border.width / 2;
							opacity:0.8;
							radius:10;
							border.width:4;
							border.color:"green";
							color:parent.ListView.isCurrentItem?"lightskyblue":"black";
							Text{
								anchors.centerIn:parent;
								color:parent.parent.ListView.isCurrentItem ? "red" : "white";
								font.pixelSize:24;
								elide:Text.ElideRight;
								text:model.name;
							}
							MouseArea{
								anchors.fill:parent;
								onClicked:{
									selectionlist.currentIndex=index;
									mainpage.addNotification({option: "category_playlist", value: index});
									qobj.internalCategory = model.name;
									qobj.match();
								}
							}
						}
					}
				}
				clip:true;
				spacing:4;
				orientation:ListView.Horizontal;
				Component.onCompleted:{
					selectionlist.currentIndex = root.index;
					selectionlist.positionViewAtIndex(root.index, ListView.Center);
				}
			}

			ButtonRow{
				id:buttonrow;
				width:parent.width;
				height:parent.height - selectionlist.height;
				Button{
					text:qsTr("Published");
					onClicked:{
						qobj.reOrder(0);
					}
				}
				Button{
					id:first;
					text:qsTr("View-count");
					onClicked:{
						qobj.reOrder(1);
					}
				}
			}
		}
	}

	PlaylistListView{
		anchors.topMargin:headheight + rect.height;
		anchors.fill:parent;
		visible:!show;
		max:1500;
		min:20;
		info:qsTr("result");
		model:ListModel{id:listmodel}
		canGetMore: qobj.playlistPage < qobj.playlistMaxPage;
		canRecursion:true;
		onRefresh:{
			qobj.match();
		}
		onMore:{
			qobj.match("more");
		}
		onJump:{
			qobj.count = page;
			qobj.match();
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			id:back;
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
        }
        Text{
            width:parent.width - back.width;
            elide:Text.ElideRight;
            font.pixelSize:24;
            text:"<b>" + qsTr("Result") + ": </b>" + qobj.total + "  <b>" + qsTr("Limit") + ": </b>" + qobj.count +  "  <b>" + qsTr("Page") + ": </b>" + qobj.playlistPage + "/" + qobj.playlistMaxPage;
        }
	}
	Component.onCompleted:{
		qobj.match();
	}
}

