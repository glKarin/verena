import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
	id: root

	property Flickable view;
	property bool isHeader: true;
	property int refreshStart:120;
	property int refreshEnd:-20;
	property int theight:60;
	property int max:1;
	property int min:1;
	property string info:qsTr("page");
	signal jump(int page);
	function hide(){
		height = 0;
	}

	width: parent.width;
	height: 0

	Connections {
		target: view
		onContentYChanged: {
			if (isHeader){
				var y = root.y - view.contentY;
				if (view.atYBeginning){
					if ( y > refreshStart ){
						root.height = theight;
					}
				}else{
					if(y < refreshEnd){
						root.height = 0;
					}
				}
			}
		}
	}

	Row{
		anchors.fill:parent;
		spacing:5;
		visible:root.height === root.theight;
		TextField{
			id:textfield;
			placeholderText:root.min + " - " + root.max + "(" + root.info + ")";
			readOnly:root.max <= root.min
			anchors.verticalCenter:parent.verticalCenter;
			width:parent.width - tool.width - search.width - 2 * parent.spacing;
			inputMethodHints:Qt.ImhDigitsOnly;
			validator:IntValidator{
				top:root.max;
				bottom:root.min;
			}
			Keys.onReturnPressed:{
				search.clicked();
			}
			ToolIcon{
				anchors.right:parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				enabled: !textfield.readOnly && textfield.text.length !== 0;
				visible:enabled;
				z:1;
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
			iconSource: "toolbar-search";
			anchors.verticalCenter: parent.verticalCenter;
			enabled: !textfield.readOnly && textfield.text.length !== 0;
			platformStyle: VButtonStyle {
				buttonWidth: buttonHeight; 
			}
			onClicked:{
				if(textfield.text.length !== 0) {
					root.hide();
					var page = parseInt(textfield.text);
					if(page > 0){
						root.jump(page);
					}
				}
			}
		}
		ToolIcon{
			id:tool;
			iconId:  Qt.resolvedUrl("../image/verena-m-close.png");
			anchors.verticalCenter: parent.verticalCenter;
			onClicked:{
				root.hide();
			}
		}
	}
}

