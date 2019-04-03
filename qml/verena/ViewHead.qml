import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle{
	id:root;
	property alias title:show.text;
	property alias canShowMessage:tool.enabled;

	signal showMessage;
	signal openEgg;

	height:60;
	z:1;
	color:"pink";
	width:parent.width;

	Image{
		anchors.right:parent.right;
		anchors.bottom:parent.bottom;
		anchors.top:parent.top;
		anchors.rightMargin:-20;
		clip:true;
		smooth:true;
		//anchors.topMargin:2;
		opacity:0.5;
		source: Qt.resolvedUrl("../image/verena_logo.png");
		z:2;
	}

	Text{
		id:show;
		anchors.centerIn:parent;
		width: parent.width;
		height: parent.height;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		maximumLineCount: 2;
		elide: Text.ElideRight;
		wrapMode: Text.WrapAnywhere;
		font.bold: true;
		font.pixelSize: constants.pixel_xl;
		z:3;
		color:"green";
		clip:true;
	}

	ToolIcon{
		id:tool;
		iconId: "toolbar-settings";
		visible:enabled;
		anchors.left:parent.left;
		anchors.verticalCenter:parent.verticalCenter;
		onClicked:{
			root.showMessage();
		}
	}
	MouseArea{
		anchors.left:parent.left;
		anchors.leftMargin:290;
		height:parent.height;
		width:height;
		anchors.top:parent.top;
		onDoubleClicked:{
			root.openEgg();
		}
	}

}
