import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

// System values used by the bar.
Item {
    id: root
    visible: false

    property int workspaceRevision: 0
    property string clockText: Qt.formatDateTime(systemClock.date, "dd MMM - HH:mm")
    property string keyboardLayout: "--"
    readonly property var audioSink: Pipewire.defaultAudioSink
    property string volumeText: volumeTextFor(audioSink)
    property string cpuText: "  --%"
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    property int connectedBluetoothDevices: connectedBluetoothDeviceCount()
    property string bluetoothState: bluetoothStateFor(bluetoothAdapter, connectedBluetoothDevices)
    property string bluetoothText: bluetoothTextFor(bluetoothState, connectedBluetoothDevices)
    readonly property var batteryDevice: UPower.displayDevice
    property string batteryText: batteryTextFor(batteryDevice)
    property string batteryTooltip: batteryTooltipFor(batteryDevice)
    property bool lowBatteryCheckPending: false
    property int lastCheckedBatteryCapacity: -1
    property int lastCheckedBatteryState: -1
    property string temperatureText: " --°C"
    readonly property var wifiDevice: networkDevice(DeviceType.Wifi)
    readonly property var ethernetDevice: networkDevice(DeviceType.Wired)
    readonly property var wifiNetwork: connectedNetwork(wifiDevice)
    property var ipv4ByDevice: ({})
    property bool networkRefreshPending: false
    property string networkText: wifiTextFor(wifiDevice, wifiNetwork)
    property string networkIpText: wifiIpTextFor(wifiDevice, wifiNetwork)
    property string ethernetText: ethernetDevice && ethernetDevice.connected ? "󰈀" : ""
    property string ethernetIpText: ethernetIpTextFor(ethernetDevice)

    function update(process) {
        process.running = false
        process.running = true
    }

    function refreshNetwork() {
        if (networkAddressProcess.running) {
            networkRefreshPending = true
            return
        }

        networkAddressProcess.running = true
    }

    function parseInitialKeyboardLayout(text) {
        try {
            var devices = JSON.parse(text)
            var keyboards = devices.keyboards || []
            for (var i = 0; i < keyboards.length; ++i) {
                if (keyboards[i].main) {
                    keyboardLayout = keyboards[i].active_keymap || "--"
                    return
                }
            }
        } catch (error) {
            console.warn("Unable to read the initial keyboard layout:", error)
        }

        keyboardLayout = "--"
    }

    function handleHyprlandEvent(event) {
        if (event.name !== "activelayout")
            return

        var fields = event.parse(2)
        if (fields.length >= 2 && fields[1])
            keyboardLayout = fields[1]
    }

    function volumeTextFor(sink) {
        if (!sink || !sink.ready || !sink.audio)
            return "  --%"

        var icon = sink.audio.muted ? "󰖁" : ""
        return icon + "  " + Math.round(sink.audio.volume * 100) + "%"
    }

    function toggleBluetooth() {
        if (!bluetoothAdapter
                || bluetoothAdapter.state === BluetoothAdapterState.Enabling
                || bluetoothAdapter.state === BluetoothAdapterState.Disabling)
            return

        bluetoothAdapter.enabled = !bluetoothAdapter.enabled
    }

    function connectedBluetoothDeviceCount() {
        var adapter = bluetoothAdapter
        var devices = Bluetooth.devices.values
        var count = 0

        for (var i = 0; i < devices.length; ++i) {
            if (devices[i].adapter === adapter && devices[i].connected)
                count++
        }

        return count
    }

    function bluetoothStateFor(adapter, connectedCount) {
        if (!adapter)
            return "missing"
        if (!adapter.enabled)
            return "off"
        return connectedCount > 0 ? "connected" : "on"
    }

    function bluetoothTextFor(state, connectedCount) {
        if (state === "missing")
            return ""
        if (state === "off")
            return "󰂲"
        return connectedCount > 0 ? "  " + connectedCount : ""
    }

    function networkDevice(type) {
        var devices = Networking.devices.values
        var fallback = null

        for (var i = 0; i < devices.length; ++i) {
            if (devices[i].type !== type)
                continue
            if (devices[i].connected)
                return devices[i]
            if (!fallback)
                fallback = devices[i]
        }

        return fallback
    }

    function connectedNetwork(device) {
        if (!device)
            return null

        var networks = device.networks.values
        for (var i = 0; i < networks.length; ++i) {
            if (networks[i].connected)
                return networks[i]
        }

        return null
    }

    function wifiSignalPercent(network) {
        if (!network)
            return 0
        var strength = network.signalStrength
        return Math.max(0, Math.min(100, Math.round(strength <= 1 ? strength * 100 : strength)))
    }

    function wifiTextFor(device, network) {
        if (!device || !device.connected || !network)
            return "⚠"
        return "  " + wifiSignalPercent(network) + "%"
    }

    function wifiIpTextFor(device, network) {
        if (!device || !device.connected || !network)
            return "IP: —"
        var cidr = ipv4ByDevice[device.name] || "IP —"
        return " " + device.name + " @ " + network.name + ": " + cidr
    }

    function ethernetIpTextFor(device) {
        if (!device || !device.connected)
            return ""
        var cidr = ipv4ByDevice[device.name] || "IP —"
        return device.name + ": " + cidr
    }

    function parseNetworkAddresses(text) {
        var addresses = {}

        try {
            var links = JSON.parse(text)
            for (var i = 0; i < links.length; ++i) {
                var entries = links[i].addr_info || []
                for (var j = 0; j < entries.length; ++j) {
                    if (entries[j].family === "inet" && entries[j].scope === "global") {
                        addresses[links[i].ifname] = entries[j].local + "/" + entries[j].prefixlen
                        break
                    }
                }
            }
        } catch (error) {
            console.warn("Unable to read IPv4 addresses:", error)
        }

        ipv4ByDevice = addresses
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

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Process {
        id: layoutProcess
        command: ["hyprctl", "devices", "-j"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.parseInitialKeyboardLayout(text) }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) { root.handleHyprlandEvent(event) }
    }

    PwObjectTracker {
        objects: [root.audioSink]
    }

    Process {
        id: cpuProcess
        command: ["sh", "-c", "top -bn1 | awk '/Cpu\\(s\\)/ { printf \"  %d%%\", 100 - $8 }'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.cpuText = text.trim() || "  --%" }
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.update(cpuProcess) }

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
        id: networkAddressProcess
        command: ["ip", "-j", "-4", "address", "show", "scope", "global"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.parseNetworkAddresses(text) }

        onExited: {
            if (root.networkRefreshPending) {
                root.networkRefreshPending = false
                Qt.callLater(root.refreshNetwork)
            }
        }
    }

    Process {
        command: ["ip", "-4", "monitor", "address"]
        running: true
        stdout: SplitParser { onRead: networkRefreshDelay.restart() }
    }

    Timer {
        id: networkRefreshDelay
        interval: 150
        repeat: false
        onTriggered: root.refreshNetwork()
    }
}
