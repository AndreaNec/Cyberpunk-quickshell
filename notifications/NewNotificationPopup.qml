import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../"
import "../Singletons"

Scope {
    id: root

    property color accent1: Theme.colRed1
    property color accent2: Theme.colCyan

    IpcHandler {
        target: "notifications"

        function dismiss_all(): void {
            NotificationService.dismissAll();
        }

        function dnd_toggle(): void {
            NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
        }
    }

    PanelWindow {
        anchors {
            left: true
            top: true
        }
        margins {
            left: 20
            top: 0
        }

        visible: NotificationService.notifications.length > 0

        focusable: false

        implicitWidth: notifiCol.width
        implicitHeight: notifiCol.implicitHeight + 20

        //color: Qt.alpha(root.accent1, 0.05)
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:notifications"

        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: notifiCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            width: 400
            spacing: 20

            Repeater {
                // For testing: 3 placeholder cards.
                // Later: model: NotificationService.notifications
                // and use modelData.summary / modelData.body below.
                //model: 3

                model: ScriptModel {
                    values: NotificationService.notifications
                    objectProp: "seqId"
                }

                delegate: RowLayout {   // one notification card
                    id: notifCard
                    required property var modelData
                    required property var index

                    HoverHandler {
                        id: cardHover
                        onHoveredChanged: notifCard.modelData.hovered = hovered
                    }

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 6

                    // left ">" column
                    ColumnLayout {
                        Layout.preferredWidth: 20
                        Layout.alignment: Qt.AlignTop

                        Text {
                            text: ">"
                            color: root.accent1
                        }
                        Text {
                            text: ">"
                            color: root.accent1
                        }
                    }

                    // main content
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        Text {
                            Layout.fillWidth: true
                            text: "connection 131.321.5."
                            font.pixelSize: 12
                            color: root.accent1
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            // icon placeholder
                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 120
                                Layout.alignment: Qt.AlignTop
                                color: "transparent"

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: "../images/icons/notificationicon2.png"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                // header
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20

                                    Item {
                                        Layout.preferredWidth: 20
                                        Layout.preferredHeight: 20

                                        CybrShape {
                                            anchors.fill: parent
                                            notch: false
                                            cut: 2
                                            borderColor: root.accent1
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            color: root.accent1
                                            text: ">"
                                        }
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: notifCard.modelData.appName || "Notication"
                                        color: root.accent1
                                        font.capitalization: Font.AllUppercase
                                        font.bold: true
                                        font.pixelSize: 18
                                    }
                                }

                                // body
                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: notifText.implicitHeight + 10   // 5px margin top + bottom

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Qt.alpha(root.accent2, 0.2)
                                        border.color: root.accent2
                                        border.width: 2
                                    }

                                    ColumnLayout {
                                        id: notifText
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 5
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.margins: 10
                                            text: notifCard.modelData.summary
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 4
                                            elide: Text.ElideRight
                                            color: root.accent2
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            visible: notifCard.modelData.body
                                            text: notifCard.modelData.body
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 4
                                            elide: Text.ElideRight
                                            color: root.accent2
                                        }
                                    }
                                }
                                RowLayout {
                                    Layout.alignment: Qt.AlignRight
                                    Layout.fillWidth: true
                                    visible: notifCard.modelData.actions.length > 0
                                    Repeater {
                                        model: notifCard.modelData.actions

                                        Item {
                                            id: actionBtn
                                            required property var modelData

                                            implicitWidth: content.implicitWidth + 20
                                            implicitHeight: 26

                                            Accessible.role: Accessible.Button
                                            Accessible.name: actionBtn.modelData.text || ""

                                            RowLayout {
                                                id: content
                                                anchors.centerIn: parent
                                                spacing: 6

                                                Text {
                                                    text: actionBtn.modelData.text || ""
                                                    color: root.accent1
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: 12
                                                    Layout.preferredHeight: 12
                                                    color: "transparent"
                                                    border.color: root.accent2
                                                    border.width: 1

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "X"
                                                        color: root.accent2
                                                        font.pixelSize: 9
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: notifCard.modelData.invokeAction(actionBtn.modelData.identifier)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // single spacer: pushes all the cards to the top
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
