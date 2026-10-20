// shell.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../"
import Quickshell.Widgets

Scope {
    id: root

    // needed so the sink's audio properties are actually populated
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property bool shown: false

    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            root.trigger();
        }
        function onMutedChanged() {
            root.trigger();
        }
    }

    function trigger() {
        shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shown = false
    }

    property color accent1: Qt.alpha(Theme.colRed1, 0.5)
    property color accent2: Theme.colCyan

    // LazyLoader creates the window only while it's visible
    LazyLoader {
        active: root.shown

        PanelWindow {
            anchors.bottom: true
            margins.bottom: 120
            exclusiveZone: 0           // don't reserve screen space
            implicitWidth: col.implicitWidth + 50
            implicitHeight: col.implicitHeight
            color: "transparent"
            mask: Region {}            // click-through
            Text {
                id: icon

                anchors.left: parent.left
                anchors.top: parent.top
                text: Pipewire.defaultAudioSink?.audio.muted ? "󰝟" : "󰕾"
                color: Qt.alpha(root.accent1, 1)
                font.pixelSize: 40
            }
            ColumnLayout {
                id: col
                implicitWidth: content.implicitWidth
                implicitHeight: content.implicitHeight + 10
                anchors.right: parent.right
                // progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: "transparent"
                    border.color: root.accent1

                    Rectangle {
                        width: parent.width * Math.min(1, Pipewire.defaultAudioSink?.audio.volume ?? 0)
                        height: 10
                        color: root.accent1
                        Behavior on width {
                            NumberAnimation {
                                duration: 80
                            }
                        }
                    }
                }
                Rectangle {
                    id: content
                    anchors.fill: parent.fill
                    implicitWidth: 350
                    implicitHeight: 40
                    border.color: root.accent1
                    color: Qt.alpha(root.accent1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        Text {
                            text: "VOLUME"
                            color: Theme.colRed1
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignRight
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
                    text: "current progress " + Math.round((Pipewire.defaultAudioSink?.audio.volume ?? 0) * 100) + "%"
                    color: root.accent1
                    font.pixelSize: 14
                }
            }
        }
    }
}
