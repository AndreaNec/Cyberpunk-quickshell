import QtQuick
import "../"

Item {
    property real value: 0   // 0..1

    Rectangle {
        anchors.fill: parent
        color: "#40000000"

        Rectangle {
            height: parent.height
            width: parent.width * Math.max(0, Math.min(1, value))
            color: value > 0.8 ? Theme.colRed1 : Theme.colRed1   // optional: change color when high

            Behavior on width {
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
