/*
 * This file included a defined of "busy" component which should be used while page status is loading or busy.
 */
import QtQuick 1.0

Image {
     id: container
     property bool on: false
     smooth: true;
     width: 80
     height:80

     source: Qt.resolvedUrl("../../image/yk/mis/image/busy.png"); visible: container.on

     NumberAnimation on rotation {
         running: container.on; from: 0; to: 360; loops: Animation.Infinite; duration: 1000
     }
 }
