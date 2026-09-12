import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// The visible top bar and its mouse bindings.
PanelWindow {
    id: bar

    required property var modelData
    required property var systemData
    required property var taskService
    required property bool autoHide

    screen: modelData
    color: "transparent"
    implicitHeight: 32
    exclusiveZone: autoHide ? 0 : 32
    WlrLayershell.layer: autoHide ? WlrLayer.Overlay : WlrLayer.Bottom

    property string monitorName: modelData.name
    property var hyprMonitor: Hyprland.monitorFor(modelData)
    property bool calendarVisible: false
    property bool cpuPopupVisible: false
    property bool networkShowsIp: false
    property bool ethernetShowsIp: false
    property bool revealHold: false
    property bool batteryTooltipVisible: false
    property string barFont: "UbuntuMono Nerd Font"
    readonly property bool pinnedPopupVisible: calendarVisible || cpuPopupVisible
    readonly property bool revealed: !autoHide || revealHold || pinnedPopupVisible

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: autoHide ? (revealed ? 0 : -30) : 2
        left: 10
        right: 10
    }

    Behavior on margins.top {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: revealHover

        onHoveredChanged: {
            if (hovered) {
                hideTimer.stop()
                bar.revealHold = true
            } else if (!bar.pinnedPopupVisible) {
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 10
        repeat: false
        onTriggered: {
            if (!revealHover.hovered && !bar.pinnedPopupVisible)
                bar.revealHold = false
        }
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

    function fontScale(pixelSize) {
        return (pixelSize + 0.5) / pixelSize
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        radius: 13
        border.color: "#292e42"
        border.width: 1
        opacity: bar.revealed ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }

        Row {
            id: leftModules
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                text: ""
                color: "#bb9af7"
                font.family: bar.barFont
                font.pixelSize: 18
                scale: bar.fontScale(18)
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
                        font.family: bar.barFont
                        font.pixelSize: 16
                        scale: bar.fontScale(16)
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
            font.family: bar.barFont
            font.pixelSize: 17
            scale: bar.fontScale(17)
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bar.cpuPopupVisible = false
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
            Text { text: systemData.keyboardLayout; color: "#e0af68"; font.family: bar.barFont; font.pixelSize: 16; scale: bar.fontScale(16) }
            Text { text: systemData.volumeText; color: "#f7768e"; font.family: bar.barFont; font.pixelSize: 16; scale: bar.fontScale(16); MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["pavucontrol"]) } }
            Text {
                id: cpuModule
                text: systemData.cpuText
                color: "#ff9e64"
                font.family: bar.barFont
                font.pixelSize: 16
                scale: bar.fontScale(16)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        bar.calendarVisible = false
                        bar.cpuPopupVisible = !bar.cpuPopupVisible
                    }
                }
            }
            Text {
                id: batteryModule
                text: systemData.batteryText
                color: "#9ece6a"
                font.family: bar.barFont
                font.pixelSize: 16
                scale: bar.fontScale(16)

                HoverHandler {
                    id: batteryHover
                    onHoveredChanged: {
                        if (hovered)
                            batteryTooltipDelay.restart()
                        else {
                            batteryTooltipDelay.stop()
                            bar.batteryTooltipVisible = false
                        }
                    }
                }

                Timer {
                    id: batteryTooltipDelay
                    interval: 250
                    repeat: false
                    onTriggered: bar.batteryTooltipVisible = batteryHover.hovered
                }
            }
            Text {
                id: networkModule
                text: bar.networkShowsIp ? systemData.networkIpText : systemData.networkText
                color: "#e0af68"
                font.family: bar.barFont
                font.pixelSize: 16
                scale: bar.fontScale(16)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton)
                            Quickshell.execDetached(["networkmanager_dmenu"])
                        else {
                            systemData.refreshNetwork()
                            bar.networkShowsIp = !bar.networkShowsIp
                        }
                    }
                }
            }
            Text {
                id: ethernetModule
                visible: systemData.ethernetText.length > 0
                text: bar.ethernetShowsIp ? systemData.ethernetIpText : systemData.ethernetText
                color: "#73daca"
                font.family: bar.barFont
                font.pixelSize: 16
                scale: bar.fontScale(16)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton)
                            Quickshell.execDetached(["networkmanager_dmenu"])
                        else {
                            systemData.refreshNetwork()
                            bar.ethernetShowsIp = !bar.ethernetShowsIp
                        }
                    }
                }
            }
            Text { text: systemData.temperatureText; color: "#7dcfff"; font.family: bar.barFont; font.pixelSize: 16; scale: bar.fontScale(16) }
        }
    }

    CalendarPopup {
        id: calendarPopup
        barWindow: bar
        taskService: bar.taskService
    }

    CpuPopup {
        barWindow: bar
        anchorItem: cpuModule
        visible: bar.cpuPopupVisible

        onClosed: bar.cpuPopupVisible = false
    }

    LazyLoader {
        active: bar.batteryTooltipVisible

        BatteryTooltip {
            barWindow: bar
            anchorItem: batteryModule
            tooltipText: systemData.batteryTooltip
            visible: true

            onClosed: bar.batteryTooltipVisible = false
        }
    }
}
