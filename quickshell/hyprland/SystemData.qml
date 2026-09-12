import QtQuick
import Quickshell
import Quickshell.Io

// System values used by the bar. Keeping the polling here leaves the UI declarative.
Item {
    id: root
    visible: false

    property int workspaceRevision: 0
    property string clockText: ""
    property string keyboardLayout: "--"
    property string volumeText: "  --%"
    property string cpuText: "  --%"
    property string batteryText: "  --%"
    property string batteryTooltip: "Оставшееся время пока неизвестно"
    property string temperatureText: " --°C"
    property string networkText: "⚠"
    property string networkIpText: "IP: —"
    property string ethernetText: ""
    property string ethernetIpText: ""

    function update(process) {
        process.running = false
        process.running = true
    }

    function refreshNetwork() {
        update(networkProcess)
    }

    function parseNetwork(text) {
        var lines = text.replace(/\r/g, "").split("\n")
        networkText = lines[0] || "⚠"
        networkIpText = lines[1] || "IP: —"
        ethernetText = lines[2] || ""
        ethernetIpText = lines[3] || ""
    }

    function parseBattery(text) {
        var lines = text.trim().split("\n")
        batteryText = lines[0] || ""
        batteryTooltip = lines[1] || "Оставшееся время пока неизвестно"
    }

    Process {
        id: clockProcess
        command: ["date", "+%d %b - %H:%M"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.clockText = text.trim() }
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.update(clockProcess) }

    Process {
        id: layoutProcess
        command: ["sh", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main==true) | .active_keymap' | head -n1"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.keyboardLayout = text.trim() || "--" }
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.update(layoutProcess) }

    Process {
        id: volumeProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ printf \"%s  %d%%\", ($3 == \"[MUTED]\" ? \"\" : \"\"), $2 * 100 }'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.volumeText = text.trim() || "  --%" }
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.update(volumeProcess) }

    Process {
        id: cpuProcess
        command: ["sh", "-c", "top -bn1 | awk '/Cpu\\(s\\)/ { printf \"  %d%%\", 100 - $8 }'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.cpuText = text.trim() || "  --%" }
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.update(cpuProcess) }

    Process {
        id: batteryProcess
        command: ["bash", Quickshell.shellPath("battery-info.sh")]
        running: true
        stdout: StdioCollector { onStreamFinished: root.parseBattery(text) }
    }
    Timer { interval: 10000; running: true; repeat: true; onTriggered: root.update(batteryProcess) }

    Process {
        id: temperatureProcess
        command: ["sh", "-c", "sensors 2>/dev/null | awk '/Package id 0:|Tctl:|CPU Temperature:/ { for (i = 1; i <= NF; i++) if ($i ~ /^[+-]?[0-9]+([.][0-9]+)?°C$/) { value = $i; gsub(/[+°C]/, \"\", value); printf \" %.0f°C\", value; exit } }'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.temperatureText = text.trim() || " --°C" }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.update(temperatureProcess) }

    Process {
        id: networkProcess
        command: ["bash", Quickshell.shellPath("network-info.sh")]
        running: true
        stdout: StdioCollector { onStreamFinished: root.parseNetwork(text) }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.update(networkProcess) }
}
