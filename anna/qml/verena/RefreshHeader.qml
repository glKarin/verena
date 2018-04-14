import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
	id: root

	property Flickable view;
	property bool isHeader: true;
	property int refreshStart:100;
	property int theight:60;
	signal refresh;
	function hide(){
		height = 0;
	}

	width: parent.width;
	height: 0

	Connections {
		target: view
		onContentYChanged: {
			if (isHeader){
				if (view.atYBeginning){
					var y = root.mapToItem(view, 0, 0).y
					if ( y >= refreshStart ){
						root.height = theight;
					}
				}
			} else {
				if (view.atYEnd){
					var y = root.mapToItem(view, 0, 0).y
					if ( view.height - y >= refreshStart){
						root.height = theight;
					}
				}
			}
		}
	}

	Timer{
		id:timer;
		interval:4000;
		running:root.height === theight;
		onTriggered:{
			root.hide();
		}
	}

    ToolButton{
		id:tool;
		anchors.centerIn:parent;
        iconSource: "toolbar-refresh";
		onClicked:{
			root.hide();
			root.refresh();
		}
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: tool;
					opacity:1.0;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: tool;
					opacity:0.0;
				}
			}
		]
		state:root.height === theight ? "show" : "noshow";
		transitions: [
			Transition {
				NumberAnimation{
					target:parent;
					property:"opacity";
					duration:400;
				}
			}
		]
	}
}
