import VerenaWebKit 1.0
import com.nokia.symbian 1.1
import QtQuick 1.1

Item{
	id:root;
	anchors.fill:parent;
	property alias title:webview.title;
	property alias progress:webview.progress;
	property alias url:webview.url;
	property alias reload:webview.reload;
	property alias stop:webview.stop;
	property alias back:webview.back;
	property alias forward:webview.forward;
	property alias icon:webview.icon;
	/*
	 property alias :webview.;
	 */
	signal linkClicked(url link);
	signal alert(string message);

	Slider{
		id:hslider;
		anchors{
			bottom:parent.bottom;
			left:parent.left;
			right:vslider.left;
		}
		z:1;
		minimumValue:0;
		maximumValue:Math.max(flick.contentWidth - flick.width, 0);
		visible:settingsObject.browserHelper;
		stepSize:1;
		value:flick.contentX;
		height:visible ? 45 : 0;
		onValueChanged:{
			if(pressed){
				flick.contentX = value;
			}
		}
	}

	Slider{
		id:vslider;
		anchors{
			top:parent.top;
			bottom:zoomout.top;
			right:parent.right;
		}
		z:1;
		stepSize:1;
		// inverted:true;
		width:visible ? 45 : 0;
		visible:settingsObject.browserHelper;
		minimumValue:0;
		maximumValue:Math.max(flick.contentHeight - flick.height, 0);
		value:flick.contentY;
		orientation:Qt.Vertical;
		onValueChanged:{
			if(pressed){
				flick.contentY = value;
			}
		}
	}

	VButton{
		id:zoomin;
		anchors{
			right:parent.right;
			bottom:parent.bottom;
		}
		z:1;
		visible:settingsObject.browserHelper;
		platformStyle: VButtonStyle {
			buttonHeight: visible ? 45 : 0;
			buttonWidth: buttonHeight; 
		}
        //iconSource: "image://theme/icon-m-toolbar-down";
        text: "-";
		onClicked:{
			webview.doZoom(0.5, (flick.contentX + flick.width / 2) * 0.5,(flick.contentY + flick.height / 2) * 0.5);
		}
	}

	VButton{
		id:zoomout;
		anchors{
			right:parent.right;
			bottom:zoomin.top;
		}
		visible:settingsObject.browserHelper;
		z:1;
		platformStyle: VButtonStyle {
			buttonHeight: visible ? 45 : 0;
			buttonWidth: buttonHeight; 
		}
        //iconSource: "image://theme/icon-m-toolbar-up";
        text: "+";
		onClicked:{
			webview.doZoom(2, (flick.contentX + flick.width / 2) * 2,(flick.contentY + flick.height / 2) * 2);
		}
	}

	Flickable{
		id:flick;
		anchors.fill:parent;
		anchors.rightMargin:vslider.width;
		anchors.bottomMargin:hslider.height;
		contentWidth: Math.max(width,webview.width);
		contentHeight: Math.max(height,webview.height);
		clip:true;
		VWebView{
			id:webview;
			preferredWidth: flick.width;
			preferredHeight: flick.height;
			settings.autoLoadImages:settingsObject.browserAutoLoadImage;
			settings.offlineStorageDatabaseEnabled :settingsObject.browserHtml5OfflineLocalStorage;
			settings.offlineWebApplicationCacheEnabled :settingsObject.browserHtml5OfflineLocalStorage;
			settings.localStorageDatabaseEnabled :settingsObject.browserHtml5OfflineLocalStorage;
			onLinkClicked:{
				root.linkClicked(link);
			}
			onAlert:{
				root.alert(message);
			}
			onZoomTo: doZoom(zoom,centerX,centerY)
			onContentsSizeChanged: {
				contentsScale = Math.min(1,flick.width / contentsSize.width)
			}
			//onUrlChanged: 
			onLoadStarted: {
				flick.contentX = 0
				flick.contentY = 0
			}
			onDoubleClick: {
				if (!heuristicZoom(clickX,clickY,2.5)) {
					var zf = flick.width / contentsSize.width
					if (zf >= contentsScale)
					zf = 2.0*contentsScale // zoom in (else zooming out)
					doZoom(zf,clickX*zf,clickY*zf)
				}
			}
			function doZoom(zoom,centerX,centerY)
			{
				if (centerX) {
					var sc = zoom*contentsScale;
					scaleAnim.to = sc;
					flickVX.from = flick.contentX
					flickVX.to = Math.max(0,Math.min(centerX-flick.width/2,webview.width*sc-flick.width))
					finalX.value = flickVX.to
					flickVY.from = flick.contentY
					flickVY.to = Math.max(0,Math.min(centerY-flick.height/2,webview.height*sc-flick.height))
					finalY.value = flickVY.to
					quickZoom.start()
				}
			}
		}
		SequentialAnimation {
			id: quickZoom

			PropertyAction {
				target: webview
				property: "renderingEnabled"
				value: false
			}
			ParallelAnimation {
				NumberAnimation {
					id: scaleAnim
					target: webview
					property: "contentsScale"
					easing.type: Easing.Linear
					duration: 200
				}
				NumberAnimation {
					id: flickVX
					target: flick
					property: "contentX"
					easing.type: Easing.Linear
					duration: 200
					from: 0  
					to: 0  
				}
				NumberAnimation {
					id: flickVY
					target: flick
					property: "contentY"
					easing.type: Easing.Linear
					duration: 200
					from: 0  
					to: 0  
				}
			}
			PropertyAction {
				id: finalX
				target: flick
				property: "contentX"
				value: 0  
			}
			PropertyAction {
				id: finalY
				target: flick
				property: "contentY"
				value: 0 
			}
			PropertyAction {
				target: webview
				property: "renderingEnabled"
				value: true
			}
		}

	}
	ScrollDecorator{
		flickableItem:flick;
	}
}
