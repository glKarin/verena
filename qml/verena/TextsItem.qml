import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	objectName: "texts_item";
	width: parent.width;
	height: mainlayout.height;
	clip: true;

	property int horizontalAlignment: Text.AlignLeft;
	property variant nu: false;
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
			font.pixelSize: constants.pixel_medium;
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
			item.text = __makeText(s.text, n, i);
			if(s.pixelSize)
				item.font.pixelSize = s.pixelSize;
			if(s.color)
				item.color = s.color;
			//console.log(s.text);
		}
	}

	function __makeText(text, n, i)
	{
		var nt = typeof(n);
		var s;
		switch(nt)
		{
			case "string":
			s = n + text;
			break;
			case "number":
			s = "" + (n + i) + ", " + text;
			break;
			case "function":
			s = n() + text;
			break;
			default:
			s = n ? ("" + (i + 1) + ", " + text) : text;
			break;
		}
		return s;
	}
}
