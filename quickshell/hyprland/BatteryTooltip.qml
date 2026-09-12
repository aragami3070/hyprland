import QtQuick
import Quickshell

// Separate popup surface so the tooltip is not clipped by the 32px panel window.
PopupWindow {
    id: tooltip

    required property var barWindow
    required property var anchorItem
    required property string tooltipText

    anchor.window: barWindow
    anchor.rect.x: Math.max(8, Math.min(
        barWindow.width - implicitWidth - 8,
        anchorItem.mapToItem(null, 0, 0).x + anchorItem.width / 2 - implicitWidth / 2
    ))
    anchor.rect.y: barWindow.height + 4
    implicitWidth: Math.max(190, label.implicitWidth + 24)
    implicitHeight: 38
    color: "transparent"
    grabFocus: false

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        radius: 8
        border.color: "#292e42"
        border.width: 1

        Text {
            id: label
            anchors.centerIn: parent
            text: tooltip.tooltipText
            color: "#c0caf5"
            font.family: "UbuntuMono Nerd Font"
            font.pixelSize: 15
        }
    }
}
