import Quickshell // for PanelWindow
import QtQuick // for Text
import "./stats"
import "./launcher"
import "./mediaplayer"
import "./osd"

ShellRoot {
    StatsHud {}
    Bar {}
    Launcher {}
    MediaPanel {}
    AudioOsd {}
}
