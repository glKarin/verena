import QtQuick 1.1
import com.nokia.symbian 1.1

VerenaDialog {
	id: root

	property alias model:selectionlist.model;
	headtitle:"<b>Verena Developer Mode</b>";
	width:parent.width;
	height:parent.height;
	buttontext:"Reboot!";

	function boot(){
		filemodel.clear();
		var list = developer.getFileList();
		list.forEach(function(e){
			filemodel.append({value: e});
		});
		selectionlist.currentIndex = -1;
		code.text = "";
        code.readOnly = true;
		switches.checked = false;
		flick.contentY = 0;
		qobj.file = "";
		qobj.canWritable = false;
		qobj.hasEdited = false;
		open();
	}

	QtObject{
		id:qobj;
		property bool canWritable:false;
		property bool hasEdited:false;
		property string file:"";
	}

	content:Item {
        height: 400;
		width: parent.width;
		Rectangle{
			id:line;
			anchors.top:parent.top;
			width:parent.width;
			height:5;
			color:"black";
		}
		ListView{
			id:selectionlist;
			anchors.top:line.bottom;
			width:parent.width;
			height:40;
			model:ListModel{id:filemodel;}
			delegate:Component{
				Rectangle{
					height:ListView.view.height;
					width:filename.width;
					color:ListView.isCurrentItem?"white":"black";
					Text{
						id:filename;
						color:parent.ListView.isCurrentItem ? "black" : "white";
						anchors.verticalCenter:parent.verticalCenter;
                        font.pixelSize:18;
						font.family: "Nokia Pure Text";
						elide:Text.ElideLeft;
						text:model.value;
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							selectionlist.currentIndex=index;
							var result = developer.openSourceCode(model.value);
							code.text = "";
							code.readOnly = true;
							switches.checked = false;
							flick.contentY = 0;
							qobj.file = model.value;
							if(result["canReadable"]){
								code.text = result["code"];
								qobj.canWritable = result["canWritable"];
							}else{
								setMsg("File is not allow to read");
								qobj.canWritable = false;
							}
							qobj.hasEdited = false;
						}
					}
				}
			}
			clip:true;
			spacing:5;
			orientation:ListView.Horizontal;
		}
		Rectangle{
			anchors.top:selectionlist.bottom;
			width:parent.width;
			height:5;
			color:"black";
		}
		Flickable{
			id:flick;
			anchors.fill:parent;
			anchors.topMargin:selectionlist.height + line.height * 2;
			anchors.bottomMargin:toolbar.height;
            anchors.rightMargin: vslider.width;
			clip:true;
			contentWidth:width;
			contentHeight:code.height;
			TextArea{
				id:code;
				wrapMode:TextEdit.WrapAnywhere;
				textFormat:TextEdit.AutoText;
                width:parent.width;
				height:text.height;
                onTextChanged:{
					qobj.hasEdited = true;
				}
			}
		}
        Slider{
            id:vslider;
            anchors{
                top:flick.top;
                bottom:flick.bottom;
                right:parent.right;
            }
            z:1;
            stepSize:1;
            width:45;
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
		Rectangle{
			id:toolbar;
			anchors.bottom:parent.bottom;
			width:parent.width;
			height:60;
			color:"black";
			Flickable{
				width:parent.width;
				height:50;
				anchors.centerIn:parent;
				clip:true;
				contentWidth:rowlayout.width;
				contentHeight:height;
				Row{
					id:rowlayout;
					height:parent.height;
					spacing:4;
					Text{
                        font.pixelSize:20;
						font.family: "Nokia Pure Text";
						anchors.verticalCenter:parent.verticalCenter;
						color:qobj.hasEdited ? "red" : "white";
						text:!code.readOnly ? "Editing" : "Edit" + " -> ";
					}
					Switch{
						id:switches;
						enabled:qobj.canWritable;
						anchors.verticalCenter:parent.verticalCenter;
						onCheckedChanged:{
							if(qobj.canWritable){
								code.readOnly = !checked;
								if(!code.readOnly){
									code.cursorPosition = 0;
									code.forceActiveFocus();
                                    code.openSoftwareInputPanel();
								}
							}
						}
					}
                    ToolButton {
                        anchors.verticalCenter:parent.verticalCenter;
                        height:40
                        width:80;
						text:"save";
						enabled:qobj.canWritable;
						onClicked:{
							if(developer.saveSourceCode(qobj.file, code.text)){
								setMsg("File save successful -> " + qobj.file);
								qobj.hasEdited = false;
							}else{
								setMsg("File save fail -> " + qobj.file);
							}
						}
					}
					ToolButton {
                        anchors.verticalCenter:parent.verticalCenter;
                        height:40
                        width:80;
						text:"close";
						enabled:qobj.file.length !== 0;
						onClicked: {
							selectionlist.currentIndex = -1;
							code.text = "";
							code.readOnly = true;
							switches.checked = false;
							flick.contentY = 0;
							qobj.file = "";
							qobj.canWritable = false;
							qobj.hasEdited = false;
						}
                    }
				}
			}
		}
		ScrollDecorator{
			flickableItem:flick;
		}
	}
}
