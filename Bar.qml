import Quickshell
import QtQuick
import QtQuick.Layouts
import "./Singletons"

PanelWindow {

    property color mainColor: "transparent"

    anchors {
        left: true
        top: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: mainColor

    CyberWidget {
        anchors.left: parent.left
        icon: "󰥔"
        label: Time.time

        visible: false
    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        spacing: 12

        CyberWidget {
            icon: ""
            label: Processes.cpuUsage

            visible: false
        }

        CyberWidget {
            icon: Network.connection
            label: Network.ssid

            visible: false
        }

        CyberWidget {
            icon: Bluetooth.icon
            visible: false
        }

        CyberWidget {
            icon: ""

            visible: false
        }
    }
}
