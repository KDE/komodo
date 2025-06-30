// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: todoDelegate
    clip: true

    property var todoModel
    property var projects: model.projects
    property var contexts: model.contexts
    property var keyValuePairs: model.keyValuePairs

    header: RowLayout {
        width: parent.width

        QQC2.CheckBox {
            id: completionStatus
            Layout.alignment: Qt.AlignLeft
            checked: model.completion
            onToggled: model.completion = !model.completion
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Task completion status")
        }

        Kirigami.Chip {
            Layout.alignment: Qt.AlignLeft
            visible: model.priority
            text: model.priority
            font.bold: false
            closable: false
            checkable: false
            icon.name: "dialog-layers-symbolic"
            QQC2.ToolTip.visible: down
            QQC2.ToolTip.text: i18n("Task priority")
        }

        Kirigami.Chip {
            visible: model.dueDate
            text: model.dueDate
            font.bold: false
            closable: false
            checkable: false
            icon.name: "notification-active-symbolic"
            QQC2.ToolTip.visible: down
            QQC2.ToolTip.text: i18n("Task due date")
        }

        Item {
            Layout.fillWidth: true
        }

        Kirigami.Chip {
            visible: model.completionDate
            text: model.completionDate
            font.bold: false
            closable: false
            checkable: false
            icon.name: "task-complete-symbolic"
            QQC2.ToolTip.visible: down
            QQC2.ToolTip.text: i18n("Task completion date")
        }
    }

    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        ColumnLayout {
            id: delegateLayout
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            Kirigami.SelectableLabel {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: model.prettyDescription
                font.strikeout: model.completion
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.35
                topPadding: Kirigami.Units.largeSpacing
                leftPadding: Kirigami.Units.smallSpacing
                rightPadding: Kirigami.Units.smallSpacing
                bottomPadding: Kirigami.Units.smallSpacing
            }

            Repeater {
                id: keyValuePairRepeater
                model: keyValuePairs
                RowLayout {
                    property var textData: modelData.split(":")
                    property var textUrl: {
                        let value = "";
                        // Split the value like this in case its URL
                        if (textData[1].startsWith("http") || textData[1].startsWith("file://")) {
                            const url = modelData.split(":").slice(1).join(":");
                            value = url;
                        }
                        return value;
                    }

                    visible: textData[0] == "due" ? false : true

                    Kirigami.SelectableLabel {
                        id: keyLabel
                        text: parent.textData[0] + ":"
                        font.italic: true
                        Layout.alignment: Qt.AlignLeft
                        leftPadding: Kirigami.Units.largeSpacing * 2
                    }

                    Kirigami.SelectableLabel {
                        text: parent.textData[1]
                        wrapMode: Qt.TextWrapAnywhere
                        visible: !textUrl
                        Layout.alignment: Qt.AlignLeft
                        rightPadding: Kirigami.Units.smallSpacing
                    }

                    Kirigami.UrlButton {
                        Layout.maximumWidth: delegateLayout.width - keyLabel.width - Kirigami.Units.largeSpacing * 2 - Kirigami.Units.smallSpacing
                        Layout.alignment: Qt.AlignLeft
                        visible: textUrl
                        wrapMode: Qt.TextWrapAnywhere
                        elide: Text.ElideRight
                        text: textUrl
                        url: textUrl
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitWidth: Kirigami.Units.smallSpacing
                    }
                }
            }
        }
    }

    footer: Kirigami.ActionToolBar {
        id: actionsToolBar
        alignment: Qt.AlignRight
        actions: [
            Kirigami.Action {
                text: i18nc("@button", "Edit")
                icon.name: "edit-entry"
                onTriggered: {
                    editPrompt.text = model.description;
                    editPrompt.model = model;
                    editPrompt.open();
                }
            },
            Kirigami.Action {
                text: i18nc("@button", "Delete")
                icon.name: "delete"
                onTriggered: {
                    const originalIndex = filteredModel.index(index, 0);
                    todoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
                }
            }
        ]
        position: QQC2.ToolBar.Footer

        Kirigami.Chip {
            Layout.alignment: Qt.AlignRight
            visible: model.creationDate
            text: model.creationDate
            font.bold: false
            closable: false
            checkable: false
            icon.name: "clock-symbolic"
            QQC2.ToolTip.visible: down
            QQC2.ToolTip.text: i18n("Task creation date")
        }
    }
}
