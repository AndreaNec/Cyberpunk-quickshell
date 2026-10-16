pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Networking

Singleton {
    id: network

    readonly property bool online: Networking.devices.values.some(d => d.connected)
    readonly property string connection: online ? "" : "󰖪"
    readonly property string ssid: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            let dev = Networking.devices.values[i];
            if (dev.type == DeviceType.Wifi) {
                for (let j = 0; j < dev.networks.values.length; j++) {
                    let net = dev.networks.values[j];
                    if (net.connected) {
                        return net.name;
                    }
                }
            }
        }
        return "disconnected";
    }

    readonly property var networks: {
        // Assuming the wifi device exist for sure
        const items = [
            {
                id: "net:toogle",
                name: Networking.wifiEnabled ? "Turn wifi off" : "Turn wifi on",
                glyph: "\uf1eb",
                boost: 15,
                keepOpen: true,
                run: () => {
                    Networking.wifiEnabled = !Networking.wifiEnabled;
                }
            }
        ];

        const devs = Networking.devices.values.slice();
        for (const d of devs) {
            if (d.type == DeviceType.Wifi) {
                d.scannerEnabled = true;
                for (let j = 0; j < d.networks.values.length; j++) {
                    let net = d.networks.values[j];
                    items.push({
                        id: "net:" + net.name,
                        name: net.name,
                        comment: net.connected ? "connected, select to disconnected" : "select to connect",
                        glyph: "\uf1eb",
                        keepOpen: true,
                        run: () => {
                            if (net.connected)
                                net.disconnect();
                            else
                                net.connect();
                        }
                    });
                }
            }
        }
        return items;
    }
}
