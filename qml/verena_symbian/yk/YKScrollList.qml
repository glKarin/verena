/*
 * This file included a define of a scrollview component.
 */

import QtQuick 1.0

ListView {
    id: listview
    model: 20
    snapMode: ListView.SnapOneItem
    orientation: ListView.Horizontal
    signal itemClicked(variant msg)
}

