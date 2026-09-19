import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// System values used by the bar.
Item {
    id: root
    visible: false

    property int workspaceRevision: 0
    property string clockText: Qt.formatDateTime(systemClock.date, "dd MMM - HH:mm")
    property string keyboardLayout: "--"
    property string volumeText: "  --%"
    property string cpuText: "  --%"
    property string bluetoothState: "missing"
    property string bluetoothText: ""
    readonly property var batteryDevice: UPower.displayDevice
    property string batteryText: batteryTextFor(batteryDevice)
    property string batteryTooltip: batteryTooltipFor(batteryDevice)
    property bool lowBatteryCheckPending: false
    property int lastCheckedBatteryCapacity: -1
    property int lastCheckedBatteryState: -1
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

    function refreshBluetooth() {
        update(bluetoothProcess)
    }

    function toggleBluetooth() {
        if (bluetoothState === "missing" || bluetoothToggleProcess.running)
            return

        var nextPower = bluetoothState === "off" ? "on" : "off"
        bluetoothToggleProcess.command = ["bluetoothctl", "power", nextPower]
        bluetoothToggleProcess.running = true
    }

    function parseNetwork(text) {
        var lines = text.replace(/\r/g, "").split("\n")
        networkText = lines[0] || "⚠"
        networkIpText = lines[1] || "IP: —"
        ethernetText = lines[2] || ""
        ethernetIpText = lines[3] || ""
    }

    function formatDuration(seconds) {
        var totalMinutes = Math.max(0, Math.round(seconds / 60))
        var days = Math.floor(totalMinutes / 1440)
        var hours = Math.floor((totalMinutes % 1440) / 60)
        var minutes = totalMinutes % 60

        if (days > 0)
            return days + " д " + hours + " ч"
        if (hours > 0)
            return hours + " ч " + minutes + " мин"
        return minutes + " мин"
    }

    function batteryCapacity(device) {
        if (!device)
            return 0
        return Math.max(0, Math.min(100, Math.round(device.percentage * 100)))
    }

    function batteryTextFor(device) {
        if (!device || !device.ready || !device.isPresent)
            return "  --%"

        var capacity = batteryCapacity(device)
        var icon = ""
        if (device.state === UPowerDeviceState.Charging)
            icon = ""
        else if (capacity < 20)
            icon = ""
        else if (capacity < 40)
            icon = ""
        else if (capacity < 60)
            icon = ""
        else if (capacity < 80)
            icon = ""

        return icon + "  " + capacity + "%"
    }

    function batteryTooltipFor(device) {
        if (!device || !device.ready || !device.isPresent)
            return "Батарея не найдена"

        if (device.state === UPowerDeviceState.FullyCharged)
            return "Батарея полностью заряжена"

        if (device.state === UPowerDeviceState.Discharging) {
            if (device.timeToEmpty > 0)
                return "Осталось примерно " + formatDuration(device.timeToEmpty)
            return "Оставшееся время пока неизвестно"
        }

        if (device.state === UPowerDeviceState.Charging) {
            if (device.timeToFull > 0)
                return "До полного заряда примерно " + formatDuration(device.timeToFull)
            return "Время до полного заряда пока неизвестно"
        }

        return "Состояние: " + UPowerDeviceState.toString(device.state)
    }

    function requestLowBatteryCheck() {
        if (!batteryDevice || !batteryDevice.ready)
            return

        var capacity = batteryCapacity(batteryDevice)
        var state = batteryDevice.state
        if (capacity === lastCheckedBatteryCapacity && state === lastCheckedBatteryState)
            return

        if (lowBatteryProcess.running) {
            lowBatteryCheckPending = true
            return
        }

        lastCheckedBatteryCapacity = capacity
        lastCheckedBatteryState = state
        lowBatteryProcess.running = true
    }

    function parseBluetooth(text) {
        var lines = text.replace(/\r/g, "").split("\n")
        bluetoothState = lines[0] || "missing"
        bluetoothText = lines[1] || ""
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

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
        id: bluetoothProcess
        command: ["bash", Quickshell.shellPath("bluetooth-info.sh")]
        running: true
        stdout: StdioCollector { onStreamFinished: root.parseBluetooth(text) }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.update(bluetoothProcess) }

    Process {
        id: bluetoothToggleProcess
        onExited: bluetoothRefreshAfterToggle.restart()
    }

    Timer {
        id: bluetoothRefreshAfterToggle
        interval: 300
        repeat: false
        onTriggered: root.refreshBluetooth()
    }

    Connections {
        target: root.batteryDevice

        function onReadyChanged() { root.requestLowBatteryCheck() }
        function onPercentageChanged() { root.requestLowBatteryCheck() }
        function onStateChanged() { root.requestLowBatteryCheck() }
    }

    Process {
        id: lowBatteryProcess
        command: ["systemctl", "--user", "start", "low-battery-notifier.service"]

        onExited: {
            if (root.lowBatteryCheckPending) {
                root.lowBatteryCheckPending = false
                Qt.callLater(root.requestLowBatteryCheck)
            }
        }
    }

    Component.onCompleted: requestLowBatteryCheck()

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
