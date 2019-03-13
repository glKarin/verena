import QtQuick 1.1
import com.nokia.symbian 1.1

ToolButton{
	id: root;

	property QtObject platformStyle: VButtonStyle{}

	width: platformStyle.buttonWidth; 
	height: platformStyle.buttonHeight;
}
