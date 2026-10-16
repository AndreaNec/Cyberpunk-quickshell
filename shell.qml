import Quickshell // for PanelWindow
import QtQuick // for Text
import "./stats"
import "./launcher"
import "./mediaplayer"

ShellRoot {
    StatsHud {}
    Bar {}
    Launcher {}
    MediaPanel {}
}
