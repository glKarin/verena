import QtQuick 1.1
import com.nokia.symbian 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;

	title: qsTr("Search");

	QtObject{
		id:qobj;

		function getTopKeyword(p){
			root.show = true;
			listmodel.clear();
			var opt = {
				count: 20,
				period: p
			};
			function s(obj){
				if(!onFail(obj))
				{
					Script.makeTopKeywordList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				setMsg(err);
			}
			Script.callAPI("GET", "searches_keyword_top", opt, s, f);
		}

	}

	Rectangle{
		id:rect;
		width:parent.width;
		height:160;
		anchors.top:headbottom;
		z:1;

		color: "black";
		Column{
			anchors.fill:parent;
			Row{
				width:parent.width;
				height:60;
				spacing:5;
				TextField{
					id:textfield;
					placeholderText:qsTr("Input keyword");
					width:parent.width - search.width - parent.spacing;
					inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase;
					platformRightMargin: clear.width;
					Keys.onReturnPressed:{
						search.clicked();
					}
					ToolIcon{
						id:clear;
						width:45;
						anchors.right:parent.right;
						anchors.verticalCenter: parent.verticalCenter;
						enabled:textfield.text.length !== 0;
						visible:enabled;
						z:2;
						iconSource:Qt.resolvedUrl("../image/verena-m-clear.png");
						onClicked: {
							textfield.text="";
							textfield.forceActiveFocus();
							textfield.openSoftwareInputPanel();
						}
					}
				}
				VButton{
					id:search;
					platformStyle: VButtonStyle {
						buttonWidth: buttonHeight; 
					}
					iconSource: "toolbar-search";
					enabled:textfield.text.length !== 0;
					onClicked:{
						if(textfield.text.length !== 0) {
							Script.removeCollection('KeywordHistory', 'keyword', textfield.text);
							Script.addCollection('KeywordHistory', [textfield.text]);
							Script.makeListModel('KeywordHistory', listmodel);
							if(videosearch.checked) {
								mainpage.addNotification({option: "search_video", value: textfield.text});
								var page = Qt.createComponent(Qt.resolvedUrl("ResultPage.qml"));
								pageStack.push(page, {keyword:textfield.text});
                            } else if(tagsearch.checked) {
                                var arr = textfield.text.trim().split(/\s+/);
                                var tag = arr.join(",");
                                mainpage.addNotification({option: "search_tag", value: tag});
                                var page = Qt.createComponent(Qt.resolvedUrl("TagVideoResultPage.qml"));
                                pageStack.push(page, {tag:tag});
                            } else if(showsearch.checked) {
								mainpage.addNotification({option: "search_show", value: textfield.text});
								var page = Qt.createComponent(Qt.resolvedUrl("ShowResultPage.qml"));
								pageStack.push(page, {keyword:textfield.text});
							} else if(usersearch.checked) {
								mainpage.addNotification({option: "user_detail", value: textfield.text});
								var page = Qt.createComponent(Qt.resolvedUrl("UserDetailPage.qml"));
								pageStack.push(page, {username:textfield.text});
							}
						}
					}
				}
			}
			ButtonRow{
				width:parent.width;
				height:50;
				CheckBox{
					id:videosearch;
                    width:parent.width/4;
                    text:qsTr("Video");
					onClicked:{
						textfield.forceActiveFocus();
						textfield.openSoftwareInputPanel();
					}
				}
                CheckBox{
                    id:tagsearch;
                    width:parent.width/4;
                    text:qsTr("Tag");
                    onClicked:{
                        textfield.forceActiveFocus();
                        textfield.openSoftwareInputPanel();
                    }
                }
				CheckBox{
					id:showsearch;
                    width:parent.width/4;
                    text:qsTr("Show");
					onClicked:{
						textfield.forceActiveFocus();
						textfield.openSoftwareInputPanel();
					}
				}
				CheckBox{
					id:usersearch;
                    width:parent.width/4;
                    text:qsTr("User");
					onClicked:{
						textfield.forceActiveFocus();
						textfield.openSoftwareInputPanel();
					}
				}
			}
			ButtonRow{
				id:buttonrow;
				width:parent.width;
				Button{
					id:first;
					text:qsTr("History");
					onClicked:{
						Script.makeListModel('KeywordHistory', listmodel);
					}
				}
				Button{
					text:qsTr("Today");
					onClicked:{
						qobj.getTopKeyword("today");
					}
				}
				Button{
					text:qsTr("Week");
					onClicked:{
						qobj.getTopKeyword("week");
					}
				}
				Button{
					text:qsTr("Month");
					onClicked:{
						qobj.getTopKeyword("month");
					}
				}
			}
		}
	}
	GridView{
		id:gridview;
		anchors.fill:parent;
		anchors.topMargin:headheight + rect.height;
		model:ListModel{id: listmodel}
		delegate: Component{
			Item{
				width:GridView.view.cellWidth;
				height:GridView.view.cellHeight;
				Text{
					anchors.left:parent.left;
					anchors.verticalCenter:parent.verticalCenter;
					width:parent.width;
					clip:true;
					color:"white";
					font.pixelSize:18;
					elide:Text.ElideRight;
                    text:model.keyword;

					font.family: "Nokia Pure Text";
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						gridview.currentIndex = index;
						textfield.text = model.keyword;
						search.clicked();
						buttonrow.checkedButton = first;
					}
					onPressAndHold:{
						if(buttonrow.checkedButton === first){
							Script.removeCollection('KeywordHistory', 'keyword', model.keyword);
							Script.makeListModel('KeywordHistory', listmodel);
						}
					}
				}
			}
		}
		cellHeight:50;
		cellWidth:parent.width/2;
		visible:!show;
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
			height: parent.height;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			maximumLineCount: 2;
			elide:Text.ElideRight;
			font.pixelSize:16;
			text:buttonrow.checkedButton === first ? qsTr("Press and hold item to remove") : "";

			color: "white";
			font.family: "Nokia Pure Text";
		}
	}

	onStatusChanged: {
		if (status === PageStatus.Active){
			textfield.forceActiveFocus();
			textfield.openSoftwareInputPanel();
		}
	}
	Component.onCompleted:{
		Script.makeListModel('KeywordHistory', listmodel);
	}
}
