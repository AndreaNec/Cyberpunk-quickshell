pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper service (awww backend; awww = the renamed swww).
// Scans a folder, applies wallpapers with `awww img`, remembers the last choice
// and re-applies it when the shell starts.
//
// qmldir:  singleton WallpaperService WallpaperService.qml
// IPC:     qs ipc call wallpaper next | previous | random | refresh | set <path>
Singleton {
    id: root

    // ---------- config ----------
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    // Empty = all outputs. Otherwise e.g. "DP-1" (see `awww query`).
    property string monitor: ""
    // none simple fade left right top bottom wipe wave grow center any outer random
    property string transition: "grow"
    property real transitionDuration: 1.2   // seconds (ignored by "simple")
    property int transitionFps: 60
    // Start awww-daemon if it isn't running yet
    property bool autoStartDaemon: true

    // ---------- state ----------
    property string current: ""
    property var wallpapers: []
    readonly property bool scanning: scanProc.running
    readonly property int count: wallpapers.length
    readonly property int currentIndex: wallpapers.indexOf(current)
    readonly property string stateFile: Quickshell.env("HOME") + "/.local/state/quickshell/wallpaper"

    // $1 path, $2 output, $3 state file, $4 transition, $5 duration, $6 fps, $7 autostart
    readonly property string applyScript: 'mkdir -p "$(dirname "$3")"; ' + 'printf "%s" "$1" > "$3"; ' + 'if [ "$7" = 1 ] && ! awww query >/dev/null 2>&1; then ' + '  (setsid awww-daemon >/dev/null 2>&1 &); ' + '  for i in 1 2 3 4 5 6 7 8 9 10; do awww query >/dev/null 2>&1 && break; sleep 0.2; done; ' + 'fi; ' + 'out=""; [ -n "$2" ] && out="-o $2"; ' + 'awww img $out --transition-type "$4" --transition-duration "$5" --transition-fps "$6" "$1"'

    // ---------- API ----------
    function refresh() {
        if (!scanProc.running)
            scanProc.running = true;
    }

    function apply(path, transitionType) {
        if (!path)
            return;
        root.current = path;
        Quickshell.execDetached(["sh", "-c", applyScript, "sh", path, monitor, stateFile, transitionType, String(transitionDuration), String(transitionFps), autoStartDaemon ? "1" : "0"]);
    }

    function set(path) {
        apply(path, transition);
    }

    function step(delta) {
        if (wallpapers.length === 0)
            return;
        const i = (Math.max(currentIndex, 0) + delta + wallpapers.length) % wallpapers.length;
        set(wallpapers[i]);
    }

    function next() {
        step(1);
    }
    function previous() {
        step(-1);
    }

    function random() {
        if (wallpapers.length === 0)
            return;
        let i;
        do {
            i = Math.floor(Math.random() * wallpapers.length);
        } while (wallpapers.length > 1 && i === currentIndex)
        set(wallpapers[i]);
    }

    // ---------- internals ----------
    Process {
        id: scanProc
        command: ["sh", "-c", "find -L \"$1\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) 2>/dev/null | sort", "sh", root.wallpaperDir]
        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.split("\n").filter(l => l.length > 0)
        }
    }

    // Read the last wallpaper and re-apply it instantly on shell start
    Process {
        id: stateProc
        command: ["cat", root.stateFile]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p.length > 0) {
                    root.current = p;
                    restoreTimer.start();
                }
            }
        }
    }

    Timer {
        id: restoreTimer
        interval: 500
        onTriggered: root.apply(root.current, "none")
    }

    IpcHandler {
        target: "wallpaper"

        function next(): void {
            root.next();
        }
        function previous(): void {
            root.previous();
        }
        function random(): void {
            root.random();
        }
        function refresh(): void {
            root.refresh();
        }
        function set(path: string): void {
            root.set(path);
        }
    }

    Component.onCompleted: {
        refresh();
        stateProc.running = true;
    }
}
