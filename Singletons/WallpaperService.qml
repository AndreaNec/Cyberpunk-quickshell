pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper service: scans a folder, applies wallpapers via hyprpaper IPC,
// remembers the last choice and re-applies it when the shell starts.
//
// qmldir:  singleton WallpaperService WallpaperService.qml
// IPC:     qs ipc call wallpaper next | previous | random | refresh | set <path>
Singleton {
    id: root

    // ---------- config ----------
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    // Empty = fallback for every monitor. Otherwise e.g. "DP-1".
    property string monitor: ""
    // hyprpaper fit mode: cover | contain | tile | fill
    property string fitMode: "cover"
    // Set true for hyprpaper < 0.8 ("monitor,path" syntax, needs preload/unload)
    property bool legacyIpc: false

    // ---------- state ----------
    property string current: ""
    property var wallpapers: []
    readonly property bool scanning: scanProc.running
    readonly property int count: wallpapers.length
    readonly property int currentIndex: wallpapers.indexOf(current)
    readonly property string stateFile: Quickshell.env("HOME") + "/.local/state/quickshell/wallpaper"

    // $1 = path, $2 = hyprpaper target, $3 = state file, $4 = legacy flag
    readonly property string applyScript: 'mkdir -p "$(dirname "$3")"; ' + 'printf "%s" "$1" > "$3"; ' + 'hyprctl hyprpaper preload "$1" >/dev/null 2>&1; ' +   // no-op on new hyprpaper
    'hyprctl hyprpaper wallpaper "$2"; ' + 'if [ "$4" = 1 ]; then hyprctl hyprpaper unload unused >/dev/null 2>&1; fi'

    // ---------- API ----------
    function refresh() {
        if (!scanProc.running)
            scanProc.running = true;
    }

    function set(path) {
        if (!path)
            return;
        root.current = path;
        const target = legacyIpc ? monitor + "," + path : monitor + "," + path + "," + fitMode;
        Quickshell.execDetached(["sh", "-c", applyScript, "sh", path, target, stateFile, legacyIpc ? "1" : "0"]);
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
        command: ["sh", "-c", "find -L \"$1\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort", "sh", root.wallpaperDir]
        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.split("\n").filter(l => l.length > 0)
        }
    }

    // Read the last wallpaper, then re-apply it (hyprpaper forgets it on restart)
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

    // Small delay so hyprpaper is up when the session has just started
    Timer {
        id: restoreTimer
        interval: 1500
        onTriggered: root.set(root.current)
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
