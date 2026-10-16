import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string icon: ""
    property string label: ""
    property color fillColor: "transparent"
    property color borderColor: Theme.colCyan

    implicitWidth: row.implicitWidth + 28
    implicitHeight: Theme.barHeight

    CybrShape {
        anchors.fill: parent
        fillColor: root.fillColor
        borderColor: root.borderColor
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.icon
            color: Theme.colCyan
            font.family: "jetbrainsmono nerd font"
        }
        Text {
            text: root.label
            color: Theme.colCyan
        }
    }
}
