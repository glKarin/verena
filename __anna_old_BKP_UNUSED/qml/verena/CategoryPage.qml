import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	property variant idx:[];

	title:"<b>" + qsTr("Video Category") + "</b>";

	QtObject{
		id:qobj;
		property int categoryPage:1;
		property int categoryMaxPage:0;
		property int count:20;
		property int total:0;
		property string orderby:schemas.videoCategoryOrderbyList[1];
		property string category;
		property string genre;
		property string period;
		property variant internalIdx:root.idx;
		onTotalChanged:{
			setMsg(qsTr("Matched videos") + ": " + total);
		}
		function getGenre(index, i){
			searchtool.enabled = false;
			genremodel.clear();
			schemas.videoCategoryMap[index].value.forEach(function(element){
				genremodel.append(element);
			});
			genretc.selectedIndex = i;
			searchtool.enabled = true;
		}

		function match(o){
			root.show = true;
			listmodel.clear();
			if(o === "prev"){
				categoryPage --;
			}else if(o === "next"){
				categoryPage++;
			}else if(o !== "this"){
				categoryPage = 1;
			}
			var opt = {
				category: category,
			};
			if(genre !== "全部"){
				opt.genre = genre;
			}
			opt.period = qobj.period;
			opt.orderby = orderby;
			opt.page = categoryPage;
            opt.count = count;
            function s(obj){
                if(!onFail(obj))
                {
                    total = obj.total;
                    var i = total / count;
                    categoryMaxPage = Math.ceil(i);
                    Script.makeVideoResultList(obj, listmodel);
                }
                root.show = false;
            }
			function f(err){
				root.show = false;
				categoryMaxPage = 0;
				setMsg(err);
			}
			Script.callAPI("GET", "videos_by_category", opt, s, f);
		}
		function reOrder(o) {
			orderby = schemas.videoCategoryOrderbyList[o];
			categoryPage = 1;
			match();
		}
	}

	Rectangle{
		id:tumbler;
		anchors.top:headbottom;
        width:parent.width - searchtool.width;
		height:185;
        color:"black";
		z:1;
        VTumbler {
			columns: [categorytc, genretc, periodtc];
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
				id:periodtc;
				label:qsTr("Period");
				items:schemas.periodList;
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
			mainpage.addNotification({option: "category_video", value: "%1,%2,%3".arg(categorytc.selectedIndex).arg(genretc.selectedIndex).arg(periodtc.selectedIndex)});
			qobj.category = schemas.videoCategoryMap[categorytc.selectedIndex].name;
			qobj.genre = schemas.videoCategoryMap[categorytc.selectedIndex].value[genretc.selectedIndex].value;
			qobj.period = schemas.periodList.get(periodtc.selectedIndex).name;
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
					qobj.reOrder(1);
				}
			}
			Button{
				text:qsTr("Published");
				onClicked:{
					qobj.reOrder(0);
				}
			}
			Button{
				text:qsTr("Comment-count");
				onClicked:{
					qobj.reOrder(2);
				}
			}
			Button{
				text:qsTr("Favorite-count");
				onClicked:{
					qobj.reOrder(5);
				}
			}
		}
	}

	VideoListView{
		id:lst;
		anchors.fill:parent;
		anchors.topMargin:headheight + rect.height + tumbler.height;
		model:ListModel{id:listmodel}
		max:qobj.categoryMaxPage;
		visible:!show;
		onRefresh:{
			qobj.match("this");
		}
		onJump:{
			qobj.categoryPage = page;
			qobj.match("this");
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
        ToolButton{
            iconSource: "toolbar-previous";
			enabled:qobj.categoryPage > 1;
			onClicked:{
				qobj.match("prev");
			}
		}
        ToolButton{
            iconSource: "toolbar-next";
			enabled:qobj.categoryPage < qobj.categoryMaxPage;
			onClicked:{
				qobj.match("next");
			}
        }
			Text{
                width:parent.width/4;
                //elide:Text.ElideRight;
                font.pixelSize:16;
                color:"white";
				font.family: "Nokia Pure Text";
				text:qobj.categoryPage + "/" + qobj.categoryMaxPage;
            }
	}
	Component.onCompleted:{
		categorymodel.clear();
		schemas.videoCategoryMap.forEach(function(k){
			categorymodel.append({value: k.name});
		});
		if(!Array.isArray(qobj.internalIdx) || qobj.internalIdx.length < 3){
			return;
		}
		categorytc.selectedIndex = qobj.internalIdx[0];
		qobj.getGenre(qobj.internalIdx[0], qobj.internalIdx[1]);
		qobj.category = schemas.videoCategoryMap[qobj.internalIdx[0]].name;
		qobj.genre = schemas.videoCategoryMap[qobj.internalIdx[0]].value[qobj.internalIdx[1]].value;
		qobj.period = schemas.periodList.get(qobj.internalIdx[2]).name;
		periodtc.selectedIndex = qobj.internalIdx[2];
		qobj.match();
	}
}
