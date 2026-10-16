import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Io
import "../"
import "../Singletons"

Scope {
    id: root
    property bool shown: false
    property string ipcTarget: "mediapanel"
    property int shapeHeight: 35
    property color accentColor1: Theme.colCyan
    property color accentColor2: Qt.alpha(Theme.colRed1, 0.5)
    property real h1: 14
    property real h2: 10

    function toggle() {
        shown = !shown;
    }
    function open() {
        shown = true;
    }
    function close() {
        shown = false;
    }

    // Exactly like the launcher: force focus to our focus container when shown
    onShownChanged: if (shown) {
        Qt.callLater(() => panelFocusScope.forceActiveFocus());
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

    PanelWindow {
        id: win
        visible: root.shown
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "mediapanel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Keys.onEscapePressed: root.close()

        anchors {
            top: true
            left: true
            bottom: true
            right: true
        }

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
        FocusScope {
            id: panelFocusScope
            anchors.fill: parent
            focus: true

            // Clean, explicit key handling just like your launcher's search box
            Keys.onEscapePressed: root.close()

            // Optional: Add volume shortcuts here too if you want them!
            Keys.onPressed: e => {
                if (e.key === Qt.Key_A) {
                    // Decrease volume action
                    Medias.active ? Medias.changeVolume(Medias.active, -0.01) : null;

                    e.accepted = true;
                } else if (e.key === Qt.Key_D) {
                    // Increase volume action
                    Medias.active ? Medias.changeVolume(Medias.active, 0.01) : null;
                    e.accepted = true;
                }
            }
        }
        GlitchReveal {
            id: fx
            anchors.centerIn: parent
            width: col.width
            height: col.height
            shown: root.shown
            ColumnLayout {
                id: col
                width: 460
                height: 500
                anchors.centerIn: parent
                spacing: 12
                Text {
                    Layout.fillWidth: true
                    text: "Tkla:__;v.0.02"
                    color: root.accentColor2
                    font.pixelSize: root.h2
                }
                Item { // radioport tag at the start
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.shapeHeight
                    CybrShape {
                        anchors.fill: parent
                        notch: false
                        cut: 6
                        borderColor: root.accentColor2
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: "RADIOPORT"
                        color: root.accentColor1
                    }
                }
                RowLayout { // album cover and info
                    id: albumName
                    Layout.fillWidth: true
                    Layout.minimumHeight: 200
                    Layout.preferredHeight: 200
                    Layout.maximumHeight: 200
                    spacing: 12

                    Item { // album cover
                        id: albumCover
                        Layout.fillHeight: true
                        Layout.preferredWidth: albumName.Layout.preferredHeight // square
                        property string artUrl: Medias.metadata(Medias.active)?.art ?? ""

                        CybrShape {
                            anchors.fill: parent
                            notch: false
                            cut: 6
                            borderColor: root.accentColor2
                        }
                        Image {
                            id: art
                            anchors.fill: parent
                            anchors.margins: 4
                            source: albumCover.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            sourceSize: Qt.size(width * 2, height * 2)
                            visible: status === Image.Ready
                        }
                        Text { // placeholder when there is no art
                            anchors.centerIn: parent
                            visible: art.status !== Image.Ready
                            text: "NO SIGNAL"
                            color: root.accentColor2
                        }
                    }

                    ColumnLayout { // name and volume
                        id: colMusicInfo
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 0
                        spacing: 8

                        property string track: Medias.metadata(Medias.active)?.title ?? "Nessun player"
                        property string artist: Medias.metadata(Medias.active)?.artist ?? "Nessun player"

                        Text {
                            text: "now playing"
                            color: root.accentColor2
                            font.pixelSize: root.h2
                        }
                        Rectangle { // separator
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            color: Qt.alpha(root.accentColor2, 0.5)
                        }

                        Text { // artist - title
                            Layout.fillWidth: true
                            Layout.fillHeight: true // pushes the volume row to the bottom
                            text: colMusicInfo.artist + " - " + colMusicInfo.track
                            color: Qt.alpha(root.accentColor2, 1)
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignTop
                        }

                        RowLayout { // volume
                            id: rowVolume
                            Layout.fillWidth: true
                            spacing: 6

                            property var raw: Medias.volume(Medias.active)
                            property string label: raw !== null && raw !== undefined ? Math.round(raw * 100) + "%" : "N/A"

                            Text {
                                text: "volume"
                                color: Qt.alpha(root.accentColor2, 1)
                            }
                            Item {
                                Layout.fillWidth: true
                            } // spacer

                            VolButton {
                                label: "A"
                                step: -0.01
                            }
                            Text {
                                Layout.preferredWidth: 40 // fixed width so the buttons don't jitter
                                horizontalAlignment: Text.AlignHCenter
                                text: rowVolume.label
                                color: Theme.colCyan
                            }
                            VolButton {
                                label: "D"
                                step: 0.01
                            }
                        }

                        Rectangle { // separator
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            color: root.accentColor2
                        }
                    }
                }
                ListView {
                    id: mediaList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: Medias.players

                    delegate: Item {
                        id: playerItem
                        required property var modelData // This is the MprisPlayer instance
                        required property int index
                        property bool isActive: modelData == Medias.active

                        width: mediaList.width
                        height: root.shapeHeight
                        CybrShape {
                            anchors.fill: parent
                            notch: false
                            cut: 6
                            fillColor: playerItem.isActive ? Qt.alpha(root.accentColor1, 0.3) : "transparent"
                            borderColor: playerItem.isActive ? Qt.alpha(root.accentColor1, 0.6) : "transparent"
                        }
                        // Example: Display the current track title or identity
                        Text {
                            width: playerItem.width - 15
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            // fallback to identity if no track is playing
                            text: modelData.trackTitle || modelData.identity || "Unknown Player"
                            elide: Text.ElideRight

                            color: root.accentColor1
                        }

                        // Example: Click to toggle play/pause for that specific player
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.canTogglePlaying) {
                                    Medias.active?.togglePlaying();
                                    modelData.togglePlaying();
                                }
                            }
                        }
                    }
                }
                Rectangle { // separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: root.accentColor2
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    Text {
                        Layout.fillWidth: true
                        text: "cyberdeckNutz"
                        color: root.accentColor2
                        font.pixelSize: root.h2
                    }
                }
            }
        }
    }
}
