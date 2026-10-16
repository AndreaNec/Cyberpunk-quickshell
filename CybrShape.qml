import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    property color fillColor: "transparent"
    property color borderColor: Theme.colCyan
    property real borderWidth: 2

    property real cut: 8            // size of the bottom chamfers
    property bool notch: true       // top-center notch on/off
    property real notchWidth: 20    // flat part of the notch, in px
    property real notchDepth: 4
    property real notchSlope: 4     // horizontal run of the notch's angled sides

    preferredRendererType: Shape.CurveRenderer

    // Inset by half the stroke so the border isn't clipped at the edges
    readonly property real l: borderWidth / 2
    readonly property real t: borderWidth / 2
    readonly property real r: width - borderWidth / 2
    readonly property real b: height - borderWidth / 2
    readonly property real cx: width / 2

    readonly property var points: {
        const pts = [Qt.point(l, t)];
        if (notch) {
            const h = notchWidth / 2;
            pts.push(Qt.point(cx - h - notchSlope, t), Qt.point(cx - h, t + notchDepth), Qt.point(cx + h, t + notchDepth), Qt.point(cx + h + notchSlope, t));
        }
        pts.push(Qt.point(r, t), Qt.point(r, b - cut), Qt.point(r - cut, b), Qt.point(l + cut, b), Qt.point(l, b - cut), Qt.point(l, t));
        return pts;
    }

    ShapePath {
        fillColor: root.fillColor
        strokeColor: root.borderColor
        strokeWidth: root.borderWidth
        strokeStyle: ShapePath.SolidLine

        PathPolyline {
            path: root.points
        }
    }
}
