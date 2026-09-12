import QtQuick
import Quickshell

// Month view and the scrollable Obsidian task list.
PopupWindow {
    id: calendarPopup

    required property var barWindow
    required property var taskService

    anchor.window: barWindow
    anchor.rect.x: barWindow.width / 2 - width / 2
    anchor.rect.y: barWindow.height
    implicitWidth: 410
    implicitHeight: 570
    visible: barWindow.calendarVisible
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
        color: "#000000"
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
                    font.pixelSize: 19
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: 34
                    height: 30
                    radius: 7
                    color: previousMouse.containsMouse ? "#292e42" : "transparent"
                    Text { anchors.centerIn: parent; text: "‹"; color: "#bb9af7"; font.pixelSize: 25 }
                    MouseArea { id: previousMouse; anchors.fill: parent; hoverEnabled: true; onClicked: calendarPopup.changeMonth(-1) }
                }
                Rectangle {
                    width: 34
                    height: 30
                    radius: 7
                    color: nextMouse.containsMouse ? "#292e42" : "transparent"
                    Text { anchors.centerIn: parent; text: "›"; color: "#bb9af7"; font.pixelSize: 25 }
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
                        font.pixelSize: 13
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
                        property bool selected: taskService.dateKey(day) === taskService.dateKey(calendarPopup.selectedDate)
                        property int tasksCount: taskService.taskCount(day)
                        color: selected ? "#7aa2f7" : (calendarPopup.isToday(day) ? "#bb9af7" : (day.getMonth() === calendarPopup.shownDate.getMonth() ? "#292e42" : "transparent"))

                        Text {
                            anchors.centerIn: parent
                            text: day.getDate()
                            color: parent.selected || calendarPopup.isToday(parent.day) ? "#16161e" : (parent.day.getMonth() === calendarPopup.shownDate.getMonth() ? "#c0caf5" : "#3b4261")
                            font.family: "JetBrains Mono"
                            font.pixelSize: 15
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
                                font.pixelSize: 9
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
                    font.pixelSize: 15
                    font.bold: true
                }
                Rectangle {
                    width: 94
                    height: 24
                    radius: 7
                    color: todayMouse.containsMouse ? "#292e42" : "transparent"
                    Text { anchors.centerIn: parent; text: "Сегодня"; color: "#7aa2f7"; font.family: "JetBrains Mono"; font.pixelSize: 13 }
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
                        visible: taskService.tasksForDate(calendarPopup.selectedDate).length === 0
                        width: parent.width
                        height: 28
                        text: "На этот день задач нет"
                        color: "#565f89"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }

                    Repeater {
                        model: taskService.taskGroupsForDate(calendarPopup.selectedDate)
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
                                    color: taskService.groupColor(modelData.name)
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 13
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
                                                text: taskService.statusGlyph(modelData.status)
                                                color: taskService.statusColor(modelData.status)
                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 18
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                            }

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 29
                                                text: modelData.title || "Без названия"
                                                color: modelData.done ? "#565f89" : "#c0caf5"
                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 14
                                                font.strikeout: modelData.done
                                                elide: Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton
                                            onClicked: taskService.cycleTaskStatus(modelData)
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
                    text: "󰈙  Открыть в tmux · obsidian"
                    color: "#bb9af7"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                }
                MouseArea {
                    id: openTasksMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.shellPath("open-daily-in-obsidian.sh"),
                        taskService.dailyFile(calendarPopup.selectedDate)
                    ])
                }
            }
        }
    }
}
