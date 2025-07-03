// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels
import org.kde.komodo.models

Kirigami.ScrollablePage {
    id: page

    Dialogs.FileDialog {
        id: openDialog
        onAccepted: {
            TodoModel.filePath = selectedFile;
        }
        modality: Qt.ApplicationModal
        nameFilters: ["Text files (*.txt)"]
    }

    Dialogs.FileDialog {
        id: createNewDialog
        onAccepted: {
            TodoModel.filePath = selectedFile;
        }
        fileMode: Qt.SaveFile
        modality: Qt.ApplicationModal
        nameFilters: ["Text files (*.txt)"]
    }

    QQC2.Dialog {
        id: deletePrompt
        title: i18n("Delete Todo")
        anchors.centerIn: parent
        modal: true
        property var model
        property var index
        standardButtons: QQC2.DialogButtonBox.Cancel
        width: parent.width - Kirigami.Units.gridUnit * 4
        contentItem: ColumnLayout {
            id: textLayout
            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n("Are you sure you wish to delete this todo?")
            }
            QQC2.TextField {
                font.family: "monospace"
                readOnly: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                wrapMode: Text.Wrap
                text: deletePrompt.model ? deletePrompt.model.description : ""
            }
        }
        footer: QQC2.DialogButtonBox {
            standardButtons: QQC2.DialogButtonBox.Cancel
            QQC2.Button {
                text: i18nc("@button", "Delete")
                icon.name: "delete"
                QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.DestructiveRole
                onClicked: {
                    const originalIndex = filteredModel.index(deletePrompt.index, 0);
                    TodoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
                }
            }
        }
    }

    QQC2.Dialog {
        id: editPrompt
        property var model
        property var index
        property alias text: editPromptText.text
        property bool addNew: true
        title: addNew ? i18n("Add New Todo") : i18n("Edit Todo")
        anchors.centerIn: parent
        modal: true
        width: parent.width - Kirigami.Units.gridUnit * 4

        contentItem: ColumnLayout {
            QQC2.TextField {
                id: editPromptText
                font.family: "monospace"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                wrapMode: Text.Wrap
                placeholderText: editPrompt.addNew ? "(A) 2024-01-01 description +project @context key:value" : editPrompt.model.description
            }
            RowLayout {
                QQC2.Button {
                    text: i18n("Date")
                    onClicked: {
                        let today = new Date();
                        const tz = today.getTimezoneOffset();
                        today = new Date(today.getTime() - (tz * 60 * 1000));
                        editPromptText.insert(editPromptText.cursorPosition, today.toISOString().substring(0, 10));
                    }
                }

                Kirigami.UrlButton {
                    text: i18n("Syntax Help")
                    url: "https://github.com/todotxt/todo.txt/blob/master/README.md"
                }
            }
        }

        footer: QQC2.DialogButtonBox {
            standardButtons: QQC2.DialogButtonBox.Ok | QQC2.DialogButtonBox.Cancel
            onAccepted: {
                if (editPrompt.addNew) {
                    TodoModel.addTodo(editPrompt.text);
                } else {
                    const model = editPrompt.model;
                    model.description = editPromptText.text;
                }
                editPrompt.text = ""; // Clear TextField every time it's done
                editPrompt.close();
            }
            onRejected: {
                editPrompt.text = "";
                editPrompt.close();
            }
        }
    }

    header: Kirigami.SearchField {
        id: searchField
        visible: true
    }

    actions: [
        Kirigami.Action {
            icon.name: "list-add"
            text: i18nc("@action:button", "Add New Todo…")
            enabled: TodoModel.filePath != ""
            onTriggered: {
                editPrompt.addNew = true;
                editPrompt.text = "";
                editPrompt.open();
            }
        },
        Kirigami.Action {
            icon.name: "document-open"
            text: i18nc("@action:button", "Open File…")
            onTriggered: {
                openDialog.open();
            }
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About KomoDo")
            icon.name: "help-about"
            shortcut: StandardKey.HelpContents
            displayHint: Kirigami.DisplayHint.AlwaysHide
            onTriggered: pageStack.layers.push(root.aboutPage)
            enabled: pageStack.layers.depth <= 1
        }
    ]
    Kirigami.CardsListView {
        id: cardsListView

        Kirigami.PlaceholderMessage {
            id: noTodosLoaded
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
            visible: TodoModel.filePath == ""
            icon.name: "korg-todo-symbolic"
            text: i18nc("@info:placeholder", "No todo.txt file is loaded.")
            explanation: xi18nc("@info:placeholder", "Click <interface>Open File…</interface> to use an existing file or <interface>Create New…</interface> to start a new file.")
            helpfulAction: Kirigami.Action {
                icon.name: "add"
                text: i18nc("@button", "Create new…")
                onTriggered: {
                    createNewDialog.open();
                }
            }
        }

        Kirigami.PlaceholderMessage {
            id: noTodosFound
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
            visible: !noTodosLoaded.visible && filteredModel.count === 0
            icon.name: "korg-todo-symbolic"
            text: i18nc("@info:placeholder", "No todos found.")
        }

        model: KSortFilterProxyModel {
            id: filteredModel
            sourceModel: TodoModel
            filterRoleName: "description"
            sortRoleName: "description"
            filterString: searchField.text
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        delegate: TodoDelegate {}
    }
}
