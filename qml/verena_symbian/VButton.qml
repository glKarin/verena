import QtQuick 1.1
import com.nokia.symbian 1.1

ToolButton{
	id: root;

	property string iconSource_2;
	property QtObject platformStyle: VButtonStyle{}

	width: platformStyle.buttonWidth; 
	height: platformStyle.buttonHeight;
	iconSource: __ConvertIconSource(iconSource_2);

	function __ConvertIconSource(is)
	{
		var PREFIX = "image://theme/icon-m-";
		var i = is.indexOf(PREFIX);
		return (i === 0) ? is.substr(PREFIX.length) : is;
	}
}
