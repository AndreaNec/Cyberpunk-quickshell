import QtQuick
import QtQuick.Shapes
import "../"

Item {
    id: root

    property color color: "#2ffcff"
    property bool filled: true
    property real strokeWidth: 2

    // details in real pixels, independent of width/height
    property real chamfer: 5          // bottom-right diagonal
    property real notchW: 2.5         // how far the left step goes in
    property real stepFromBottom: 30  // height of the notched area
    property real footH: 3            // vertical part at the bottom-left
    property real leadH: 1.5          // small diagonal lead-in
    property real foot: 0.5           // inset of the bottom-left foot

    implicitWidth: implicitHeight * 0.27
    implicitHeight: Theme.ramHeight

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.filled ? root.color : "transparent"
            strokeColor: root.strokeWidth > 0 ? root.color : "transparent"
            strokeWidth: root.strokeWidth
            joinStyle: ShapePath.MiterJoin

            startX: 0
            startY: 0
            PathLine {
                x: root.width
                y: 0
            }
            PathLine {
                x: root.width
                y: root.height - root.chamfer
            }
            PathLine {
                x: root.width - root.chamfer
                y: root.height
            }
            PathLine {
                x: root.foot
                y: root.height
            }
            PathLine {
                x: root.foot
                y: root.height - root.footH
            }
            PathLine {
                x: root.notchW
                y: root.height - root.footH - root.leadH
            }
            PathLine {
                x: root.notchW
                y: root.height - root.stepFromBottom
            }
            PathLine {
                x: 0
                y: root.height - root.stepFromBottom
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }
}
