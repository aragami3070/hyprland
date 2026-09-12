import QtQuick
import Quickshell
import Quickshell.Hyprland

// Entry point: shared services are created once, the bar is created per monitor.
Scope {
    id: root

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

    Variants {
        model: Quickshell.screens

        Bar {
            systemData: system
            taskService: tasks
        }
    }
}
