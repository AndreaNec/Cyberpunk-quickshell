import Quickshell // for PanelWindow
import QtQuick // for Text
import "./stats"
import "./launcher"
import "./mediaplayer"
import "./notifications"
import "./osd"
import "./settings"

ShellRoot {
    StatsHud {}
    Bar {}
    Launcher {}
    MediaPanel {}
    Osd {}
    NewNotificationPopup {}
    SettingsPanel {}
}
