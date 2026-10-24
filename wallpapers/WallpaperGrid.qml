import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../"
import "../Singletons"

// Grid wallpaper picker.
// Add `WallpaperManager {}` to shell.qml, then:
//   qs ipc call wallpapers toggle
//
// Keys: arrows / hjkl = move, Enter = apply, R = random, Esc = close
Scope {
    id: root

    property bool shown: false
    property int columns: 4
    property bool closeOnApply: false

    readonly property color accent: Theme.colCyan
    readonly property color alert: Theme.colRed1
    readonly property color panel: "#0b0f14"
    readonly property color dim: "#2a3340"
    readonly property string mono: "monospace"

    function open() {
        shown = true;
    }
    function close() {
        shown = false;
    }
    function toggle() {
        shown = !shown;
    }

    function toUrl(p) {
        return "file://" + p.split("/").map(encodeURIComponent).join("/");
    }

    function baseName(p) {
        return p.split("/").pop();
    }

    IpcHandler {
        target: "wallpapers"

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

    // Chamfered frame (top-right + bottom-left cut).
    // Swap for your CutShape/CybrShape if you prefer.
    component CutFrame: Shape {
        id: frame
        property real cut: 14
        property color fillColor: root.panel
        property color strokeColor: root.accent
        property real strokeWidth: 1.5

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: frame.fillColor
            strokeColor: frame.strokeColor
            strokeWidth: frame.strokeWidth
            startX: 0
            startY: 0
            PathLine {
                x: frame.width - frame.cut
                y: 0
            }
            PathLine {
                x: frame.width
                y: frame.cut
            }
            PathLine {
                x: frame.width
                y: frame.height
            }
            PathLine {
                x: frame.cut
                y: frame.height
            }
            PathLine {
                x: 0
                y: frame.height - frame.cut
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    PanelWindow {
        id: win

        visible: root.shown
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        //WlrLayershell.namespace: "quickshell:wallpapers"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        function sync() {
            grid.currentIndex = Math.max(WallpaperService.currentIndex, 0);
            grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
        }

        onVisibleChanged: {
            if (visible) {
                WallpaperService.refresh();
                sync();
                grid.forceActiveFocus();
            }
        }

        Connections {
            target: WallpaperService
            function onWallpapersChanged() {
                if (root.shown)
                    win.sync();
            }
        }

        // dimmed backdrop, click outside = close
        Rectangle {
            anchors.fill: parent
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }

        ColumnLayout {
            anchors.centerIn: parent

            width: Math.min(parent.width - 120, 1100)
            height: Math.min(parent.height - 120, 720)
            spacing: 0

            Rectangle {
                id: topBar
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                color: root.alert
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    Text {
                        color: "#000000"
                        text: "das jko JKLDJ jlkAçS--dsad"
                        font.pixelSize: topBar.Layout.preferredHeight - 4
                    }
                }
            }

            Rectangle {
                id: card
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.alpha(root.alert, 0.1)

                border {

                    width: 2
                    color: root.alert
                }

                // swallow clicks so the backdrop doesn't close the window
                MouseArea {
                    anchors.fill: parent
                }

                // ---------- header ----------
                Item {
                    id: header
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 24
                    }
                    height: 52

                    Text {
                        id: title
                        text: "// WALLPAPERS"
                        color: root.accent
                        font {
                            family: root.mono
                            pixelSize: 22
                            bold: true
                            letterSpacing: 2
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }
                        text: WallpaperService.current !== "" ? "ACTIVE :: " + root.baseName(WallpaperService.current) : "ACTIVE :: none"
                        color: root.alert
                        elide: Text.ElideMiddle
                        width: parent.width * 0.7
                        font {
                            family: root.mono
                            pixelSize: 12
                        }
                    }

                    Text {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        text: WallpaperService.scanning ? "SCANNING..." : WallpaperService.count + " FILES"
                        color: root.accent
                        font {
                            family: root.mono
                            pixelSize: 12
                        }
                    }
                }

                Rectangle {
                    id: divider
                    anchors {
                        top: header.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 24
                        rightMargin: 24
                        topMargin: 6
                    }
                    height: 1
                    color: root.accent
                    opacity: 0.5
                }

                // ---------- grid ----------
                GridView {
                    id: grid
                    anchors {
                        top: divider.bottom
                        bottom: footer.top
                        left: parent.left
                        right: parent.right
                        leftMargin: 18
                        rightMargin: 18
                        topMargin: 10
                        bottomMargin: 6
                    }
                    clip: true
                    focus: true
                    keyNavigationEnabled: true
                    highlightFollowsCurrentItem: false
                    boundsBehavior: Flickable.StopAtBounds
                    cacheBuffer: 600

                    model: WallpaperService.wallpapers
                    cellWidth: Math.floor(width / root.columns)
                    cellHeight: Math.round(cellWidth * 9 / 16)

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            color: root.accent
                            opacity: 0.7
                        }
                    }

                    Keys.onPressed: event => {
                        switch (event.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            WallpaperService.set(WallpaperService.wallpapers[currentIndex]);
                            if (root.closeOnApply)
                                root.close();
                            break;
                        case Qt.Key_Escape:
                            root.close();
                            break;
                        case Qt.Key_R:
                            WallpaperService.random();
                            win.sync();
                            break;
                        case Qt.Key_H:
                            moveCurrentIndexLeft();
                            break;
                        case Qt.Key_L:
                            moveCurrentIndexRight();
                            break;
                        case Qt.Key_K:
                            moveCurrentIndexUp();
                            break;
                        case Qt.Key_J:
                            moveCurrentIndexDown();
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }

                    delegate: Item {
                        id: cell

                        required property var modelData
                        required property int index

                        readonly property bool selected: GridView.isCurrentItem
                        readonly property bool active: modelData === WallpaperService.current

                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "transparent"

                            border{
                              color: cell.selected ? root.accent : (cell.active ? root.alert : root.dim)
                              width: cell.selected ? 2 : 1
                            }
                        }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10
                            source: root.toUrl(cell.modelData)
                            sourceSize.width: 480
                            sourceSize.height: 270
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            opacity: status !== Image.Ready ? 0 : (cell.selected ? 1 : 0.7)

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                        }

                        // ACTIVE tag
                        Rectangle {
                            visible: cell.active
                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                                leftMargin: 10
                                bottomMargin: 10
                            }
                            width: tag.implicitWidth + 12
                            height: tag.implicitHeight + 6
                            color: root.alert

                            Text {
                                id: tag
                                anchors.centerIn: parent
                                text: "ACTIVE"
                                color: "#0b0f14"
                                font {
                                    family: root.mono
                                    pixelSize: 10
                                    bold: true
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: grid.currentIndex = cell.index
                            onClicked: {
                                grid.currentIndex = cell.index;
                                WallpaperService.set(cell.modelData);
                                if (root.closeOnApply)
                                    root.close();
                            }
                        }
                    }
                }

                Text {
                    visible: !WallpaperService.scanning && WallpaperService.count === 0
                    anchors.centerIn: grid
                    horizontalAlignment: Text.AlignHCenter
                    text: "NO IMAGES FOUND\n" + WallpaperService.wallpaperDir
                    color: root.alert
                    font {
                        family: root.mono
                        pixelSize: 14
                    }
                }

                // ---------- footer ----------
                Text {
                    id: footer
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        margins: 20
                    }
                    horizontalAlignment: Text.AlignHCenter
                    text: "ARROWS/HJKL NAVIGATE  ·  ENTER APPLY  ·  R RANDOM  ·  ESC CLOSE"
                    color: root.accent
                    opacity: 0.7
                    font {
                        family: root.mono
                        pixelSize: 11
                        letterSpacing: 1
                    }
                }
            }
            RowLayout {
                id: rowFooter
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.preferredHeight: 18
                Text {
                    Layout.fillWidth: true
                    text: "Device asjdlkaspaqqa213"
                    color: root.alert
                    font.pixelSize: rowFooter.Layout.preferredHeight - 4
                }
                Rectangle {
                    Layout.preferredHeight: 18
                    Layout.preferredWidth: 80
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: "../images/icons/Protocol1.png"
                    }
                }
            }
        }
    }
}
