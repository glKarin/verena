import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id: root;
	objectName: "selection_item";
	width: parent.width;
	height: mainlayout.height;
	clip: true;

	property alias text: title.text;
	property variant subitems: [];
	property variant currentValue: 0;
	signal clicked(variant value);

	Column{
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
			style: "left";
		}

		ButtonColumn{
			id: col;
			width: parent.width;
			spacing: 4;
			exclusive: false;
		}
	}

	Component{
		id: checkbox;
		CheckBox{
			property variant value;
			property bool enabled: true;

			width: parent.width;
			onClicked: {
				col.exclusive = true;
				currentValue = value;
				root.clicked(value);
			}
			MouseArea{
				anchors.fill: parent;
				enabled: !parent.enabled;
			}
		}
	}

	onSubitemsChanged: {
		var items = col.children;
		for(var k in items)
			items[k].destroy();
		col.children = [];

		for(var k in subitems)
		{
			var s = subitems[k];
			var item = checkbox.createObject(col);
			item.text = s.text;
			item.value = s.value;
			if(s.enabled !== undefined)
				item.enabled = s.enabled;
			//console.log(s.text, s.value);
			/*
			item.clicked.connect(function(){
				root.clicked(value);
			});
			*/
		}
		setCurrentChecked(currentValue);
	}

	onCurrentValueChanged: {
		setCurrentChecked(currentValue);
	}

	function setCurrentChecked(v)
	{
		var items = col.children;
		for(var i = 0; i < items.length; i++)
				items[i].checked = false;
		for(var i = 0; i < items.length; i++)
		{
			if(items[i].value == v)
				items[i].checked = true;
		}
	}
}
