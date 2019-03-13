/*
 * This file included a define of menu item component.
 */

import QtQuick 1.0

Image {
    id: item
    width: 45 * fPercent;
    height: 45 * fPercent;
    property int index: 0
    property variant press: ""
    property variant normal: ""
    property variant selected: ""
    property variant disable: ""
    property bool lock: false

    function lockState() {
        lock = true;
    }

    function unlockState() {
        lock = false;
    }

    signal clicked(int index)
    MouseArea {
        anchors.fill: parent
        onPressed: if (!lock)item.state="pressed"
        onReleased: if (!lock)item.state="normal"
        onCanceled: if (!lock)item.state = "normal"
        onClicked: item.clicked(index)
    }

    states: [
        State {
            name: "pressed"
            PropertyChanges {
                target: item
                source: item.press
            }
        },
        State{
            name: "normal"
            PropertyChanges {
                target: item
                source: item.normal
            }
        },
        State {
            name: "selected"
            PropertyChanges {
                target: item
                source: item.selected
            }
        },
        State {
            name: "disable"
            PropertyChanges {
                target: item
                source: item.disable
            }
        }
    ]
}
