import QtQuick
import Quickshell
import Quickshell.Io

// Reads Obsidian dailies on demand and writes status changes back to their source file.
Item {
    id: root
    visible: false

    property string tasksDirectory: Quickshell.env("QS_DAILIES_DIR") || "/home/aragami3070/ObsidianWorkSpace/Obsidian/dailies"
    property var calendarTasks: []
    property var dailyFiles: ({})
    property var statusOrder: [" ", "x", ">", "-", "!", "i"]

    function refresh() {
        tasksProcess.running = false
        tasksProcess.running = true
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

        taskStatusProcess.exec([
            "bash",
            Quickshell.shellPath("update-task-status.sh"),
            task.file,
            String(task.line),
            nextStatus(task.status)
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

    Process {
        id: tasksProcess
        command: ["bash", Quickshell.shellPath("read-dailies.sh"), root.tasksDirectory]
        stdout: StdioCollector { onStreamFinished: root.parseTasks(text) }
    }

    Process {
        id: taskStatusProcess
        onExited: root.refresh()
    }
}
