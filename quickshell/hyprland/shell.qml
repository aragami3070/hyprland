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
    property string tasksDirectory: Quickshell.env("QS_DAILIES_DIR") || "/home/aragami3070/ObsidianWorkSpace/Obsidian/dailies"
    property var calendarTasks: []
    property var dailyFiles: ({})
    property var statusOrder: [" ", "x", ">", "-", "!", "i"]

    function update(process) {
        process.running = false
        process.running = true
    }

    function dateKey(day) {
        var month = String(day.getMonth() + 1).padStart(2, "0")
        var date = String(day.getDate()).padStart(2, "0")
        return day.getFullYear() + "-" + month + "-" + date
    }

    function tasksForDate(day) {
        var key = dateKey(day)
        return calendarTasks.filter(function(task) { return task.date === key })
    }

    function taskCount(day) {
        return tasksForDate(day).length
    }

    function groupLabel(group) {
        var labels = {
            "Main tasks": "Главные задачи",
            "Quick tasks": "Быстрые задачи",
            "Others tasks": "Другие задачи",
            "Unforeseen": "Непредвиденные",
            "Thoughts|Ideas": "Мысли и идеи"
        }
        return labels[group] || group
    }

    function groupColor(group) {
        var colors = {
            "Main tasks": "#7aa2f7",
            "Quick tasks": "#9ece6a",
            "Others tasks": "#e0af68",
            "Unforeseen": "#f7768e",
            "Thoughts|Ideas": "#bb9af7"
        }
        return colors[group] || "#565f89"
    }

    function taskGroupsForDate(day) {
        var groups = []
        var positions = {}
        var tasks = tasksForDate(day)

        for (var i = 0; i < tasks.length; ++i) {
            var name = tasks[i].group || "Other"
            if (positions[name] === undefined) {
                positions[name] = groups.length
                groups.push({ name: name, label: groupLabel(name), tasks: [] })
            }
            groups[positions[name]].tasks.push(tasks[i])
        }

        return groups
    }

    function statusGlyph(status) {
        var glyphs = {
            " ": "󰄱",
            "x": "✔",
            ">": "➣",
            "-": "✗",
            "!": "⚠︎",
            "i": "𝐢"
        }
        return glyphs[status] || "󰄱"
    }

    function statusColor(status) {
        var colors = {
            " ": "#f78c6c",
            "x": "#89ddff",
            ">": "#f78c6c",
            "-": "#ff5370",
            "!": "#d73128",
            "i": "#80ff80"
        }
        return colors[status] || "#f78c6c"
    }

    function nextStatus(status) {
        var index = statusOrder.indexOf(status)
        return statusOrder[(index + 1) % statusOrder.length]
    }

    function cycleTaskStatus(task) {
        if (!task.file || !task.line || taskStatusProcess.running)
            return

        var next = nextStatus(task.status)
        taskStatusProcess.exec([
            "bash",
            Quickshell.shellPath("update-task-status.sh"),
            task.file,
            String(task.line),
            next
        ])
    }

    function dailyFile(day) {
        return dailyFiles[dateKey(day)] || tasksDirectory
    }

    function parseTasks(markdown) {
        var parsed = []
        var sectionDate = ""
        var fileDate = ""
        var currentFile = ""
        var taskGroup = "Other"
        var fileLine = 0
        var files = {}
        var lines = markdown.split("\n")

        for (var i = 0; i < lines.length; ++i) {
            var fileMarker = lines[i].match(/^@@QS_FILE@@(.+)$/)
            if (fileMarker) {
                currentFile = fileMarker[1]
                var fileMatch = currentFile.match(/(?:^|\/)(\d{4}-\d{2}-\d{2})\.md$/)
                fileDate = fileMatch ? fileMatch[1] : ""
                sectionDate = ""
                taskGroup = "Other"
                fileLine = 0
                if (fileDate)
                    files[fileDate] = currentFile
                continue
            }

            fileLine++

            var heading = lines[i].match(/^#{1,6}\s+(\d{4}-\d{2}-\d{2})(?:\s|$)/)
            if (heading)
                sectionDate = heading[1]

            var groupHeading = lines[i].match(/^\s*📝\s*(.+?):\s*$/)
            if (groupHeading)
                taskGroup = groupHeading[1].trim()

            var match = lines[i].match(/^\s*[-*+]\s+\[([^\]])\](?:\s+(.*))?$/)
            if (!match)
                continue

            var body = match[2] || ""
            var dateMatch = body.match(/📅\s*(\d{4}-\d{2}-\d{2})/)
                || body.match(/⏳\s*(\d{4}-\d{2}-\d{2})/)
                || body.match(/(?:^|\s)(\d{4}-\d{2}-\d{2})(?:\s|$)/)
            var taskDate = dateMatch ? dateMatch[1] : (sectionDate || fileDate)
            if (!taskDate)
                continue

            var title = body
                .replace(/[📅⏳🛫]\s*\d{4}-\d{2}-\d{2}/g, "")
                .replace(/^\d{4}-\d{2}-\d{2}\s*/, "")
                .trim()

            parsed.push({
                date: taskDate,
                title: title,
                group: taskGroup,
                status: match[1],
                done: match[1].toLowerCase() === "x",
                file: currentFile,
                line: fileLine
            })
        }

        dailyFiles = files
        calendarTasks = parsed
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
        id: tasksProcess
        command: ["bash", Quickshell.shellPath("read-dailies.sh"), root.tasksDirectory]
        running: true
        stdout: StdioCollector { onStreamFinished: root.parseTasks(text) }
    }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.update(tasksProcess) }

    Process {
        id: taskStatusProcess
        onExited: root.update(tasksProcess)
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
                            root.update(tasksProcess)
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
                    implicitWidth: 410
                    implicitHeight: 570
                    visible: bar.calendarVisible
                    grabFocus: true
                    property date shownDate: new Date()
                    property date selectedDate: new Date()
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
                            spacing: 10

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
                                height: 210
                                columns: 7
                                rows: 6
                                columnSpacing: 4
                                rowSpacing: 3

                                Repeater {
                                    model: 42
                                    delegate: Rectangle {
                                        required property int index
                                        width: (parent.width - 24) / 7
                                        height: 32
                                        radius: 8
                                        property date day: {
                                            var first = new Date(calendarPopup.shownDate.getFullYear(), calendarPopup.shownDate.getMonth(), 1)
                                            var mondayOffset = (first.getDay() + 6) % 7
                                            return new Date(calendarPopup.shownDate.getFullYear(), calendarPopup.shownDate.getMonth(), index + 1 - mondayOffset)
                                        }
                                        property bool selected: root.dateKey(day) === root.dateKey(calendarPopup.selectedDate)
                                        property int tasksCount: root.taskCount(day)
                                        color: selected ? "#7aa2f7" : (calendarPopup.isToday(day) ? "#bb9af7" : (day.getMonth() === calendarPopup.shownDate.getMonth() ? "#292e42" : "transparent"))

                                        Text {
                                            anchors.centerIn: parent
                                            text: day.getDate()
                                            color: parent.selected || calendarPopup.isToday(parent.day) ? "#16161e" : (parent.day.getMonth() === calendarPopup.shownDate.getMonth() ? "#c0caf5" : "#3b4261")
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 14
                                            font.bold: parent.selected || calendarPopup.isToday(parent.day)
                                        }

                                        Rectangle {
                                            visible: parent.tasksCount > 0
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            anchors.margins: 3
                                            width: 13
                                            height: 13
                                            radius: 7
                                            color: parent.selected ? "#16161e" : "#9ece6a"
                                            Text {
                                                anchors.centerIn: parent
                                                text: parent.parent.tasksCount > 9 ? "9+" : parent.parent.tasksCount
                                                color: parent.parent.selected ? "#7aa2f7" : "#16161e"
                                                font.pixelSize: 8
                                                font.bold: true
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: calendarPopup.selectedDate = parent.day
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#292e42"
                            }

                            Row {
                                width: parent.width
                                height: 25
                                Text {
                                    width: parent.width - 94
                                    text: Qt.formatDate(calendarPopup.selectedDate, "dddd, d MMMM")
                                    color: "#c0caf5"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Rectangle {
                                    width: 94
                                    height: 24
                                    radius: 7
                                    color: todayMouse.containsMouse ? "#292e42" : "transparent"
                                    Text { anchors.centerIn: parent; text: "Сегодня"; color: "#7aa2f7"; font.family: "JetBrains Mono"; font.pixelSize: 12 }
                                    MouseArea {
                                        id: todayMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            calendarPopup.shownDate = new Date()
                                            calendarPopup.selectedDate = new Date()
                                        }
                                    }
                                }
                            }

                            Flickable {
                                id: taskScroller
                                width: parent.width
                                height: 150
                                clip: true
                                contentWidth: width
                                contentHeight: taskList.height
                                interactive: true
                                flickableDirection: Flickable.VerticalFlick
                                boundsBehavior: Flickable.StopAtBounds

                                Column {
                                    id: taskList
                                    width: taskScroller.width
                                    spacing: 5

                                    Text {
                                        visible: root.tasksForDate(calendarPopup.selectedDate).length === 0
                                        width: parent.width
                                        height: 28
                                        text: "На этот день задач нет"
                                        color: "#565f89"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 13
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Repeater {
                                        model: root.taskGroupsForDate(calendarPopup.selectedDate)
                                        delegate: Column {
                                            required property var modelData
                                            width: taskList.width
                                            spacing: 4

                                            Rectangle {
                                                width: parent.width
                                                height: 24
                                                radius: 6
                                                color: "#1f2335"

                                                Text {
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 9
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modelData.label + "  ·  " + modelData.tasks.length
                                                    color: root.groupColor(modelData.name)
                                                    font.family: "JetBrains Mono"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }
                                            }

                                            Column {
                                                id: groupTasks
                                                width: parent.width
                                                spacing: 4

                                                Repeater {
                                                    model: modelData.tasks
                                                    delegate: Item {
                                                        required property var modelData
                                                        width: groupTasks.width
                                                        height: 26

                                                        Row {
                                                            anchors.fill: parent
                                                            spacing: 9

                                                            Text {
                                                                width: 20
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                text: root.statusGlyph(modelData.status)
                                                                color: root.statusColor(modelData.status)
                                                                font.family: "JetBrains Mono"
                                                                font.pixelSize: 17
                                                                font.bold: true
                                                                horizontalAlignment: Text.AlignHCenter
                                                            }

                                                            Text {
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                width: parent.width - 29
                                                                text: modelData.title || "Без названия"
                                                                color: modelData.done ? "#565f89" : "#c0caf5"
                                                                font.family: "JetBrains Mono"
                                                                font.pixelSize: 13
                                                                font.strikeout: modelData.done
                                                                elide: Text.ElideRight
                                                            }
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            acceptedButtons: Qt.LeftButton
                                                            onClicked: root.cycleTaskStatus(modelData)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: taskScroller.contentHeight > taskScroller.height
                                    anchors.right: parent.right
                                    y: taskScroller.contentHeight > taskScroller.height
                                        ? taskScroller.contentY / (taskScroller.contentHeight - taskScroller.height) * (taskScroller.height - height)
                                        : 0
                                    width: 3
                                    height: Math.max(24, taskScroller.height * taskScroller.height / taskScroller.contentHeight)
                                    radius: 2
                                    color: "#7aa2f7"
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 28
                                radius: 8
                                color: openTasksMouse.containsMouse ? "#292e42" : "#1f2335"
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰈙  Открыть daily note"
                                    color: "#bb9af7"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 12
                                }
                                MouseArea {
                                    id: openTasksMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Quickshell.execDetached(["xdg-open", root.dailyFile(calendarPopup.selectedDate)])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
