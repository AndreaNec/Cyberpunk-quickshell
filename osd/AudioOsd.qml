import QtQuick
import Quickshell
import "../Singletons"

Scope {
    id: root
    required property GeneralOsd osd          // injected from shell.qml

    property bool ready: false
    Timer {
        interval: 2000
        running: true
        onTriggered: root.ready = true
    }
    Connections {
        target: Audio.sink?.audio
        function onVolumeChanged() {
            if (root.ready) {
                root.push();
            }
        }
        function onMutedChanged() {
            if (root.ready) {
                root.push();
            }
        }
    }

    function push() {
        const a = Audio.sink?.audio;
        if (!a)
            return;
        osd.show(a.muted ? "󰝟" : "󰕾", "VOLUME", a.muted ? 0 : a.volume);
    }
}
