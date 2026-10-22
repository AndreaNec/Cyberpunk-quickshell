import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../"

Scope {
    id: root

    // ---------- Public API ----------
    property bool shown: false
    property string ipcTarget: "settings"

    function toggle() {
        shown = !shown;
    }
    function open() {
        shown = true;
    }
    function close() {
        shown = false;
    }

    // qs ipc call launcher toggle | open | close
    IpcHandler {
        target: root.ipcTarget
        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    // ---------- Style ----------
    readonly property string nerdFont: "JetBrainsMono Nerd Font"
    readonly property color accentRed: "#a31621"
    readonly property color textDim: "#9399b2"
    readonly property color accent1: Theme.colRed1
    readonly property color accent2: Theme.colCyan

    // ---------- State ------------
    property string currentPage: ""
    function selectPage(p) {
        currentPage = (currentPage === p) ? "" : p;
    }
    onShownChanged: if (!shown)
        currentPage = ""

    // ---------- Window ----------
    PanelWindow {
        id: win
        visible: root.shown || fx.visible
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Dim background, click anywhere outside the card to close
        Rectangle {
            anchors.fill: parent
            color: "#cc000000"
            opacity: root.shown ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }
        GlitchReveal {
            id: fx
            height: 800
            shown: root.shown
            // move this variables in Item beneath if to remove Wrapper GlitchReveal
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        Layout.preferredHeight: 3
                        Layout.fillWidth: true
                        color: root.accent2
                    }
                    SettingsEntry {
                        name: "wallpaper"
                        page: "wallpaper"
                        active: root.currentPage === page
                        onClicked: root.selectPage(page)
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        Layout.preferredHeight: 3
                        Layout.fillWidth: true
                        color: root.accent2
                    }
                }

                Loader {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: 100
                    Layout.rightMargin: 100
                    active: root.currentPage === "wallpaper"
                    sourceComponent: WallpaperManager {
                        onCloseRequested: root.currentPage = ""
                    }
                }
            }
        }
    }
}
