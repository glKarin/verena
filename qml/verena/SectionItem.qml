import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	objectName: "section_item";
	width: parent.width;
	height: mainlayout.height;

	property alias text: title.text;
	property alias content: rect.children;

	Column {
		id: mainlayout;
		anchors{
			top: parent.top;
			left: parent.left;
			right: parent.right;
		}
		width: parent.width;
		spacing: 8;

		ListItemHeader{
			id: title;
			item: rect;
		}
		VerenaRectangle{
			id: rect;
			theight: childrenRect.height;
			width: parent.width;
			onFullShowChanged: {
				for(var i = 0; i < children.length; i++)
					children[i].visible = fullShow;
			}
		}
	}
}
