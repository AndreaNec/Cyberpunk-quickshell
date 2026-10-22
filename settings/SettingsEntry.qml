import QtQuick
import QtQuick.Layouts
import Quickshell
import "../"

Item {
    id: root

    required property var page
    required property string name
    readonly property color accent1: Theme.colRed1
    readonly property color accent2: Theme.colCyan
    property bool active: false
    signal clicked

    Layout.preferredWidth: 250
    Layout.preferredHeight: 100
    clip: true
    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: root.active ? -border.width : 0   // spinge il bordo basso fuori dall'Item
        color: "transparent"
        border {
            color: root.accent2
            width: 2
        }
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            Layout.alignment: Qt.AlignCenter
            spacing: 20

            Rectangle { //image place holder
                Layout.preferredWidth: 50
                Layout.preferredHeight: 80
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: "../images/icons/notificationicon.png"
                }
            }
            CybrShape {
                Layout.fillWidth: true
                Layout.fillHeight: true
                notch: false
                cut: 6
                fillColor: Qt.alpha(root.accent2, 0.15)
                Text {
                    anchors.centerIn: parent
                    text: root.name
                    color: root.accent2
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
