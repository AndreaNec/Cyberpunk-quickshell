pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property int ramHeight: 60
    readonly property int barHeight: 30
    // Colori principali / rossi
    readonly property color colRed1: "#fb0a26" // (251, 10, 38)
    readonly property color colRed2: "#f50a1c" // (245, 10, 28)

    // Colore ciano / accento
    readonly property color colCyan: "#46ebeb" // (70, 235, 235)
    readonly property color colCyan2: "#3046ebeb" // (70, 235, 235)

    // Colori di sfondo / scuri
    readonly property color colDarkGray: "#2e3133" // (46, 49, 51)
    readonly property color colDarkGreen: "#192f22" // (25, 47, 34)

    readonly property string fontFamily: "DejaVu Sans"
}
