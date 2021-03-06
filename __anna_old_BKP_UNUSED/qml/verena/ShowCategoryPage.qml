import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;

	property variant idx:[];

	title:"<b>" + qsTr("Show Category") + "</b>";

	QtObject{
		id:qobj;
		property string category;
		property string genre;
		property string area;
		property variant internalIdx:root.idx;
		property int showCategoryPage:1;
		property int showCategoryMaxPage:0;
		property int count:20;
		property int total:0;
		property string orderby:schemas.showCategoryOrderbyList[0];

		onTotalChanged:{
            setMsg(qsTr("Matched shows") + ": " + total);
		}
		function reOrder(o) {
			showCategoryPage = 1;
			orderby = schemas.showCategoryOrderbyList[o];
			match();
		}
		function getGenre(index, i){
			searchtool.enabled = false;
			genremodel.clear();
			schemas.showCategoryMap[index].value.forEach(function(element){
				genremodel.append(element);
			});
			genretc.selectedIndex = i;
			searchtool.enabled = true;
		}

		function match(o){
			root.show = true;
			listmodel.clear();
			if(o === "prev"){
				showCategoryPage --;
			}else if(o === "next"){
				showCategoryPage++;
			}else if(o !== "this"){
				showCategoryPage = 1;
			}
			var opt = {
				category: category
			};
			if(genre !== "全部"){
				opt.genre = genre;
			}
			if(area !== "全部"){
				opt.area = area;
			}
			opt.orderby = orderby;
			opt.page = showCategoryPage;
            opt.count = count;
            function s(obj){
                if(!onFail(obj))
                {
                    total = obj.total;
                    var i = total / count;
                    showCategoryMaxPage = Math.ceil(i);
                    Script.makeShowResultList_2(obj, listmodel);
                }
                root.show = false;
            }
			function f(err){
				root.show = false;
				showCategoryMaxPage = 0;
				setMsg(err);
			}
			Script.callAPI("GET", "shows_by_category", opt, s, f);
		}
	}

	Rectangle{
		id:tumbler;
		anchors.top:headbottom;
        width:parent.width - searchtool.width;
        color:"black";
		height:185;
		z:1;
        VTumbler {
			columns: [categorytc, genretc, areatc];
			TumblerColumn {
				id:categorytc;
				label:qsTr("Category");
				items:ListModel{id:categorymodel}
				selectedIndex: 0;
				onSelectedIndexChanged:{
					qobj.getGenre(selectedIndex, 0);
				}
			}

			TumblerColumn {
				id:genretc;
				label:qsTr("Genre");
				items:ListModel{id:genremodel}
				selectedIndex: 0;
				onSelectedIndexChanged:{
					if(selectedIndex === -1){
						selectedIndex = 0;
					}
				}
			}

			TumblerColumn {
				id:areatc;
				label:qsTr("Area");
				items:schemas.areaList;
				selectedIndex: 0;
			}
		}
	}
    ToolButton{
        id:searchtool;
        iconSource: "toolbar-search";
        anchors.right:parent.right;
		anchors.verticalCenter: tumbler.verticalCenter;
		z:1;
		onClicked:{
			mainpage.addNotification({option: "category_show", value: "%1,%2,%3".arg(categorytc.selectedIndex).arg(genretc.selectedIndex).arg(areatc.selectedIndex)});
			qobj.category = schemas.showCategoryMap[categorytc.selectedIndex].name;
			qobj.genre = schemas.showCategoryMap[categorytc.selectedIndex].value[genretc.selectedIndex].value;
			qobj.area = schemas.areaList.get(areatc.selectedIndex).value;
			qobj.match();
		}
	}
	Rectangle{
		id:rect;
		anchors.top:tumbler.bottom;
		height:50;
		width:parent.width;
		z:1;
		ButtonRow{
			id:buttonrow;
			anchors.fill:parent;
			Button{
				id:first;
				text:qsTr("View-count");
				onClicked:{
					qobj.reOrder(0);
				}
			}
			Button{
				text:qsTr("Updated");
				onClicked:{
					qobj.reOrder(8);
				}
			}
			Button{
				text:qsTr("Release-date");
				onClicked:{
					qobj.reOrder(6);
				}
			}
			Button{
				text:qsTr("Favorite-count");
				onClicked:{
					qobj.reOrder(3);
				}
			}
		}
	}

	ListHeader {
		id:fheader;
		max:qobj.showCategoryMaxPage;
		anchors.top:rect.bottom;
		view: gridview;
		onJump:{
			qobj.showCategoryPage = page;
			qobj.match("this");
		}
	}
	GridView{
		id:gridview;
		anchors.fill:parent;
		anchors.topMargin:headheight + rect.height + tumbler.height + fheader.height;
		model:ListModel{id:listmodel}
		header: Component{
			RefreshHeader {
				view: gridview;
				onRefresh:{
					fheader.hide();
					qobj.match("this");
				}
				onHeightChanged:{
					if(height === 0){
						gridview.positionViewAtBeginning();
					}
				}
			}
		}
		delegate: Component{
			Rectangle{
				width:gridview.cellWidth;
				height:gridview.cellHeight;
				color:GridView.isCurrentItem?"lightskyblue":"white";
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						gridview.currentIndex = index;
						mainpage.addNotification({option: "show_detail", title: model.name, thumbnail: model.poster, value: model.id});
						var page = Qt.createComponent(Qt.resolvedUrl("ShowDetailPage.qml"));
						pageStack.push(page, {showid:model.id});
					}
				}
				Column{
					anchors.fill:parent;
					Image{
						height:parent.height/3*2;
						width:parent.width;
						source:model.poster;
						smooth:true;
					}
					Text{
						width:parent.width;
						height:parent.height/6;
						color:"black";
						font.family: "Nokia Pure Text";
                        font.pixelSize:16;
						//elide:Text.ElideRight;
						text:model.name;
						wrapMode:Text.WordWrap;
					}
					Button{
						width:parent.width;
						height:parent.height/6;
						enabled:model.last_play_video_id !== "";
						text:formatUpdateAndTotal(model.episode_updated, model.episode_count);
						onClicked:{
							gridview.currentIndex = index;
							mainpage.addNotification({option: "video_detail", title: "节目-%1 最近更新".arg(model.name), value: model.last_play_video_id});
							var page = Qt.createComponent(Qt.resolvedUrl("DetailPage.qml"));
							pageStack.push(page, {videoid:model.last_play_video_id});
						}
					}
				}
			}
		}
		clip:true;
		cellHeight:300;
		cellWidth:parent.width/2;
		visible:!show;
	}

	ScrollDecorator{
		flickableItem:gridview;
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-search";
			onClicked:{
				var page = Qt.createComponent(Qt.resolvedUrl("SearchPage.qml"));
				pageStack.push(page);
			}
		}
        ToolButton{
            iconSource: "toolbar-previous";
			enabled:qobj.showCategoryPage > 1;
			onClicked:{
				qobj.match("prev");
			}
		}
        ToolButton{
            iconSource: "toolbar-next";
			enabled:qobj.showCategoryPage < qobj.showCategoryMaxPage;
			onClicked:{
				qobj.match("next");
			}
        }
            Text{
                width:parent.width/5;
                //elide:Text.ElideRight;
                font.pixelSize:16;
                color:"white";
				font.family: "Nokia Pure Text";
				text:qobj.showCategoryPage + "/" + qobj.showCategoryMaxPage;
            }
	}
	Component.onCompleted:{
		categorymodel.clear();
		schemas.showCategoryMap.forEach(function(k){
			categorymodel.append({value: k.name});
		});
		if(!Array.isArray(qobj.internalIdx) || qobj.internalIdx.length < 3){
			return;
		}
		categorytc.selectedIndex = qobj.internalIdx[0];
		qobj.getGenre(qobj.internalIdx[0], qobj.internalIdx[1]);
		areatc.selectedIndex = qobj.internalIdx[2];
		qobj.category = schemas.showCategoryMap[qobj.internalIdx[0]].name;
		qobj.genre = schemas.showCategoryMap[qobj.internalIdx[0]].value[qobj.internalIdx[1]].value;
		qobj.area = schemas.areaList.get(qobj.internalIdx[2]).value;
		qobj.match();
	}
}

