import Quickshell
import "../Singletons"
import "../"
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top

    mask: Region {}

    anchors {
        top: true
        left: true
        right: true
    }
    // Aggiungiamo un margine extra alla larghezza per evitare tagli dovuti all'inclinazione
    implicitHeight: workspaces.height
    color: "transparent"
    margins {
        top: 5
        left: 20
        right: 20
    }

    Item {
        id: contentRoot
        anchors.fill: parent
        property int spacing: 10

        // 1. Left Column (RAM info) anchored to the left edge of workspaces
        Column {
            id: leftBlock
            anchors.right: workspaces.left
            anchors.rightMargin: contentRoot.spacing
            anchors.top: workspaces.top
            spacing: 4

            Text {
                color: Qt.alpha(Theme.colRed1, 0.35)
                text: "cyberdeck Ram:"
            }
            Rectangle {
                color: Qt.alpha(Theme.colRed1, 0.35)
                height: 3
                width: parent.width
            }
        }

        // 2. CENTER: Workspaces component locked to the exact center of the window
        Workspaces {
            id: workspaces
            anchors.centerIn: parent
            height: Theme.ramHeight
        }

        // 3. Right Column anchored to the right edge of workspaces
        Column {
            id: rightBlock
            anchors.left: workspaces.right
            anchors.leftMargin: contentRoot.spacing
            anchors.top: workspaces.top
            spacing: 4

            Text {
                color: Qt.alpha(Theme.colRed1, 0.35)
                text: Hypr.currentWsId + "/" + Hypr.nWs + " " + Time.time
            }
            Rectangle {
                color: Qt.alpha(Theme.colRed1, 0.35)
                height: 3
                width: parent.width
            }
        }
    }
}
