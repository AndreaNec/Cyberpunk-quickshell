import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Hyprland // for Hyprland IPC
import QtQuick.Layouts //
import "../"

Item {
    implicitHeight: 60 * 2
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        anchors.fill: parent

        Repeater {
            model: Hyprland.workspaces.values.length

            RamShape {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                // Controlla realmente se ci sono finestre aperte in questo workspace
                property bool hasWindows: {
                    for (var i = 0; i < Hyprland.toplevels.values.length; i++) {
                        var win = Hyprland.toplevels.values[i];
                        if (win.workspace && win.workspace.id === index + 1)
                            return true;
                    }
                    return false;
                }

                color: isActive ? Theme.colCyan : (hasWindows ? Qt.alpha(Theme.colCyan, 0.15) : Qt.alpha(Theme.colRed1, 0.5))
                filled: isActive || hasWindows

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
    }
}
