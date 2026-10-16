pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Networking

Singleton {
    //CPU
    property real cpuUsage: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;

                var parts = data.trim().split(/\s+/);
                if (parts[0] !== "cpu")
                    return;

                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;

                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal;
                    var idleDiff = idleTime - lastCpuIdle;
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);
                    }
                }

                lastCpuTotal = total;
                lastCpuIdle = idleTime;
            }
        }
    }

    // Timer IO
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true // Esegue subito la prima lettura all'avvio
        onTriggered: {
            cpuProc.running = true;
        }
    }
}
