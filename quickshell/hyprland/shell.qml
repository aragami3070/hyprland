import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Waybar replacement for this Hyprland setup.
// The bar is instantiated once for every connected monitor.
Scope {
    id: root

    property int workspaceRevision: 0
    property string clockText: ""
    property string keyboardLayout: "--"
    property string volumeText: "  --%"
    property string cpuText: "  --%"
    property string memoryText: "  --%"
    property string batteryText: "  --%"
    property string temperatureText: "  --°C"
    property string networkText: "⚠"
    property string calendarText: ""

    function update(process) {
        process.running = false
        process.running = true
    }

    // One-shot shell commands keep the dependencies identical to the old Waybar modules.
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
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ printf \"%s %d%%\", ($3 == \"[MUTED]\" ? \"\" : \"\"), $2 * 100 }'"]
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
        id: memoryProcess
        command: ["sh", "-c", "free -m | awk '/Mem:/ { printf \"  %d%%\", ($3 / $2) * 100 }'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.memoryText = text.trim() || "  --%" }
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.update(memoryProcess) }

    Process {
        id: batteryProcess
        command: ["sh", "-c", "capacity=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1); status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1); [ -z \"$capacity\" ] && exit 0; icon=\"\"; [ \"$capacity\" -lt 20 ] && icon=\"\"; [ \"$capacity\" -lt 40 ] && icon=\"\"; [ \"$capacity\" -lt 60 ] && icon=\"\"; [ \"$capacity\" -lt 80 ] && icon=\"\"; [ \"$status\" = Charging ] && icon=\"\"; printf \"%s  %s%%\" \"$icon\" \"$capacity\""]
        running: true
        stdout: StdioCollector { onStreamFinished: root.batteryText = text.trim() || "" }
    }
    Timer { interval: 10000; running: true; repeat: true; onTriggered: root.update(batteryProcess) }

    Process {
        id: temperatureProcess
        command: ["sh", "-c", "sensors 2>/dev/null | awk '/Package id 0:|Tctl:|CPU Temperature:/ { gsub(/[+°C]/, \"\", $3); printf \"  %d°C\", $3; exit }'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.temperatureText = text.trim() || "  --°C" }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.update(temperatureProcess) }

    Process {
        id: networkProcess
        command: ["sh", "-c", "if nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep -q ':wifi:connected'; then printf ''; elif nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep -q ':ethernet:connected'; then printf ''; else printf '⚠'; fi"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.networkText = text.trim() || "⚠" }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.update(networkProcess) }

    Process {
        id: calendarProcess
        command: ["sh", "-c", "cal -m"]
        stdout: StdioCollector { onStreamFinished: root.calendarText = text }
    }

    Connections {
        target: Hyprland
        function onRawEvent() { root.workspaceRevision++ }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: 32
            exclusiveZone: 32

            property string monitorName: modelData.name
            property var hyprMonitor: Hyprland.monitorFor(modelData)
            property bool calendarVisible: false

            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                top: 2
                left: 10
                right: 10
            }

            function workspaceIsActive(id) {
                var revision = root.workspaceRevision
                var list = Hyprland.workspaces.values
                for (var i = 0; i < list.length; ++i) {
                    if (list[i].id === id && list[i].monitor && list[i].monitor.name === monitorName)
                        return list[i].active
                }
                return false
            }

            Rectangle {
                anchors.fill: parent
                color: "#16161e"
                radius: 13
                border.color: "#292e42"
                border.width: 1

                Row {
                    id: leftModules
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        text: ""
                        color: "#bb9af7"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 18
                        MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["wofi", "--show", "drun"]) }
                    }

                    Repeater {
                        model: bar.monitorName === "HDMI-A-1" ? 3 : 9
                        delegate: Rectangle {
                            required property int index
                            width: 25
                            height: 26
                            radius: 6
                            color: bar.workspaceIsActive(index + 1) ? "#bb9af7" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                color: bar.workspaceIsActive(index + 1) ? "#16161e" : "#bb9af7"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 16
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.clockText
                    color: "#bb9af7"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 17
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.update(calendarProcess)
                            bar.calendarVisible = !bar.calendarVisible
                        }
                    }
                }

                Row {
                    id: rightModules
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Text { text: root.keyboardLayout; color: "#e0af68"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                    Text { text: root.volumeText; color: "#f7768e"; font.family: "JetBrains Mono"; font.pixelSize: 16; MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["pavucontrol"]) } }
                    Text { text: root.cpuText; color: "#ff9e64"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                    Text { text: root.batteryText; color: "#9ece6a"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                    Text { text: root.memoryText; color: "#9ece6a"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                    Text {
                        id: networkModule
                        text: root.networkText
                        color: "#e0af68"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 16
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) {
                                if (mouse.button === Qt.RightButton)
                                    Quickshell.execDetached(["networkmanager_dmenu"])
                                else
                                    Quickshell.execDetached(["sh", "-c", "ip -br address show scope global | awk '{print $1 \": \" $3}' | notify-send -i network-wired \"IP addresses\" -"])
                            }
                        }
                    }
                    Text { text: root.temperatureText; color: "#7dcfff"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                }

                PopupWindow {
                    id: calendarPopup
                    anchor.window: bar
                    anchor.rect.x: bar.width / 2 - width / 2
                    anchor.rect.y: bar.height
                    implicitWidth: 340
                    implicitHeight: 365
                    visible: bar.calendarVisible
                    grabFocus: true
                    property date shownDate: new Date()
                    property var weekdays: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

                    function changeMonth(offset) {
                        shownDate = new Date(shownDate.getFullYear(), shownDate.getMonth() + offset, 1)
                    }

                    function isToday(day) {
                        var today = new Date()
                        return day.getFullYear() === today.getFullYear()
                            && day.getMonth() === today.getMonth()
                            && day.getDate() === today.getDate()
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1b26"
                        radius: 13
                        border.color: "#292e42"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Row {
                                width: parent.width
                                height: 30
                                spacing: 8

                                Text {
                                    width: parent.width - 86
                                    text: Qt.formatDate(calendarPopup.shownDate, "MMMM yyyy")
                                    color: "#c0caf5"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 18
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Rectangle {
                                    width: 34
                                    height: 30
                                    radius: 7
                                    color: previousMouse.containsMouse ? "#292e42" : "transparent"
                                    Text { anchors.centerIn: parent; text: "‹"; color: "#bb9af7"; font.pixelSize: 24 }
                                    MouseArea { id: previousMouse; anchors.fill: parent; hoverEnabled: true; onClicked: calendarPopup.changeMonth(-1) }
                                }
                                Rectangle {
                                    width: 34
                                    height: 30
                                    radius: 7
                                    color: nextMouse.containsMouse ? "#292e42" : "transparent"
                                    Text { anchors.centerIn: parent; text: "›"; color: "#bb9af7"; font.pixelSize: 24 }
                                    MouseArea { id: nextMouse; anchors.fill: parent; hoverEnabled: true; onClicked: calendarPopup.changeMonth(1) }
                                }
                            }

                            Row {
                                width: parent.width
                                height: 20
                                spacing: 4
                                Repeater {
                                    model: calendarPopup.weekdays
                                    delegate: Text {
                                        required property string modelData
                                        required property int index
                                        width: (parent.width - 24) / 7
                                        text: modelData
                                        color: index > 4 ? "#f7768e" : "#565f89"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            Grid {
                                width: parent.width
                                height: 252
                                columns: 7
                                rows: 6
                                columnSpacing: 4
                                rowSpacing: 4

                                Repeater {
                                    model: 42
                                    delegate: Rectangle {
                                        required property int index
                                        width: (parent.width - 24) / 7
                                        height: 36
                                        radius: 8
                                        property date day: {
                                            var first = new Date(calendarPopup.shownDate.getFullYear(), calendarPopup.shownDate.getMonth(), 1)
                                            var mondayOffset = (first.getDay() + 6) % 7
                                            return new Date(calendarPopup.shownDate.getFullYear(), calendarPopup.shownDate.getMonth(), index + 1 - mondayOffset)
                                        }
                                        color: calendarPopup.isToday(day) ? "#bb9af7" : (day.getMonth() === calendarPopup.shownDate.getMonth() ? "#292e42" : "transparent")

                                        Text {
                                            anchors.centerIn: parent
                                            text: day.getDate()
                                            color: calendarPopup.isToday(day) ? "#16161e" : (day.getMonth() === calendarPopup.shownDate.getMonth() ? "#c0caf5" : "#3b4261")
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 14
                                            font.bold: calendarPopup.isToday(day)
                                        }
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "Сегодня: " + Qt.formatDate(new Date(), "dd.MM.yyyy")
                                color: "#565f89"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }
    }
}
