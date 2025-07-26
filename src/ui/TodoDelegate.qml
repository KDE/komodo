// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.dateandtime as DateTime

Kirigami.AbstractCard {
    id: todoDelegate
    clip: true

    required property int index
    required property var model

    property bool currentItem: Kirigami.CardsListView.isCurrentItem
    property bool editMode: false
    property alias textEditField: editTodoItemText

    KeyNavigation.tab: completionStatus
    // Create custom shadowed rectangle for the focus coloring
    background: Kirigami.ShadowedRectangle {
        color: Kirigami.Theme.backgroundColor
        shadow.color: Qt.rgba(0, 0, 0, 0.6)
        shadow.yOffset: 1
        shadow.size: Kirigami.Units.gridUnit / 2
        radius: Kirigami.Units.cornerRadius
        border.width: 1
        border.color: todoDelegate.currentItem ? Kirigami.Theme.activeTextColor : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
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
                        checked: todoDelegate.model.completion
                        onToggled: {
                            todoDelegate.model.completion = !todoDelegate.model.completion;
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                        QQC2.ToolTip.text: i18n("Task completion status")
                        KeyNavigation.tab: editButton
                        KeyNavigation.backtab: searchField
                        background: Rectangle {
                            visible: completionStatus.visualFocus
                            color: Kirigami.Theme.highlightColor
                            radius: Kirigami.Units.cornerRadius
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    QQC2.Label {
                        id: priorityLabel
                        Layout.alignment: Qt.AlignHCenter
                        visible: todoDelegate.model.priority
                        text: todoDelegate.model.priority.replace(/\(|\)/g, "")
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
                        MouseArea {
                            hoverEnabled: true
                            anchors.fill: parent
                            QQC2.ToolTip.visible: containsMouse
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            QQC2.ToolTip.text: i18n("Priority")
                        }
                    }
                }

                Kirigami.Separator {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter
                }

                Item {
                    Layout.minimumWidth: Kirigami.Units.smallSpacing
                    implicitWidth: Kirigami.Units.smallSpacing
                }

                ColumnLayout {
                    id: viewLayout
                    Layout.fillWidth: true
                    Kirigami.SelectableLabel {
                        id: prettyDescriptionLabel
                        font.family: "monospace"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        wrapMode: Text.Wrap
                        text: todoDelegate.model.prettyDescription
                        // Looks like colors work with markdownText, but it also resolves urls etc.
                        textFormat: Qt.MarkdownText
                        font.strikeout: todoDelegate.model.completion
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                        bottomPadding: Kirigami.Units.smallSpacing
                        color: todoDelegate.model.completion ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
                    }

                    Repeater {
                        id: keyValuePairRepeater
                        model: todoDelegate.model.keyValuePairs
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
                            visible: todoDelegate.model.completionDate
                            text: todoDelegate.model.completionDate
                            font.bold: false
                            closable: false
                            checkable: false
                            icon.name: "task-complete-symbolic"
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            QQC2.ToolTip.text: i18n("Task completion date")
                        }

                        Kirigami.Chip {
                            Layout.alignment: Qt.AlignLeft
                            visible: todoDelegate.model.dueDate
                            text: todoDelegate.model.dueDate
                            font.bold: false
                            closable: false
                            checkable: false
                            icon.name: "notification-active-symbolic"
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            QQC2.ToolTip.text: i18n("Task due date")
                        }

                        Kirigami.Chip {
                            Layout.alignment: Qt.AlignLeft
                            visible: todoDelegate.model.creationDate
                            text: todoDelegate.model.creationDate
                            font.bold: false
                            closable: false
                            checkable: false
                            icon.name: "clock-symbolic"
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            QQC2.ToolTip.text: i18n("Task creation date")
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        QQC2.Button {
                            id: editButton
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            flat: true
                            display: QQC2.AbstractButton.IconOnly
                            action: Kirigami.Action {
                                id: editItemAction
                                text: i18nc("@button", "Edit")
                                tooltip: text
                                icon.name: "edit-entry-symbolic"
                                onTriggered: {
                                    todoDelegate.editMode = true;
                                    editTodoItemText.focus = true;
                                }
                                shortcut: todoDelegate.currentItem ? "Ctrl+E" : ""
                            }
                            KeyNavigation.tab: deleteItemButton
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            QQC2.ToolTip.text: editItemAction.tooltip
                        }

                        QQC2.Button {
                            id: deleteItemButton
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            display: QQC2.AbstractButton.IconOnly
                            flat: true
                            action: Kirigami.Action {
                                id: deleteItemAction
                                text: i18nc("@button", "Delete")
                                icon.name: "entry-delete-symbolic"
                                onTriggered: {
                                    deletePrompt.description = todoDelegate.model.description;
                                    deletePrompt.index = todoDelegate.index;
                                    deletePrompt.open();
                                }
                                shortcut: todoDelegate.currentItem ? "Ctrl+D" : ""
                                tooltip: text
                            }
                            KeyNavigation.tab: searchField
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            QQC2.ToolTip.text: deleteItemAction.tooltip
                        }
                    }
                }
            }
            ColumnLayout {
                id: editLayout
                visible: todoDelegate.editMode
                QQC2.TextField {
                    id: editTodoItemText
                    font.family: "monospace"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: delegateLayout.width - Kirigami.Units.smallSpacing
                    wrapMode: Text.Wrap
                    placeholderText: todoDelegate.model.description == "" ? i18nc("Placeholder text for creating new tasks", "Description +Project @Context key:value") : todoDelegate.model.description
                    text: todoDelegate.model.description
                    Accessible.role: Accessible.EditableText
                    KeyNavigation.backtab: cancelEditButton
                    Keys.onReturnPressed: {
                        saveEditButton.click();
                    }
                }

                RowLayout {

                    DateTime.DatePopup {
                        id: datePopup
                        modal: true
                        onAccepted: {
                            var timezoneOffset = (new Date()).getTimezoneOffset() * 60 * 1000;
                            var ISOTimeWithLocale = (new Date(datePopup.value - timezoneOffset)).toISOString().slice(0, 10);
                            editTodoItemText.insert(editTodoItemText.cursorPosition, ISOTimeWithLocale);
                        }
                        onClosed: {
                            editTodoItemText.focus = true;
                        }
                    }

                    QQC2.Button {
                        action: Kirigami.Action {
                            id: insertDateAction
                            text: i18nc("@button", "Insert Date…")
                            icon.name: "view-calendar-symbolic"
                            tooltip: i18n("Open a date picker and insert it at cursor position")
                            onTriggered: {
                                datePopup.open();
                            }
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                        QQC2.ToolTip.text: insertDateAction.tooltip
                    }

                    Kirigami.ContextualHelpButton {
                        id: helpText
                        text: i18n("Syntax Information")
                        display: QQC2.AbstractButton.TextBesideIcon
                        toolTipText: i18nc("@info", "<p>Syntax information:<br><br>Description: General task description. Mandatory.<br><br>+Project: Projects this task is relevant to. Optional.<br><br>@Context: In which contexts this task is relevant in. Optional.<br><br>key:value: Various key-value pairs of information. Optional.<br></p><p>These values can be mixed with each other. Example:</p> <p>2025-05-03 Do some +Cleaning and +Coding when @Home @Office due:2025-05-05</p><br><p>Please read the Help section for more details.</p>")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QQC2.Button {
                        id: saveEditButton
                        display: QQC2.AbstractButton.IconOnly
                        flat: true
                        enabled: editTodoItemText.length > 0
                        action: Kirigami.Action {
                            id: saveEditAction
                            text: i18nc("@button", "Save")
                            icon.name: "document-save-symbolic"
                            onTriggered: {
                                todoDelegate.model.description = editTodoItemText.text;
                                todoDelegate.editMode = false;
                                completionStatus.focus = true;
                            }
                            tooltip: text
                            shortcut: todoDelegate.currentItem ? StandardKey.Save : ""
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                        QQC2.ToolTip.text: saveEditAction.tooltip
                    }
                    //TODO: we should ask confirm from the user if theyre cancelling a field that has been edited!
                    QQC2.Button {
                        id: cancelEditButton
                        display: QQC2.AbstractButton.IconOnly
                        flat: true
                        action: Kirigami.Action {
                            id: cancelEditAction
                            text: i18nc("@button", "Cancel")
                            icon.name: "dialog-cancel-symbolic"
                            onTriggered: {
                                editTodoItemText.text = todoDelegate.model.description;
                                todoDelegate.editMode = false;
                                completionStatus.focus = true;
                                // Delete empty todos
                                if (todoDelegate.model.description == "") {
                                    deleteTodo(index);
                                }
                            }
                            tooltip: text
                            shortcut: todoDelegate.currentItem ? StandardKey.Cancel : ""
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                        QQC2.ToolTip.text: cancelEditAction.tooltip
                        KeyNavigation.tab: searchField
                    }
                }
            }
        }
    }
}
