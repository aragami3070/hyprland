import QtQuick
import Quickshell
import Quickshell.Hyprland

// The visible top bar and its mouse bindings.
PanelWindow {
    id: bar

    required property var modelData
    required property var systemData
    required property var taskService

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
        var revision = systemData.workspaceRevision
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
            text: systemData.clockText
            color: "#bb9af7"
            font.family: "JetBrains Mono"
            font.pixelSize: 17
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    taskService.refresh()
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
            Text { text: systemData.keyboardLayout; color: "#e0af68"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
            Text { text: systemData.volumeText; color: "#f7768e"; font.family: "JetBrains Mono"; font.pixelSize: 16; MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["pavucontrol"]) } }
            Text { text: systemData.cpuText; color: "#ff9e64"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
            Text { text: systemData.batteryText; color: "#9ece6a"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
            Text { text: systemData.memoryText; color: "#9ece6a"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
            Text {
                id: networkModule
                text: systemData.networkText
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
            Text { text: systemData.temperatureText; color: "#7dcfff"; font.family: "JetBrains Mono"; font.pixelSize: 16 }
        }
    }

    CalendarPopup {
        id: calendarPopup
        barWindow: bar
        taskService: bar.taskService
    }
}
