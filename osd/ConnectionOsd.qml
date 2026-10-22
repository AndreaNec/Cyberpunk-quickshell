import QtQuick
import Quickshell
import "../Singletons"

Scope {
    id: root
    required property GeneralOsd osd

    // Ignore the initial values that appear when the shell starts
    property bool ready: false
    Timer {
        interval: 2000
        running: true
        onTriggered: root.ready = true
    }

    Connections {
        target: Network
        function onOnlineChanged() {
            if (root.ready)
                root.push();
        }
        function onSsidChanged() {
            if (root.ready)
                root.push();
        }
    }

    function push() {
        if (!Network.online) {
            osd.show("󰤭", "NETWORK // OFFLINE", 0, false);
        } else {
            osd.show("󰤨", "NETWORK // " + Network.ssid, 1, false);
        }
    }
}
