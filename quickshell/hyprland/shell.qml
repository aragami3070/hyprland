import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Entry point: shared services are created once, the bar is created per monitor.
Scope {
    id: root

    property bool autoHide: true

    SystemData {
        id: system
    }

    TaskService {
        id: tasks
    }

    Connections {
        target: Hyprland
        function onRawEvent() { system.workspaceRevision++ }
    }

    IpcHandler {
        target: "bar"

        function toggleMode(): void {
            root.autoHide = !root.autoHide
        }

        function mode(): string {
            return root.autoHide ? "autohide" : "always"
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            systemData: system
            taskService: tasks
            autoHide: root.autoHide
        }
    }
}
