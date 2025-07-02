// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: todoDelegate
    clip: true

    property var keyValuePairs: model.keyValuePairs

    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        RowLayout {
            id: delegateLayout
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            ColumnLayout {
                id: completionColumn
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                Layout.maximumWidth: Kirigami.Units.gridUnit * 2
                QQC2.CheckBox {
                    id: completionStatus
                    Layout.alignment: Qt.AlignHCenter
                    checked: model.completion
                    onToggled: model.completion = !model.completion
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Task completion status")
                }

                Item {
                    Layout.fillHeight: true
                }

                QQC2.Label {
                    id: priorityLabel
                    Layout.alignment: Qt.AlignHCenter
                    visible: model.priority
                    text: model.priority.replace(/\(|\)/g, "")
                }
            }

            Kirigami.Separator {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Kirigami.SelectableLabel {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    wrapMode: Text.Wrap
                    text: model.prettyDescription
                    textFormat: Qt.MarkdownText
                    font.strikeout: model.completion
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.35
                    bottomPadding: Kirigami.Units.smallSpacing
                }

                Repeater {
                    id: keyValuePairRepeater
                    model: todoDelegate.keyValuePairs
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

                        QQC2.Label {
                            id: keyLabel
                            text: parent.textData[0] + ":"
                            font.italic: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        }

                        // Show this if the value has no url
                        Kirigami.SelectableLabel {
                            Layout.maximumWidth: delegateLayout.width - keyLabel.width - completionColumn.width - Kirigami.Units.smallSpacing * 4
                            text: parent.textData[1]
                            visible: !textUrl
                            wrapMode: Text.Wrap
                            Layout.alignment: Qt.AlignLeft
                            rightPadding: Kirigami.Units.smallSpacing
                        }

                        // Otherwise, we give a clickable url
                        Kirigami.UrlButton {
                            // Make sure the external url icon does not go outside the view
                            Layout.maximumWidth: delegateLayout.width - keyLabel.width - completionColumn.width - Kirigami.Units.smallSpacing * 4
                            Layout.alignment: Qt.AlignLeft
                            visible: textUrl
                            elide: Text.ElideRight
                            text: textUrl
                            url: textUrl
                        }
                    }
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Layout.maximumWidth: delegateLayout.width - completionColumn.width - Kirigami.Units.smallSpacing
                    Kirigami.Chip {
                        Layout.alignment: Qt.AlignLeft
                        visible: model.completionDate
                        text: model.completionDate
                        font.bold: false
                        closable: false
                        checkable: false
                        icon.name: "task-complete-symbolic"
                        QQC2.ToolTip.visible: down
                        QQC2.ToolTip.text: i18n("Task completion date")
                    }

                    Kirigami.Chip {
                        Layout.alignment: Qt.AlignLeft
                        visible: model.dueDate
                        text: model.dueDate
                        font.bold: false
                        closable: false
                        checkable: false
                        icon.name: "notification-active-symbolic"
                        QQC2.ToolTip.visible: down
                        QQC2.ToolTip.text: i18n("Task due date")
                    }

                    Kirigami.Chip {
                        Layout.alignment: Qt.AlignLeft
                        visible: model.creationDate
                        text: model.creationDate
                        font.bold: false
                        closable: false
                        checkable: false
                        icon.name: "clock-symbolic"
                        QQC2.ToolTip.visible: down
                        QQC2.ToolTip.text: i18n("Task creation date")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        text: i18nc("@button", "Delete")
                        display: QQC2.AbstractButton.IconOnly
                        flat: true
                        icon.name: "entry-delete"
                        onClicked: {
                            deletePrompt.model = model;
                            deletePrompt.index = index;
                            deletePrompt.open();
                        }
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        text: i18nc("@button", "Edit")
                        display: QQC2.AbstractButton.IconOnly
                        flat: true
                        icon.name: "edit-entry"
                        onClicked: {
                            editPrompt.text = model.description;
                            editPrompt.model = model;
                            editPrompt.index = index;
                            editPrompt.open();
                        }
                    }
                }
            }
        }
    }

    footer: RowLayout {
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
            visible: model.completionDate
            text: model.completionDate
            font.bold: false
            closable: false
            checkable: false
            icon.name: "task-complete-symbolic"
            QQC2.ToolTip.visible: down
            QQC2.ToolTip.text: i18n("Task completion date")
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

        Item {
            Layout.fillWidth: true
        }

        QQC2.Button {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            text: i18nc("@button", "Edit")
            display: QQC2.AbstractButton.IconOnly
            flat: true
            icon.name: "edit-entry"
            onClicked: {
                editPrompt.text = model.description;
                editPrompt.model = model;
                editPrompt.index = index;
                editPrompt.open();
            }
        }

        QQC2.Button {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            text: i18nc("@button", "Delete")
            display: QQC2.AbstractButton.IconOnly
            flat: true
            icon.name: "entry-delete"
            onClicked: {
                deletePrompt.model = model;
                deletePrompt.index = index;
                deletePrompt.open();
            }
        }
    }
}
