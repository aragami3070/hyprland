import QtQuick
import Quickshell
import Quickshell.Io

// Compact live view of total and per-logical-core CPU utilization.
PopupWindow {
    id: popup

    required property var barWindow
    required property var anchorItem

    property int totalLoad: 0
    property var coreLoads: []

    anchor.window: barWindow
    anchor.rect.x: Math.max(8, Math.min(
        barWindow.width - implicitWidth - 8,
        anchorItem.mapToItem(null, 0, 0).x + anchorItem.width / 2 - implicitWidth / 2
    ))
    anchor.rect.y: barWindow.height + 4
    implicitWidth: 340
    implicitHeight: 102 + Math.ceil(coreLoads.length / 2) * 27
    color: "transparent"
    grabFocus: true

    function refresh() {
        if (!cpuProcess.running)
            cpuProcess.running = true
    }

    function parseLoads(text) {
        var lines = text.trim().split("\n")
        var nextCores = []

        for (var i = 0; i < lines.length; ++i) {
            var parts = lines[i].trim().split(/\s+/)
            if (parts.length < 2)
                continue

            var load = Math.max(0, Math.min(100, Number(parts[1])))
            if (parts[0] === "all")
                totalLoad = load
            else
                nextCores.push({ label: "CPU " + parts[0], load: load })
        }

        coreLoads = nextCores
    }

    Component.onCompleted: refresh()

    onVisibleChanged: {
        if (visible)
            refresh()
    }

    Process {
        id: cpuProcess
        command: ["bash", Quickshell.shellPath("cpu-cores.sh")]
        stdout: StdioCollector { onStreamFinished: popup.parseLoads(text) }
    }

    Timer {
        interval: 1500
        running: popup.visible
        repeat: true
        onTriggered: popup.refresh()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        radius: 13
        border.color: "#292e42"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Row {
                width: parent.width
                height: 20

                Text {
                    width: parent.width - totalText.width
                    text: "Загрузка процессора"
                    color: "#c0caf5"
                    font.family: "UbuntuMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    id: totalText
                    text: popup.totalLoad + "%"
                    color: "#ff9e64"
                    font.family: "UbuntuMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            Rectangle {
                width: parent.width
                height: 7
                radius: 4
                color: "#1a1b26"

                Rectangle {
                    width: parent.width * popup.totalLoad / 100
                    height: parent.height
                    radius: parent.radius
                    color: popup.totalLoad >= 85 ? "#f7768e" : "#ff9e64"

                    Behavior on width { NumberAnimation { duration: 180 } }
                }
            }

            Text {
                height: 18
                text: "Логические ядра"
                color: "#565f89"
                font.family: "UbuntuMono Nerd Font"
                font.pixelSize: 14
            }

            Grid {
                width: parent.width
                columns: 2
                columnSpacing: 14
                rowSpacing: 5

                Repeater {
                    model: popup.coreLoads

                    delegate: Item {
                        required property var modelData
                        width: 149
                        height: 22

                        Text {
                            width: 42
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: "#a9b1d6"
                            font.family: "UbuntuMono Nerd Font"
                            font.pixelSize: 13
                        }

                        Rectangle {
                            x: 45
                            width: 70
                            height: 6
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 3
                            color: "#1a1b26"

                            Rectangle {
                                width: parent.width * modelData.load / 100
                                height: parent.height
                                radius: parent.radius
                                color: modelData.load >= 85 ? "#f7768e" : "#bb9af7"

                                Behavior on width { NumberAnimation { duration: 180 } }
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.load + "%"
                            color: "#c0caf5"
                            font.family: "UbuntuMono Nerd Font"
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
}
