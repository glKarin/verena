/*
 * This file included a define of "menu" component.
 */
import QtQuick 1.0
Item{
    id: container
    anchors.fill: parent
    signal centerClicked
    signal itemClicked(int index)
    signal subbarItemClicked(int index)
    signal clickMenuOutside

    property variant centerSrc: ""
    property variant centerPressedSrc: ""
    property variant menuModel: 0
    property variant subModel: 0
    property int rMargin: 25
    property int yMargin: 25

		property int menuRadius: 160;
		property real fPercent: 1;


    state: "mainbarshowed"

    //show sub menu
    function showSubbar(flag) {
        if (flag)
            container.state = "subbarshowed"
        else
            container.state = "subbarhiden"
    }

    function isSubbarShowed() {
        return container.state == "subbarshowed"
    }

    function selectSubbarItem(index) {
        for (var i = 0; i < subMenu.children.length; i ++)
             subMenu.children[i].state = "normal";
         subMenu.children[index].state = "selected"
    }

    //return reference of sub menu item
    function getSubbarItem(index) {
        return subMenu.children[i];
    }

    function selectItem(name) {
        for (var i = 0; i < menuModel.count; i++)
            if (menuModel.get(i).name == name && mainMenuIconArea.children[i] != undefined) {
                mainMenuIconArea.children[i].state = "selected";
                return;
            }
        for (i = 0; i < subModel.count; i++) {
            if (menuModel.get(i).name == name &&  subMenu.children[i] != undefined) {
                subMenu.children[i].state = "selected";
                return;
            }
        }
    }

    function unSelectItem(name) {
        for (var i = 0; i < menuModel.count; i++)
            if (menuModel.get(i).name == name && mainMenuIconArea.children[i] != undefined) {
                mainMenuIconArea.children[i].state = "normal";
                return;
            }
        for (i = 0; i < subModel.count; i++) {
            if (menuModel.get(i).name == name &&  subMenu.children[i] != undefined) {
                subMenu.children[i].state = "normal";
                return;
            }
        }
    }

    function setItemState(name, state) {
        for (var i = 0; i < menuModel.count; i++)
            if (menuModel.get(i).name == name && mainMenuIconArea.children[i] != undefined) {
                mainMenuIconArea.children[i].state = state;
                return;
            }
    }

    //lock item to ensure that the item doesn't handle mouse events
    function lockItemState(name){
        for (var i = 0; i < menuModel.count; i++)
            if (menuModel.get(i).name == name && mainMenuIconArea.children[i] != undefined) {
                mainMenuIconArea.children[i].lockState();
                return;
            }
    }

    function getItemState(name) {
        for (var i = 0; i < menuModel.count; i++)
            if (menuModel.get(i).name == name && mainMenuIconArea.children[i] != undefined) {
                return mainMenuIconArea.children[i].state;
            }
        return "";
    }

    Rectangle{
        anchors.fill: parent
        color: "#00ffff00"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var r = 0;
                var oX = container.width / 2;
                var oY = container.height;
                if (container.state == "subbarshowed") {
                    r = subMenu.width / 2;
                } else
                    r = mainMenu.width / 2;
                if (Math.pow(oX - mouse.x, 2) + Math.pow(oY - mouse.y, 2) >= Math.pow(r, 2)){
                    container.clickMenuOutside();
                }
                else
                    console.log("Click inside ring.")
            }
        }
    }

		Rectangle{
			id: subRect
			width: 443 * fPercent;
			height: 443 * fPercent; // ori 202;
				anchors.horizontalCenter: parent.horizontalCenter;
        y: container.height - height / 2
        rotation: 180
				color: "#00ffff00"
				clip: true;
				visible: rotation != 180;

				/*
        Image {
            id: subBackground
            source: "qrc:/tapbar/image/icon_tapbar1.png"
            anchors.fill: subMenu
					}
					*/

        Rectangle{
            id: subMenu
            width: parent.width;
            height: width;
            anchors.centerIn: parent;
            color: "#161616"
						radius: width / 2;
						smooth: true;

            property real margin: 28

            Component.onCompleted: subMenu.loadSubMenu();

            function subMenuItemClicked(index) {
                container.subbarItemClicked(index);
            }

            function loadSubMenu() {
                var num = subModel.count;
                var angel = 180 / (num + 1);
                var r = subMenu.width / 2 - subMenu.margin;
                var component = Qt.createComponent("YKMenuItem.qml");
                if (component.status == Component.Ready) {
                    for (var i = 0; i < num; i++) {
                        var icon = component.createObject(subMenu);
                        icon.x = subMenu.width / 2  -  Math.cos(Math.PI * angel * (i + 1) / 180)*r - icon.width / 2;
                        icon.y = subMenu.width / 2 - r * Math.sin(Math.PI * (angel * (i  + 1) / 180)) - icon.height / 2;
                        icon.index = i;
                        icon.press = subModel.get(i).pressed;
                        icon.normal = subModel.get(i).normal;
                        icon.selected = subModel.get(i).selected;
                        icon.clicked.connect(subMenu.subMenuItemClicked);
                        icon.state = "normal";
                    }
                }
            }
        }
    }

    Rectangle {
        id:mainMenu
        width: (287 + 12) * fPercent;
        height: (129 + 12) * fPercent;
        color: "#00ffff00"
        anchors.bottom: container.bottom
        anchors.horizontalCenter: container.horizontalCenter

				clip: true;

        property real margin: 28

        Component.onCompleted: mainMenu.loadMenu();

        function menuItemClicked(index) {
            container.itemClicked(index);
        }

        // Create menu item base on model
        function loadMenu() {
            var num = menuModel.count;
            var angel = 180 / (num + 1);
            var r = mainMenu.width / 2 - mainMenu.margin;
            var component = Qt.createComponent("YKMenuItem.qml");
            if (component.status == Component.Ready) {
                for (var i = 0; i < num; i++) {
                    var icon = component.createObject(mainMenuIconArea);
                    icon.x = mainMenu.width / 2  -  Math.cos(Math.PI * angel * (i + 1) / 180)*r - icon.width / 2;
                    icon.y = mainMenu.width / 2 - r * Math.sin(Math.PI * (angel * (i  + 1) / 180)) - icon.height / 2;
                    icon.index = i;
                    icon.press = menuModel.get(i).pressed;
                    icon.normal = menuModel.get(i).normal;
                    icon.selected = menuModel.get(i).selected;
                    icon.disable = menuModel.get(i).disable;
                    icon.clicked.connect(mainMenu.menuItemClicked);
                    icon.state = "normal"
                }
            }
        }

        Rectangle {
            id:mainMenuIconArea
            //anchors.fill: parent
						anchors.top: parent.top;
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						height: width;
						radius: width / 2;
						smooth: true;
            color: "#413641"
        }

				/*
        Image {
            id: background
            anchors.fill: parent
            source: "qrc:/tapbar/image/icon_tapbar.png"
					}
					*/

    }

		Rectangle{
        width: 140 * fPercent;
        height: 64 * fPercent;
        color: "#00ffff00"
        anchors.bottom: container.bottom
        anchors.horizontalCenter: container.horizontalCenter

				clip: true;

        Rectangle {
						anchors.top: parent.top;
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						height: width;
						radius: width / 2;
						smooth: true;
            color: "#161616"
        }

        Image {
            id: center
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            source: menu.centerSrc

            states: [
                State {
                    name: "pressed"
                    PropertyChanges {
                        target: center
                        source: menu.centerPressedSrc
                    }
                },
                State {
                    name: "released"
                    PropertyChanges {
                        target: center
                        source:menu.centerSrc
                    }
                }

            ]

            MouseArea{
                anchors.fill: parent
                onPressed: center.state = "pressed"
                onReleased: center.state = "released"
                onCanceled: center.stat = "released"
                onClicked:  menu.centerClicked()
            }
        }
			}

    states: [
        State {
            name: "subbarshowed"
            PropertyChanges {
                target: subRect
                rotation: 360
            }
        },
        State {
            name: "subbarhiden"
            PropertyChanges {
                target: subRect
                rotation: 180
            }
        },
        State {
            name: "allhiden"
            PropertyChanges {
                target: container
                opacity: 0
            }
        },
        State {
            name: "mainbarshowed"
            PropertyChanges {
                target: mainMenu
                opacity: 1
            }
            PropertyChanges {
                target: subRect
                rotation: 180
            }
        }

    ]

    transitions: [
        Transition {
            NumberAnimation {
                target: subRect
                property: "rotation"
                easing.type: Easing.InOutBounce
                duration: 200
            }
        }
    ]

}
