// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import org.kde.komodo.models

PlasmoidItem {
    id: root

    property bool isLoaded: todoModel.filePath != ""

    readonly property bool inPanel: [
        PlasmaCore.Types.TopEdge,
        PlasmaCore.Types.RightEdge,
        PlasmaCore.Types.BottomEdge,
        PlasmaCore.Types.LeftEdge,
    ].includes(Plasmoid.location)

    Plasmoid.icon: inPanel ? "story-editor" : "org.kde.komodo"

    toolTipMainText: i18nc("@info:tooltip title, shown on hover", "KomoDo Tasks")
    toolTipSubText: i18nc("@info:tooltip description, shown on hover", "Manage your tasks at a glance")

    function loadFileIfExists() {
        if (!todoModel.fileExists()) {
            todoModel.filePath = "";
        } else {
            todoModel.loadFile();
        }
    }

    Connections {
        target: Plasmoid.configuration

        function onFilePathChanged() {
            todoModel.filePath = Plasmoid.configuration.filePath;
            loadFileIfExists();
        }
    }

    TodoFilterProxyModel {
        id: filteredModel

        sourceModel: TodoModel {
            id: todoModel

            filePath: Plasmoid.configuration.filePath

            onFileChanged: {
                loadFileIfExists();
            }

            Component.onCompleted: {
                loadFileIfExists();
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            id: manageAction
            text: i18nc("@action:inmenu Open the KomoDo app", "Manage Tasks…")
            icon.name: "story-editor"
            visible: isLoaded
            onTriggered: plasmoid.launchKomodo(todoModel.filePath)
        }
    ]

    compactRepresentation: CompactRepresentation { }
    fullRepresentation: FullRepresentation { }
}
