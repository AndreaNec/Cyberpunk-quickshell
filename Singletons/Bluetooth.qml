pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Bluetooth

Singleton {
    id: bluetooth

    property string icon: online ? "" : "󰂲"

    property BluetoothAdapter dev: Bluetooth.defaultAdapter
    property bool online: dev.enabled ? true : false
    readonly property var bluetooth: {
        const a = Bluetooth.defaultAdapter;
        if (!a)
            return [
                {
                    id: "bt:none",
                    name: "No Bluetooth adapter",
                    glyph: "\uf293",
                    run: () => {}
                }
            ];

        const items = [
            {
                id: "bt:toggle",
                name: a.enabled ? "Turn Bluetooth off" : "Turn Bluetooth on",
                glyph: "\uf293",
                boost: 15,
                keepOpen: true,
                run: () => {
                    a.enabled = !a.enabled;
                }
            }
        ];
        if (!a.discovering) {
            a.discovering = true;
        }

        let connectionTimer = null;
        const devs = a.devices.values.slice();
        devs.sort((x, y) => (y.bonded - x.bonded) || x.name.localeCompare(y.name));
        for (const d of devs) {
            // gets rid of the devices without real names
            if (d.name == d.deviceName) {
                items.push({
                    id: "bt:" + d.name,
                    name: d.name,
                    comment: d.connected ? "Connected, select to disconnect" : (d.bonded ? "Bonded, select to connect" : "Disconnected, select to connect"),
                    glyph: "\uf293",
                    keepOpen: true,
                    run: () => {
                        if (d.connected) {
                            if (connectionTimer)
                                clearTimeout(connectionTimer);
                            d.disconnect();
                        } else {
                            if (!d.paired) {
                                d.pair();
                            }
                            d.connect();

                            // If it doesn't connect within 15 seconds, abort the attempt
                            connectionTimer = setTimeout(() => {
                                if (!d.connected) {
                                    d.cancelPair();
                                    d.disconnect();
                                }
                            }, 15000);
                        }
                    }
                });
            }
        }
        return items;
    }
}
