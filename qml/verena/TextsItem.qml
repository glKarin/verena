import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	objectName: "texts_item";
	width: parent.width;
	height: mainlayout.height;
	clip: true;

	property int horizontalAlignment: Text.AlignLeft;
	property bool nu: false;
	property alias text: title.text;
	property variant texts: [];
	signal clicked(string link);

	Column {
		id: mainlayout;
		anchors{
			top: parent.top;
			left: parent.left;
			right: parent.right;
		}
		width: parent.width;
		spacing: 8;

		LineText{
			id: title;
			anchors.horizontalCenter: parent.horizontalCenter;
		}

		Column{
			id: col;
			width: parent.width;
			spacing: 4;
		}
	}

	Component{
		id: textitem;
		Text{
			font.pixelSize: 18;
			width: parent.width;
			color: "black";
			wrapMode: Text.WordWrap;
			horizontalAlignment: root.horizontalAlignment;
			onLinkActivated: {
				root.clicked(link);
			}
		}
	}

	onTextsChanged: {
		fillTextList(texts, nu);
	}

	onNuChanged: {
		fillTextList(texts, nu);
	}

	function fillTextList(ts, n)
	{
		var items = col.children;
		for(var k in items)
			items[k].destroy();
		col.children = [];

		if(!ts)
			return;

		for(var i = 0; i < ts.length; i++)
		{
			var s = ts[i];
			var item = textitem.createObject(col);
			item.text = n ? ("" + (i + 1) + ", " + s.text) : s.text;
			if(s.pixelSize)
				item.font.pixelSize = s.pixelSize;
			if(s.color)
				item.color = s.color;
			//console.log(s.text);
		}
	}
}
