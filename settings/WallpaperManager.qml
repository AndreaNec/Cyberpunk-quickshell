import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import "../"   // Theme + WallpaperService (remove if this file sits next to them)
import "../Singletons"

// Embeddable wallpaper grid (no window, no backdrop).
// Keys: arrows/hjkl = move, Enter = apply, R = random, Esc = closeRequested()
Rectangle {
    id: root

    property int columns: 4
    property bool closeOnApply: false
    signal closeRequested

    readonly property color accent: Theme.colCyan
    readonly property color alert: Theme.colRed1
    readonly property color panel: "#0b0f14"
    readonly property color dim: "#2a3340"
    readonly property string mono: "monospace"

    color: Qt.alpha(accent, 0.1)
    border {
        color: accent
        width: 2
    }

    function toUrl(p) {
        return "file://" + p.split("/").map(encodeURIComponent).join("/");
    }

    function baseName(p) {
        return p.split("/").pop();
    }

    function sync() {
        grid.currentIndex = Math.max(WallpaperService.currentIndex, 0);
        grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
    }

    Component.onCompleted: {
        WallpaperService.refresh();
        sync();
        grid.forceActiveFocus();
    }

    Connections {
        target: WallpaperService
        function onWallpapersChanged() {
            root.sync();
        }
    }

    // ---------- header ----------
    Item {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 16
        }
        height: 40

        /*
        Text {
            text: "// WALLPAPERS"
            color: root.accent
            font {
                family: root.mono
                pixelSize: 18
                bold: true
                letterSpacing: 2
            }
          }
          */

        Text {
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            width: parent.width * 0.7
            elide: Text.ElideMiddle
            text: WallpaperService.current !== "" ? "ACTIVE :: " + root.baseName(WallpaperService.current) : "ACTIVE :: none"
            color: root.alert
            font {
                family: root.mono
                pixelSize: 11
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
                pixelSize: 11
            }
        }
    }

    // ---------- grid ----------
    GridView {
        id: grid
        anchors {
            top: header.bottom
            bottom: footer.top
            left: parent.left
            right: parent.right
            leftMargin: 10
            rightMargin: 10
            topMargin: 6
            bottomMargin: 4
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
                    root.closeRequested();
                break;
            case Qt.Key_Escape:
                root.closeRequested();
                break;
            case Qt.Key_R:
                WallpaperService.random();
                root.sync();
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

            CybrShape {
                anchors.fill: parent
                anchors.margins: 6
                borderColor: cell.selected ? root.accent : (cell.active ? root.alert : root.dim)
                borderWidth: cell.selected ? 2 : 1
                notch: false
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
                    color: root.panel
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
                        root.closeRequested();
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
            pixelSize: 13
        }
    }

    // ---------- footer ----------
    Text {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 10
        }
        horizontalAlignment: Text.AlignHCenter
        text: "ARROWS/HJKL NAVIGATE  ·  ENTER APPLY  ·  R RANDOM  ·  ESC CLOSE"
        color: root.accent
        opacity: 0.7
        font {
            family: root.mono
            pixelSize: 10
            letterSpacing: 1
        }
    }
}
