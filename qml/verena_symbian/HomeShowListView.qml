import QtQuick 1.1
import com.nokia.symbian 1.1

Rectangle{
	id:root;

	property alias model:view.model;

	width:parent.width;
	height: 240;

	Column{
		anchors.fill:parent;
		ListView{
			id:view;
			width:parent.width;
			height:parent.height - line.height;
			delegate: Component{
				ShowDelegateItem{
					viewItem: view;
					height: ListView.view.height;
					width:height - 40;
					current: ListView.isCurrentItem;
				}
			}
			clip:true;
			spacing:2;
			orientation:ListView.Horizontal;
		}

		Rectangle{
			id:line;
			width:parent.width;
			height:5;
			color:"orange";
		}

	}

}
