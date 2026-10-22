pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth as QsBt   // aliased so it can't clash with your own Bluetooth.qml singleton
import "../Singletons/"
import "../"

// DATA layer of the launcher.
//
// An item is a plain object:
//   { id, name, comment?, glyph? | iconName?, keywords?, boost?,
//     run?: () => void,                       // leaf
//     children?: array | () => array,         // node
//     keepOpen?: bool }                       // leaf: don't close after run
Singleton {
    id: root

    // Change this to your terminal launcher
    readonly property string terminal: "xdg-terminal-exec"

    function sh(cmd) {
        return () => Quickshell.execDetached(["sh", "-c", cmd]);
    }

    // ---------- Apps ----------
    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay).map(e => ({
                id: "app:" + e.id,
                name: e.name,
                comment: e.comment || e.genericName || "",
                iconName: e.icon,
                keywords: (e.keywords || []).join(" "),
                run: () => e.execute()
            })).sort((a, b) => a.name.localeCompare(b.name))

    // ---------- Power ----------
    readonly property var power: [
        {
            id: "power:lock",
            name: "Lock",
            glyph: "\uf023",
            boost: 15,
            run: sh("loginctl lock-session")
        },
        {
            id: "power:suspend",
            name: "Suspend",
            glyph: "\uf186",
            boost: 15,
            keywords: "sleep",
            run: sh("systemctl suspend")
        },
        {
            id: "power:logout",
            name: "Log out",
            glyph: "\uf2f5",
            boost: 15,
            keywords: "exit",
            run: sh("hyprctl dispatch exit")
        },
        {
            id: "power:reboot",
            name: "Reboot",
            glyph: "\uf021",
            boost: 15,
            keywords: "restart",
            run: sh("systemctl reboot")
        },
        {
            id: "power:off",
            name: "Power off",
            glyph: "\uf011",
            boost: 15,
            keywords: "shutdown",
            run: sh("systemctl poweroff")
        }
    ]

    // ---------- Bluetooth ----------
    readonly property var bluetooth: Bluetooth.bluetooth

    // ----------- WiFi ---------------
    readonly property var networks: Network.networks

    // ---------- Tree ----------
    readonly property var rootNode: ({
            id: "root",
            name: "Menu",
            children: () => [
                    {
                        id: "apps",
                        name: "Apps",
                        glyph: "\uf009",
                        comment: "Installed applications",
                        children: () => root.apps
                    },
                    {
                        id: "power",
                        name: "Power",
                        glyph: "\uf011",
                        comment: "Lock, suspend, reboot, power off",
                        children: () => root.power
                    },
                    {
                        id: "network",
                        name: "Network",
                        glyph: "\uf1eb",
                        comment: "Wi-Fi and connections",
                        children: () => root.networks
                    },
                    {
                        id: "bluetooth",
                        name: "Bluetooth",
                        glyph: "\uf293",
                        comment: "Adapter and devices",
                        children: () => root.bluetooth
                    },
                    {
                        id: "media",
                        name: "Media",
                        glyph: "\udb81\udf5a",
                        comment: "open Radioport",
                        run: sh("qs ipc call mediapanel open")
                    },
                    {
                        id: "settings",
                        name: "Settings",
                        glyph: "\uf013",
                        comment: "open settings",
                        run: sh("qs ipc call settings toggle")
                    }
                ]
        })

    function childrenOf(node) {
        const c = node.children;
        return typeof c === "function" ? c() : (c || []);
    }

    // Every leaf under `node`, tagged with its breadcrumb in `path`
    function flatten(node, path) {
        let out = [];
        for (const it of childrenOf(node)) {
            if (it.children) {
                out = out.concat(flatten(it, path ? path + " › " + it.name : it.name));
            } else {
                out.push(Object.assign({}, it, {
                    path: path
                }));
            }
        }
        return out;
    }

    // Memoized: only recomputed when apps/devices/etc. change, not on each keystroke
    readonly property var flat: flatten(rootNode, "")

    function search(pool, q) {
        const scored = [];
        for (const it of pool) {
            const n = it.name.toLowerCase();
            let s = 0;
            if (n.startsWith(q))
                s = 100;
            else if (n.includes(q))
                s = 60;
            else if ((it.keywords || "").toLowerCase().includes(q))
                s = 40;
            else if ((it.comment || "").toLowerCase().includes(q))
                s = 20;
            else if ((it.path || "").toLowerCase().includes(q))
                s = 10;
            if (s > 0)
                scored.push({
                    it: it,
                    s: s + (it.boost || 0)
                });
        }
        scored.sort((a, b) => b.s - a.s || a.it.name.localeCompare(b.it.name));
        return scored.map(x => x.it);
    }
}
