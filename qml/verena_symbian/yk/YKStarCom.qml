/*
 * This file included a define of a component which could display a video's reputation in “stars” style.
 */
import QtQuick 1.0

Repeater {
    id: container
    model: 5
    property int score: 0
    property alias numStar: container.model

    Component.onCompleted: {
        setScore(container.score);
    }

    function setScore(score) {
        container.score = score;
        for (var i = 0; i < score && i < container.numStar; i++)
            container.itemAt(i).state = "full";
    }

    Image {
        id: star
        width: 20
        height: 20; // ori 35
        state: "empty"
        states: [
            State {
                name: "full"
                PropertyChanges {
                    target: star
										source: Qt.resolvedUrl("../../image/yk/mis/image/star_1.png");
                }
            },
            State {
                name: "empty"
                PropertyChanges {
                    target: star
										source: Qt.resolvedUrl("../../image/yk/mis/image/star_2.png");
                }
            }
        ]
    }
}
