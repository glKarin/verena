import QtQuick 1.1

Item{
	id:root;
	property alias text:label.text;
	property string pressedTextColor:"#7b797b";
	property string textColor:"#FFFFFF";
	property string backgroundColor:"#211C21";
	property string backgroundColor2:"#000000";
	property string backgroundPressedColor:"#313031";
	property string backgroundPressedColor2:"181818";
	property alias labelSize:label.font.pixelSize;
	property int buttonWidth:160;
	property int buttonHeight:39;

	property int buttonRadius:16;
	property int buttonBorderWidth:1;
    property string buttonBorderColor:"#393839";

	signal clicked;

	height:buttonHeight + buttonBorderWidth * 2;
	width:buttonWidth + buttonBorderWidth * 2;

	Rectangle{
		id:button;
		border.width:buttonBorderWidth;
		height:buttonHeight;
		width:buttonWidth;
		border.color:buttonBorderColor;
		anchors.centerIn:parent;
		radius:buttonRadius;
		smooth:true;
		gradient: Gradient {
			GradientStop {
				id:topG;
                position: 0.0;
                color: mousearea.pressed ? backgroundPressedColor : backgroundColor;
			}
			GradientStop { 
				id:bottomG;
                position: 1.0;
                color: mousearea.pressed ? backgroundPressedColor2 : backgroundColor2;
			}
		}
		Text{
			id:label;
			font.pixelSize:24;
            anchors.centerIn:parent;
            color: mousearea.pressed ? pressedTextColor : textColor;
			font.weight:Font.Bold;
		}
        MouseArea{
            id:mousearea;
            anchors.fill:parent;
			onClicked:{
                root.clicked();
            }
		}
	}
}
