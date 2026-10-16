pragma Singleton
import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Hyprland // for Hyprland IPC

Singleton {
    property var nWs: Hyprland.workspaces.values.length
    property var currentWsId: Hyprland.focusedWorkspace?.id
}
