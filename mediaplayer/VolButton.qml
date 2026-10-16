import Quickshell
import QtQuick
import "../"
import "../Singletons"

Item {
    id: btn
    property string label
    property color tint: Theme.colCyan
    property real step: 1

    implicitWidth: 20
    implicitHeight: 20

    Rectangle {
        anchors.fill: parent
        color: hit.pressed ? Qt.alpha(btn.tint, 0.3) : "transparent"
        border.width: 1
        border.color: btn.tint
    }
    Text {
        anchors.centerIn: parent
        text: btn.label
        color: btn.tint
    }
    MouseArea {
        id: hit
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Medias.active ? Medias.changeVolume(Medias.active, step) : null
    }
}
