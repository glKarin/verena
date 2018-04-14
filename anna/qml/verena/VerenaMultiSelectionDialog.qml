import QtQuick 1.1
import com.nokia.symbian 1.1
import "MultiSelectionDialog.js" as MultiSelectionDialog

Item{
    id:troot;
    property alias titleText:root.titleText;
    property alias model:selectionListView.model;
    property alias acceptButtonText:acceptButton.text;
    property alias rejectButtonText:rejectButton.text;
	signal hasSelectedIndies(variant arr);
	signal rejected;
    width:360;
    height:420;

	function open(){
        root.open();
	}

	function resetSelectedIndexes(){
        root.selectedIndexes = [];
    }
    /****************************************************************************
    **
    ** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
    ** All rights reserved.
    ** Contact: Nokia Corporation (qt-info@nokia.com)
    **
    ** This file is part of the Qt Components project.
    **
    ** $QT_BEGIN_LICENSE:BSD$
    ** You may use this file under the terms of the BSD license as follows:
    **
    ** "Redistribution and use in source and binary forms, with or without
    ** modification, are permitted provided that the following conditions are
    ** met:
    **   * Redistributions of source code must retain the above copyright
    **     notice, this list of conditions and the following disclaimer.
    **   * Redistributions in binary form must reproduce the above copyright
    **     notice, this list of conditions and the following disclaimer in
    **     the documentation and/or other materials provided with the
    **     distribution.
    **   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
    **     the names of its contributors may be used to endorse or promote
    **     products derived from this software without specific prior written
    **     permission.
    **
    ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
    ** $QT_END_LICENSE$
    **
    ****************************************************************************/

    CommonDialog {
        id: root
        anchors.fill:parent;
        onAccepted:{
            if(selectedIndexes.length > 0){
                troot.hasSelectedIndies(selectedIndexes);
            }else{
                //close();
                reject();
            }
        }
        // Common API: property list<int> selectedIndexes (currently not possible due to QTBUG-10822)
        property variant selectedIndexes: []   // read & write, variant is supposed to be list<int>
        //property alias titleText: titleLabel.text

        property Component delegate:          // Note that this is the default delegate for the list
            Component {
                id: defaultDelegate
    /*
                Item {
                    id: delegateItem

                    height: root.platformStyle.itemHeight
                    anchors.left: parent.left
                    anchors.right: parent.right

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent;
                        onPressed: MultiSelectionDialog.__toggleIndex(index);
                    }

                    Rectangle {
                        id: backgroundRect
                        anchors.fill: parent
                        color: MultiSelectionDialog.__isSelected(index) ? root.platformStyle.itemSelectedBackgroundColor : root.platformStyle.itemBackgroundColor
                    }

                    BorderImage {
                        id: background
                        anchors.fill: parent
                        border { left: UI.CORNER_MARGINS; top: UI.CORNER_MARGINS; right: UI.CORNER_MARGINS; bottom: UI.CORNER_MARGINS }
                        source: delegateMouseArea.pressed ? root.platformStyle.itemPressedBackground :
                                MultiSelectionDialog.__isSelected(index) ? root.platformStyle.itemSelectedBackground :
                                root.platformStyle.itemBackground
                    }

                    Text {
                        id: itemText
                        elide: Text.ElideRight
                        color: MultiSelectionDialog.__isSelected(index) ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
                        anchors.verticalCenter: delegateItem.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: root.platformStyle.itemLeftMargin
                        anchors.rightMargin: root.platformStyle.itemRightMargin
                        font: root.platformStyle.itemFont
                    }
                    Component.onCompleted: {
                        try {
                            // Legacy. "name" used to be the role which was used by delegate
                            itemText.text = name
                        } catch(err) {
                            try {
                                // "modelData" available for JS array and for models with one role
                                itemText.text = modelData
                            } catch (err) {
                                try {
                                     // C++ models have "display" role available always
                                    itemText.text = display
                                } catch(err) {
                                }
                            }
                        }
                    }
                }
                */
            MenuItem {
                height:64;
                width:ListView.view.width;
                platformInverted: root.platformInverted
                text: model.name
                //privateSelectionIndicator: selectedIndex == index

                onClicked: {
                        MultiSelectionDialog.__toggleIndex(index);
                    //root.accept()
                }
                CheckBox{
                    checked: MultiSelectionDialog.__isSelected(index);
                    anchors.right:parent.right;
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.rightMargin: 15;
                    enabled: false;
                }

                /*
                Keys.onPressed: {
                    if (event.key == Qt.Key_Up || event.key == Qt.Key_Down)
                        scrollBar.flash()
                }
                */
            }
                }
        // private api
        property int __pressDelay: 350
        property variant __selectedIndexesHash: []

        QtObject {
            id: backup
            property variant oldSelectedIndexes: []
        }

        onStatusChanged: {
          if (status == DialogStatus.Opening) {
              selectionListView.positionViewAtIndex(selectedIndexes[0], ListView.Center)
          }
          if (status == DialogStatus.Open)
              backup.oldSelectedIndexes = selectedIndexes
          if (status === DialogStatus.Closed)
              app.forceActiveFocus();
        }
        onRejected: { selectedIndexes = backup.oldSelectedIndexes;
            troot.rejected(); }

        onSelectedIndexesChanged: {
            MultiSelectionDialog.__syncHash();
        }

        // the title field consists of the following parts: title string and
        // a close button (which is in fact an image)
        // it can additionally have an icon
        titleText: "Multi-Selection Dialog"

        // the content field which contains the selection content
        content: Item {

            id: selectionContent
            property int listViewHeight
            property int maxListViewHeight : root.visualParent
                                             ? root.visualParent.height * 0.87
                                                     - buttonRow.childrenRect.height - 10 - 30
                                                     - 60
                                             : root.parent
                                                     ? root.parent.height * 0.87
                                                             - buttonRow.childrenRect.height - 10 - 30
                                                             - 60
                                                     : 350
            height: listViewHeight > maxListViewHeight ? maxListViewHeight : listViewHeight
            width: root.width
            y : 10

            ListView {
                id: selectionListView
                model: ListModel {}

                currentIndex : -1
                anchors.fill: parent
                delegate: root.delegate
                focus: true
                clip: true
                pressDelay: root.__pressDelay

                ScrollDecorator {
                    id: scrollDecorator
                    flickableItem: selectionListView
                    platformInverted: true
                }
                onCountChanged: selectionContent.listViewHeight = (typeof model.count === 'undefined' ? model.length : model.count) * 64
                onModelChanged: selectionContent.listViewHeight = (typeof model.count === 'undefined' ? model.length : model.count) * 64
            }

        }

        buttons: Item {
            id: buttonRowFiller
            width: parent.width
            height:  childrenRect.height
            y: 30

            onWidthChanged: {
                if ( (acceptButton.width + rejectButton.width > width) ||
                     (acceptButton.implicitWidth + rejectButton.implicitWidth > width) ) {
                    acceptButton.width = width / 2
                    rejectButton.width = width / 2
                } else {
                    acceptButton.width = acceptButton.implicitWidth
                    rejectButton.width = rejectButton.implicitWidth
                }
            }

            Row {
                id: buttonRow
                height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id: acceptButton
                    height: implicitHeight
                    objectName: "acceptButton"
                    text: ""
                    onClicked: root.accept()
                    visible: text != ""
                    //__dialogButton: true
                }
                Button {
                    id: rejectButton
                    height: implicitHeight
                    objectName: "rejectButton"
                    text: ""
                    onClicked: root.reject()
                    visible: text != ""
                    //__dialogButton: true
                }
            }
        }
    }
}
