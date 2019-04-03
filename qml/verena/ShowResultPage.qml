import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

VerenaPage{
	id:root;
	property string keyword:"";

	title: qsTr("Search") + ": \"" + keyword + "\"";

	QtObject{
		id:qobj;
		property int showPage:1;
		property int showMaxPage:0;
		property int count:20;
		property int total:0;
		property string orderby:schemas.showSearchOrderbyList[0];
		property string internalKeyword:root.keyword;
		onTotalChanged:{
			setMsg(qsTr("Search") + " \"" + internalKeyword + "\" : " + qsTr("shows") + ": " + total);
		}

		function reOrder(o){
			showPage = 1;
			orderby = schemas.showSearchOrderbyList[o];
			search();
		}
		function search(o){
			root.show = true;
			//var c = 0;
			if(o === "more"){
				//c = (total - count * showPage) > count ? count : total - count * showPage;
				showPage++;
			}else{
				//c = count;
				showPage = 1;
				listmodel.clear();
			}
			var opt = {
				keyword: internalKeyword,
				unite: 0,
				orderby: orderby,
				//hasvideotype: "正片",
				page: showPage,
				count: count
				//count: c 
			};
			function s(obj){
				if(!onFail(obj))
				{
					total = obj.total;
					var i = total / count;
					showMaxPage = Math.ceil(i);
					Script.makeShowResultList(obj, listmodel);
				}
				root.show = false;
			}
			function f(err){
				root.show = false;
				showMaxPage = 0;
				setMsg(err);
			}
			Script.callAPI("GET", "searches_show_by_keyword", opt, s, f);
		}
	}

	Rectangle{
		id:rect;
		anchors.top:headbottom;
		width:parent.width;
		height: constants.scheme_nav_bar_height;
		z:1;
		ButtonRow{
			anchors.fill:parent;
			Button{
				text:qsTr("View-count");
				onClicked:{
					qobj.reOrder(0);
				}
			}
			Button{
				text:qsTr("View-today-count");
				onClicked:{
					qobj.reOrder(1);
				}
			}
			Button{
				text:qsTr("Release-year");
				onClicked:{
					qobj.reOrder(2);
				}
			}
		}
	}

	ListHeader {
		id:fheader;
		max:100;
		min:10;
		info:qsTr("result");
		anchors.top:rect.bottom;
		view: lst;
		onJump:{
			qobj.count = page;
			qobj.search();
		}
	}
	ListView{
		id:lst;
		anchors.fill:parent;
		anchors.topMargin:headheight + rect.height + fheader.height;
		model:ListModel{id:listmodel}
		header: Component{
			RefreshHeader {
				view: lst;
				onRefresh:{
					qobj.search();
				}
			}
		}
		footer:Component{
			GetMoreFooter{
				visible:qobj.showPage < qobj.showMaxPage;
				width:ListView.view.width;
				onMore:{
					qobj.search("more");
				}
			}
		}
		delegate: Component{
			Rectangle{
				height:200;
				width:ListView.view.width;
				color:ListView.isCurrentItem?"lightskyblue":"white";
				Row{
					anchors.fill:parent;
					Image{
						id:image;
						height:parent.height;
						width:height - 30;
						smooth:true;
						source:model.poster;
					}
					Column{
						width:parent.width - image.width;
						height:parent.height;
						Text{
							width:parent.width;
							height:parent.height/3;
							horizontalAlignment: Text.AlignHCenter;
							verticalAlignment: Text.AlignVCenter;
							font.pixelSize: constants.pixel_xl;
							wrapMode:Text.WrapAnywhere;
							color:"black";
							maximumLineCount:2;
							text:model.name;
						}
						Row{
							width:parent.width;
							height:parent.height / 6;
							Row{
								width:parent.width / 2;
								height:parent.height;
								Image{
									height:parent.height;
									width:height;
									source:Qt.resolvedUrl("../image/verena-s-category.png");
									smooth:true;
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									clip:true;
									font.pixelSize: constants.pixel_large;
									color:"black";
									text:model.showcategory;
								}
							}
							Row{
								width:parent.width / 2;
								height:parent.height;
								Image{
									height:parent.height;
									width:height;
									smooth:true;
									source:Qt.resolvedUrl("../image/verena-s-location.png");
								}
								Text{
									anchors.verticalCenter:parent.verticalCenter;
									width:parent.width - parent.height;
									font.pixelSize: constants.pixel_large;
									clip:true;
									color:"black";
									text:model.area;
								}
							}
						}
						Row{
							width:parent.width;
							height:parent.height / 6;
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
									font.pixelSize: constants.pixel_large;
									color:"black";
									text:model.published;
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
									font.pixelSize: constants.pixel_large;
									clip:true;
									color:"black";
									text:parseFloat(model.score).toFixed(1);
								}
							}
						}
						Row{
							width:parent.width;
							height:parent.height / 6;
							Image{
								height:parent.height;
								width:height;
								source:Qt.resolvedUrl("../image/verena-s-play.png");
								smooth:true;
							}
							Text{
								width:parent.width - parent.height;
								anchors.verticalCenter:parent.verticalCenter;
								font.pixelSize: constants.pixel_large;
								color:"black";
								elide:Text.ElideRight;
								text: model.view_count;
							}
						}
						Text{
							width:parent.width;
							height:parent.height/6;
							color:"black";
							font.pixelSize: constants.pixel_large;
							elide:Text.ElideRight;
							text:formatUpdateAndTotal(model.episode_updated, model.episode_count);
						}
					}
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						lst.currentIndex=index;
						mainpage.addNotification({option: "show_detail", title: model.name, thumbnail: model.poster, value: model.id});
						var page = Qt.createComponent(Qt.resolvedUrl("ShowDetailPage.qml"));
						pageStack.push(page, {showid:model.id});
					}
				}
			}
        }
		clip:true;
		spacing:2;
		visible:!show;
	}

	ScrollDecorator{
		flickableItem:lst;
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
						wrapMode: Text.WordWrap;
            elide:Text.ElideRight;
            font.pixelSize: constants.pixel_xl;
            text: qsTr("Result") + ": " + qobj.total + "   " + qsTr("Limit") + ": " + qobj.count + "   " + qsTr("Page") + ": " + qobj.showPage + "/" + qobj.showMaxPage;
        }
	}
	Component.onCompleted:{
		qobj.search();
	}
}
