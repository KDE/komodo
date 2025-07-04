// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: todoDelegate
    clip: true

    // Create custom shadowed rectangle for the focus coloring
    background: Kirigami.ShadowedRectangle {
        color: Kirigami.Theme.backgroundColor
        shadow.color: Qt.rgba(0, 0, 0, 0.6)
        shadow.yOffset: 1
        shadow.size: Kirigami.Units.gridUnit / 2
        radius: Kirigami.Units.cornerRadius
        border.width: 1
        border.color: todoDelegate.focus ? Kirigami.Theme.activeTextColor : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
    }

    property bool editMode: false
    property var keyValuePairs: model ? model.keyValuePairs : [""]
    property bool completion: model ? model.completion : false
    property var priority: model ? model.priority : ""
    property var prettyDescription: model ? model.prettyDescription : ""
    property var completionDate: model ? model.completionDate : ""
    property var dueDate: model ? model.dueDate : ""
    property var creationDate: model ? model.creationDate : ""
    property var description: model ? model.description : ""

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

            RowLayout {
                id: dataLayout
                visible: !todoDelegate.editMode

                ColumnLayout {
                    id: completionColumn
                    Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 2
                    QQC2.CheckBox {
                        id: completionStatus
                        spacing: 0
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        checked: todoDelegate.completion
                        onToggled: todoDelegate.completion = !todoDelegate.completion
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: i18n("Task completion status")
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    QQC2.Label {
                        id: priorityLabel
                        Layout.alignment: Qt.AlignHCenter
                        visible: todoDelegate.priority
                        text: todoDelegate.priority.replace(/\(|\)/g, "")
                        color: {
                            switch (text) {
                            case "A":
                                return Kirigami.Theme.negativeTextColor;
                            case "B":
                                return Kirigami.Theme.neutralTextColor;
                            case "C":
                                return Kirigami.Theme.positiveTextColor;
                            default:
                                return Kirigami.Theme.textColor;
                            }
                        }
                    }
                }

                Kirigami.Separator {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter
                }

                ColumnLayout {
                    id: viewLayout
                    Layout.fillWidth: true
                    Kirigami.SelectableLabel {
                        font.family: "monospace"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        wrapMode: Text.Wrap
                        text: todoDelegate.prettyDescription
                        // Looks like colors work with markdownText, but it also resolves urls etc.
                        textFormat: Qt.MarkdownText
                        font.strikeout: todoDelegate.completion
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
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
                            visible: todoDelegate.completionDate
                            text: todoDelegate.completionDate
                            font.bold: false
                            closable: false
                            checkable: false
                            icon.name: "task-complete-symbolic"
                            QQC2.ToolTip.visible: down
                            QQC2.ToolTip.text: i18n("Task completion date")
                        }

                        Kirigami.Chip {
                            Layout.alignment: Qt.AlignLeft
                            visible: todoDelegate.dueDate
                            text: todoDelegate.dueDate
                            font.bold: false
                            closable: false
                            checkable: false
                            icon.name: "notification-active-symbolic"
                            QQC2.ToolTip.visible: down
                            QQC2.ToolTip.text: i18n("Task due date")
                        }

                        Kirigami.Chip {
                            Layout.alignment: Qt.AlignLeft
                            visible: todoDelegate.creationDate
                            text: todoDelegate.creationDate
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
                            text: i18nc("@button", "Edit")
                            display: QQC2.AbstractButton.IconOnly
                            flat: true
                            icon.name: "edit-entry"
                            onClicked: {
                                todoDelegate.editMode = true;
                            }
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
                    }
                }
            }
            ColumnLayout {
                id: editLayout
                visible: todoDelegate.editMode
                QQC2.TextField {
                    id: addNewPromptText
                    font.family: "monospace"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: delegateLayout.width - Kirigami.Units.smallSpacing
                    wrapMode: Text.Wrap
                    placeholderText: model.description
                    text: model.description
                }
                RowLayout {
                    QQC2.Button {
                        text: i18nc("@button", "Date")
                        icon.name: "view-calendar"
                        onClicked: {
                            addNewPromptText.insert(addNewPromptText.cursorPosition, getDate());
                        }
                    }

                    Kirigami.UrlButton {
                        text: i18nc("@info", "Syntax Help")
                        url: "https://github.com/todotxt/todo.txt/blob/master/README.md"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QQC2.Button {
                        text: i18nc("@button", "Save")
                        display: QQC2.AbstractButton.IconOnly
                        flat: true
                        icon.name: "document-save"
                        onClicked: {
                            model.description = addNewPromptText.text;
                            todoDelegate.editMode = false;
                        }
                    }
                    QQC2.Button {
                        text: i18nc("@button", "Cancel")
                        display: QQC2.AbstractButton.IconOnly
                        flat: true
                        icon.name: "dialog-cancel"
                        onClicked: {
                            addNewPromptText.text = model.description;
                            todoDelegate.editMode = false;
                        }
                    }
                }
            }
        }
    }
}
