// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.components as WorkspaceComponents

import org.kde.komodo.models

MouseArea {
    id: mouseArea

    Layout.minimumWidth: Plasmoid.formFactor === PlasmaCore.Types.Horizontal ? height : Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? width : Kirigami.Units.iconSizes.small + 2 * Kirigami.Units.gridUnit

    hoverEnabled: true

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button == Qt.MiddleButton) {
            plasmoid.launchKomodo(todoModel.filePath);
        } else {
            root.expanded = !root.expanded;
        }
    }

    Kirigami.Icon {
        source: Plasmoid.icon
        active: mouseArea.containsMouse

        anchors.fill: parent

        WorkspaceComponents.BadgeOverlay {
            id: badge

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            
            property int numIncompleteTasks: 0

            visible: root.isLoaded && plasmoid.configuration.showBadge && numIncompleteTasks > 0

            Component.onCompleted: countIncompleteTasks();

            Connections {
                target: todoModel

                function onFilePathChanged() {
                    badge.countIncompleteTasks();
                }

                function onDataChanged() {
                    badge.countIncompleteTasks();
                }
            }

            Connections {
                target: filteredModel

                function onPrimaryFilterChanged() {
                    badge.countIncompleteTasks();
                }
            }

            function countIncompleteTasks() {
                numIncompleteTasks = 0;
                for (let i = 0; i < todoModel.rowCount(); i++) {
                    const item = todoModel.index(i, 0);

                    if (!filteredModel.itemMatchesPrimaryFilter(item))
                        continue;

                    if (todoModel.data(item, TodoModel.CompletionRole))
                        continue;

                    numIncompleteTasks++;
                }
            }

            text: numIncompleteTasks.toString()
            icon: parent
        }
    }
}
