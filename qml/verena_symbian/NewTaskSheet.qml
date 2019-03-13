import QtQuick 1.1
import com.nokia.symbian 1.1

VerenaDialog{
	id: root;

	signal requestPause(string vid);
	onAccepted:{
		if(textfield.text.length === 0){
			return;
        }
        //symbian
        var pattern = /^(http:\/\/|https:\/\/)?v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
		var vid = "";
		if (textfield.text.match(pattern)) {
			vid = textfield.text.match(pattern)[2];
		}else{
			vid = textfield.text;
		}
		requestPause(vid);
	}

	content: Column {
		width: constants.max_width
		height: width * 1.2;
		TextField {
			id: textfield;
			width:parent.width;
			focus: true;
			//text:"XOTQ4ODM0MDQw";
			placeholderText: qsTr("Input video ID or URL");
			Keys.onReturnPressed:{
				root.accepted();
				root.close();
			}
		}
		Row{
			width:parent.width;
			height:50;
				Button{
					width:parent.width / 3;
					text:qsTr("Copy");
					onClicked:{
						vut.copyToClipboard(textfield.text);
						textfield.forceActiveFocus();
						textfield.openSoftwareInputPanel();
					}
				}
				Button{
					width:parent.width / 3;
					text:qsTr("Paste");
					onClicked:{
						textfield.paste();
						textfield.forceActiveFocus();
						textfield.openSoftwareInputPanel();
					}
				}
				Button{
					width:parent.width / 3;
					text:qsTr("Clear");
					onClicked:{
						textfield.text = "";
						textfield.forceActiveFocus();
						textfield.openSoftwareInputPanel();
					}
				}
			}
			ListItemHeader{
				text:qsTr("Tips");
				item:tipsrect;
			}
			VerenaRectangle{
				id:tipsrect;
				theight:tips.height;
				Column {
					id:tips;
					width:parent.width;
					visible:parent.fullShow;
					Text{
						font.pixelSize: 20;
						width:parent.width;
						color:"black";
						text: qsTr("Parsing video url from video url or video id of youku that you input.");
						wrapMode:Text.WordWrap;

						font.family: "Nokia Pure Text";
					}
					Text{
						font.pixelSize: 20;
						width:parent.width;
						color:"black";
						text: "<b>" + qsTr("Example:") + "</b>";
						wrapMode:Text.WrapAnywhere;

						font.family: "Nokia Pure Text";
					}
					Text{
						font.pixelSize: 18;
						width:parent.width;
						color:"black";
                        text: qsTr("Video url with schema") + ": \"http://v.youku.com/v_show/id_XOTI2NjYwMDY0==.html\"";
						wrapMode:Text.WrapAnywhere;

						font.family: "Nokia Pure Text";
					}
					Text{
						font.pixelSize: 18;
						width:parent.width;
						color:"black";
                        text: qsTr("or Video url without schema") + ": \"v.youku.com/v_show/id_XOTI2NjYwMDY0==.html\"";
						wrapMode:Text.WrapAnywhere;

						font.family: "Nokia Pure Text";
					}
					Text{
						font.pixelSize: 18;
						width:parent.width;
						color:"black";
						text: qsTr("or Video ID") + ": \"XOTI2NjYwMDY0\"";
						wrapMode:Text.WrapAnywhere;

						font.family: "Nokia Pure Text";
					}
				}
			}
		}

		onStatusChanged: {
			if (status === DialogStatus.Open){
				textfield.forceActiveFocus();
				textfield.openSoftwareInputPanel();
			}
		}
	}

