import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../"

Scope {
    id: root

    // --- public API ---
    property string icon: ""
    property string context: ""
    property real progress: 0          // 0..1
    property color accent1: Qt.alpha(Theme.colRed1, 0.5)
    property color accent2: Theme.colCyan
    property int timeout: 1500

    function show(icon, context, progress) {
        root.icon = icon;
        root.context = context;
        root.progress = progress;
        shown = true;
        hideTimer.restart();
    }

    // --- internals ---
    property bool shown: false

    Timer {
        id: hideTimer
        interval: root.timeout
        onTriggered: root.shown = false
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            anchors.bottom: true
            margins.bottom: 120
            exclusiveZone: 0
            implicitWidth: col.implicitWidth + 50
            implicitHeight: col.implicitHeight
            color: "transparent"
            mask: Region {}
            WlrLayershell.layer: WlrLayer.Overlay

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                text: root.icon
                color: Qt.alpha(root.accent1, 1)
                font.pixelSize: 40
            }

            ColumnLayout {
                id: col
                anchors.right: parent.right
                spacing: 4

                // progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: "transparent"
                    border.color: root.accent1

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.progress))
                        height: parent.height
                        color: root.accent1
                        Behavior on width {
                            NumberAnimation {
                                duration: 80
                            }
                        }
                    }
                }

                // content box
                Rectangle {
                    Layout.preferredWidth: 450
                    Layout.preferredHeight: 40
                    border.color: root.accent1
                    color: Qt.alpha(root.accent1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 5

                        Text {
                            text: root.context
                            color: Theme.colRed1
                        }

                        Item {
                            Layout.fillWidth: true
                        }   // spacer pushes the logo right

                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            color: "transparent"
                            border.color: root.accent1

                            Image {
                                anchors.fill: parent
                                anchors.margins: 5
                                source: "../images/icons/NcIndustries.png"
                            }
                        }
                    }
                }

                Text {
                    text: "current progress " + Math.round(root.progress * 100) + "%"
                    color: root.accent1
                    font.pixelSize: 14
                }
            }
        }
    }
}
