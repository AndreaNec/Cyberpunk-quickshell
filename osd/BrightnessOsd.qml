import Quickshell
import Quickshell.Io

Scope {
    id: root
    required property Osd osd

    IpcHandler {
        target: "brightness"
        function show(value: real): void {
            root.osd.show("󰃠", "BRIGHTNESS", value);
        }
    }
}
