import QtQuick 1.1

Rectangle {
    id:root;
    width: info.width + 20;
    height:width;
    color:"black";
    radius: 90;
    border.color: "lightskyblue";
    border.width: 5;
    visible:opacity != 0.0;
    property alias text:info.text;
    opacity:0;
    smooth:true;

    function show(){
        animation.restart();
    }

    Text{
        id:info;
        anchors.centerIn: parent;
        color:"white";
        font.pixelSize: 24;
        font.family: "Nokia Pure Text";
    }

    SequentialAnimation{
        id:animation;
        NumberAnimation{
            target:root;
            property:"opacity";
            to:0.8;
            easing.type:Easing.OutExpo;
            duration:400;
        }
        PauseAnimation {
            duration: 2000;
        }
        NumberAnimation{
            target:root;
            property:"opacity";
            to:0.0;
            easing.type:Easing.InExpo;
            duration:400;
        }
    }

    MouseArea{
        anchors.fill:parent;
        onClicked:{
            animation.complete();
        }
    }

}
