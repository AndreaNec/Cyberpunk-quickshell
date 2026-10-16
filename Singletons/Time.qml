pragma Singleton

import Quickshell
import QtQuick

Singleton {
    //Time
    readonly property string time: {
        // The passed format string matches the default output of
        // the `date` command.
        Qt.formatDateTime(clock.date, "ddd MMM d hh:mm");
    }
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
