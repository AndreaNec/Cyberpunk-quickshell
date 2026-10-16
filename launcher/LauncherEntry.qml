import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "../"

Item {
    id: item
    required property var modelData
    required property int index

    readonly property bool current: ListView.isCurrentItem
    readonly property int distance: Math.abs(index - ListView.view.currentIndex)

    // Quadratic shift: 0 on the selected row, growing with the distance from it
    readonly property real reserve: 48
    readonly property real shift: Math.min(distance * distance * 2.3, 44)

    readonly property string subtitle: (root.query !== "" && modelData.path) ? modelData.path : (modelData.comment || "")

    width: ListView.view.width
    height: list.rowHeight
    opacity: current ? 1 : Math.max(0.25, 1 - distance * 0.18)
    Behavior on opacity {
        NumberAnimation {
            duration: 120
        }
    }

    Item {
        id: body
        x: item.shift
        width: parent.width - item.reserve    // constant width: the row translates, it doesn't shrink
        height: parent.height
        Behavior on x {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        // Number badge
        Rectangle {
            id: badge
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            border.width: 2
            border.color: Theme.colCyan
            Text {
                anchors.centerIn: parent
                text: item.index + 1
                color: Theme.colCyan
                font.bold: true
                font.pixelSize: 12
            }
        }

        // Row box: outline + content as siblings
        Item {
            id: rowBox
            anchors.left: badge.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 2
            anchors.bottomMargin: 2

            CybrShape {
                anchors.fill: parent
                notch: false
                cut: 6
                borderWidth: item.current ? 2 : 1
                borderColor: item.current ? Theme.colCyan : Qt.alpha(Theme.colCyan, 0.5)
                fillColor: item.current ? Qt.alpha(Theme.colCyan, 0.15) : "transparent"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                // Icon: nerd-font glyph for system entries, theme icon for apps
                Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    IconImage {
                        anchors.fill: parent
                        visible: !item.modelData.glyph
                        source: Quickshell.iconPath(item.modelData.iconName || "", true) || Quickshell.iconPath("application-x-executable", true)
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !!item.modelData.glyph
                        text: item.modelData.glyph || ""
                        color: Theme.colCyan
                        font.family: root.nerdFont
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: item.modelData.name
                        color: item.current ? "white" : "#aab4c8"
                        font.bold: true
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        visible: text !== ""
                        text: item.subtitle
                        color: Qt.alpha(Theme.colCyan, 0.7)
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Chevron for submenus
                Text {
                    visible: !!item.modelData.children
                    text: "\uf054"
                    color: Theme.colCyan
                    font.family: root.nerdFont
                    font.pixelSize: 12
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        // onPositionChanged, not onEntered: the list scrolls under a still cursor
        onPositionChanged: list.currentIndex = item.index
        onClicked: root.activate(item.modelData)
    }
}
