import QtQuick 1.1
import com.nokia.meego 1.1

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
		height: 500;
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
						font.pixelSize:22;
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
						font.pixelSize:24;
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
									code.platformOpenSoftwareInputPanel();
								}
							}
						}
					}
					Button {
						anchors.verticalCenter:parent.verticalCenter;
						platformStyle:ButtonStyle{
							fontPixelSize:20;
							buttonHeight:40
							buttonWidth:80;
						}
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
						platformStyle:ButtonStyle{
							fontPixelSize:20;
							buttonHeight:40
							buttonWidth:80;
						}
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
					Text{
						font.pixelSize:24;
						anchors.verticalCenter:parent.verticalCenter;
						color:switches2.checked ? "red" : "white";
						text:switches2.checked ? "enable root" : "disable root" + " -> ";
					}
					Switch{
						id:switches2;
						anchors.verticalCenter:parent.verticalCenter;
					}
					Text{
						font.pixelSize:24;
						anchors.verticalCenter:parent.verticalCenter;
						color:"white";
						text:"Terminal -> ";
					}
					ButtonRow{
						id:terminal;
						width:240;
						anchors.verticalCenter:parent.verticalCenter;
						Button {
							id:meegot;
							platformStyle:ButtonStyle{
								fontPixelSize:20;
								buttonHeight:40
								buttonWidth:120;
							}
							text:"MeeGo";
						}
						Button {
							id:mt;
							platformStyle:ButtonStyle{
								fontPixelSize:20;
								buttonHeight:40
								buttonWidth:120;
							}
							text:"Mtermite";
						}
					}
					Text{
						font.pixelSize:24;
						anchors.verticalCenter:parent.verticalCenter;
						color:"white";
						text:"external editor -> ";
					}
					Button {
						anchors.verticalCenter:parent.verticalCenter;
						platformStyle:ButtonStyle{
							fontPixelSize:20;
							buttonHeight:40
							buttonWidth:80;
						}
						text:"Vim";
						enabled:qobj.file.length !== 0;
						onClicked:{
							var term = terminal.checkedButton === meegot ? "/usr/bin/meego-terminal" : "/opt/mtermite/bin/mtermite";
							developer.openExternEditor(qobj.file, term, "/usr/bin/vim", switches2.checked);
						}
					}
					Button {
						anchors.verticalCenter:parent.verticalCenter;
						platformStyle:ButtonStyle{
							fontPixelSize:20;
							buttonHeight:40
							buttonWidth:80;
						}
						text:"Vi";
						enabled:qobj.file.length !== 0;
						onClicked:{
							var term = terminal.checkedButton === meegot ? "/usr/bin/meego-terminal" : "/opt/mtermite/bin/mtermite";
							developer.openExternEditor(qobj.file, term, "/usr/bin/vi", switches2.checked);
						}
					}
					Button {
						anchors.verticalCenter:parent.verticalCenter;
						platformStyle:ButtonStyle{
							fontPixelSize:20;
							buttonHeight:40
							buttonWidth:80;
						}
						text:"Nano";
						enabled:qobj.file.length !== 0;
						onClicked:{
							var term = terminal.checkedButton === meegot ? "/usr/bin/meego-terminal" : "/opt/mtermite/bin/mtermite";
							developer.openExternEditor(qobj.file, term, "/usr/bin/nano", switches2.checked);
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
