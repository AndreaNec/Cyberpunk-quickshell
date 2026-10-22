import QtQuick
import Quickshell
import "../Singletons"

Scope {
    id: root
    required property GeneralOsd osd
    property bool ready: false
    Timer {
        interval: 2000
        running: true
        onTriggered: root.ready = true
    }
    Connections {
        target: Bluetooth
        function onOnlineChanged() {
            if (root.ready)
                root.push();
        }
        function onDeviceChanged() {
            if (root.ready)
                root.push();
        }
    }

    function push() {
        if (!Bluetooth.online) {
            osd.show("󰤭", "BLUETOOTH // OFFLINE", 0, false);
        } else {
            osd.show("󰤨", "BLUETOOTH // " + Bluetooth.device, 1, false);
        }
    }
}
