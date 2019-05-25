import com.nokia.meego 1.1

Page{
	id:root;
	property alias show:indicator.visible;
	property alias title:head.title;
	property alias headheight:head.height;
	property alias headbottom:head.bottom;
	property alias extraToolEnabled:head.canShowMessage;
	
	orientationLock: PageOrientation.LockPortrait;

	ViewHead{
        id:head;
        anchors.top:parent.top;
        anchors.left:parent.left;
        anchors.right:parent.right;
		onOpenEgg:{
			devmode.boot();
		}
		onShowMessage:{
			var page = Qt.createComponent(Qt.resolvedUrl("SettingPage.qml"));
			pageStack.push(page);
		}	
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn:parent;
		z:3;
		platformStyle:BusyIndicatorStyle{
			size:"large";
		}
		visible:false;
		running:visible;
	}
}
