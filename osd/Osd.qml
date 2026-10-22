import Quickshell
import QtQuick

Scope {
    GeneralOsd {
        id: osd
    }
    AudioOsd {
        osd: osd
    }
    ConnectionOsd {
        osd: osd
    }
    BluetoothOsd {
        osd: osd
    }
}
