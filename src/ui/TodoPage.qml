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

    KeyNavigation.tab: searchField
    KeyNavigation.backtab: cardsListView.currentItem

    horizontalScrollBarPolicy: QQC2.ScrollBar.AlwaysOff
    horizontalScrollBarInteractive: false


    property bool fileChangedFromApp: false

    Connections {
        target: TodoModel
        function onFileChanged() {
            if (page.fileChangedFromApp) {
                page.fileChangedFromApp = false;
                return;
            }
            if (TodoModel.fileExists()){
                console.warn("file changed lol");
                fileDeletedMessage.visible = false;
                fileChangedMessage.visible = true;
            } else {
                fileChangedMessage.visible = false;
                fileDeletedMessage.visible = true;
                cardsListView.enabled = false;
            }
        }
    }

    function getDate() {
        let today = new Date();
        const tz = today.getTimezoneOffset();
        today = new Date(today.getTime() - (tz * 60 * 1000));
        return addNewPromptText.cursorPosition, today.toISOString().substring(0, 10);
    }

    Dialogs.FileDialog {
        id: openDialog
        onAccepted: {
            TodoModel.filePath = selectedFile;
            fileDeletedMessage.visible = false;
            cardsListView.enabled = true;
        }
        modality: Qt.ApplicationModal
        nameFilters: ["Text files (*.txt)"]
    }

    Dialogs.FileDialog {
        id: createNewDialog
        onAccepted: {
            TodoModel.filePath = selectedFile;
            fileDeletedMessage.visible = false;
            cardsListView.enabled = true;
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
                    page.fileChangedFromApp = true;
                    const originalIndex = filteredModel.index(deletePrompt.index, 0);
                    TodoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
                }
            }
        }
    }

    QQC2.Dialog {
        id: addNewPrompt
        property var model
        property var index
        property alias text: addNewPromptText.text
        title: i18n("Add New Todo")
        anchors.centerIn: parent
        modal: true
        width: parent.width - Kirigami.Units.gridUnit * 4

        contentItem: ColumnLayout {
            QQC2.TextField {
                id: addNewPromptText
                focus: true
                font.family: "monospace"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                wrapMode: Text.Wrap
                placeholderText: "(A) YYYY-MM-DD description +project @context key:value"
                Accessible.role: Accessible.EditableText
                onTextEdited: {
                    buttonBox.standardButton(QQC2.DialogButtonBox.Ok).enabled = text.length > 0;
                }
            }
            RowLayout {
                QQC2.Button {
                    text: i18nc("@button", "Insert Date")
                    icon.name: "view-calendar-symbolic"
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Inserts timestamp, such as 2025-12-31")
                    onClicked: {
                        addNewPromptText.insert(addNewPromptText.cursorPosition, getDate());
                    }
                }

                Kirigami.UrlButton {
                    text: i18nc("@info", "Syntax Help")
                    url: "https://github.com/todotxt/todo.txt/blob/master/README.md"
                }
            }
        }

        footer: QQC2.DialogButtonBox {
            id: buttonBox
            standardButtons: QQC2.DialogButtonBox.Ok | QQC2.DialogButtonBox.Cancel
            onAccepted: {
                page.fileChangedFromApp = true;
                TodoModel.addTodo(addNewPrompt.text);
                addNewPrompt.close();
            }
            onRejected: {
                addNewPrompt.close();
            }
        }
    }

    titleDelegate: Kirigami.Heading {
        text: TodoModel.filePath.toString().replace("file://", "").split('/').pop()
        elide: Text.ElideMiddle
    }

    header: ColumnLayout {
        QQC2.Pane {
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Layout.fillWidth: true
                Kirigami.SearchField {
                    id: searchField
                    Layout.fillWidth: true
                    KeyNavigation.backtab: page.globalToolBarItem
                    KeyNavigation.tab: filterComboBox
                    visible: true
                    onTextChanged: {
                        cardsListView.currentIndex = -1;
                    }
                }
                QQC2.Label {
                    text: i18n("Filter:")
                }
                QQC2.ComboBox {
                    id: filterComboBox
                    editable: false
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        {
                            value: "default",
                            text: i18n("Show All")
                        },
                        {
                            value: "hasDueDate",
                            text: i18n("Due Date")
                        },
                        {
                            value: "isNotCompleted",
                            text: i18n("Incomplete")
                        },
                        {
                            value: "isCompleted",
                            text: i18n("Completed")
                        },
                    ]
                    onCurrentValueChanged: {
                        filteredModel.filterString = filterComboBox.currentValue;
                    }
                }
            }
            background: ColumnLayout {
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Kirigami.Theme.backgroundColor
                }
                Kirigami.Separator {
                    Layout.fillWidth: true
                }
            }
        }
        Kirigami.InlineMessage {
            id: fileChangedMessage
            Layout.fillWidth: true
            visible: false
            text: i18n("This file has been changed externally. Reloading it is strongly advised!")
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            actions: [
                Kirigami.Action {
                    icon.name: "view-refresh-symbolic"
                    text: i18nc("@action:button", "Reload")
                    onTriggered: source => {
                        TodoModel.loadFile();
                        fileChangedMessage.visible = false;
                    }
                }
            ]
        }
        Kirigami.InlineMessage {
            id: fileDeletedMessage
            Layout.fillWidth: true
            visible: false
            text: i18n("This file has been deleted! Open another file or create new one.")
            type: Kirigami.MessageType.Error
            showCloseButton: false
            actions: [
                Kirigami.Action {
                    icon.name: "add"
                    text: i18nc("@button", "Create New…")
                    onTriggered: {
                        createNewDialog.open();
                    }
                },
                Kirigami.Action {
                    icon.name: "document-open"
                    text: i18nc("@action:button", "Open File…")
                    onTriggered: {
                        openDialog.open();
                    }
                }
            ]
        }
    }

    actions: [
        Kirigami.Action {
            icon.name: "list-add"
            text: i18nc("@action:button", "Add New Todo…")
            enabled: TodoModel.filePath != ""
            onTriggered: {
                addNewPrompt.text = "(A) " + getDate() + " ";
                addNewPrompt.open();
            }
            shortcut: StandardKey.New
        },
        Kirigami.Action {
            icon.name: "document-open"
            text: i18nc("@action:button", "Open File…")
            onTriggered: {
                openDialog.open();
            }
            shortcut: StandardKey.Open
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About KomoDo")
            icon.name: "help-about"
            shortcut: StandardKey.HelpContents
            onTriggered: pageStack.layers.push(aboutPage)
            enabled: pageStack.layers.depth <= 1
        }
    ]

    Kirigami.CardsListView {
        id: cardsListView
        highlightFollowsCurrentItem: true
        currentIndex: -1
        highlightMoveDuration: 1
        highlightMoveVelocity: 1
        focusPolicy: Qt.NoFocus

        Kirigami.PlaceholderMessage {
            id: noTodosLoaded
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
            visible: TodoModel.filePath == ""
            icon.name: "korg-todo"
            text: i18nc("@info:placeholder", "No todo.txt file is loaded.")
            explanation: xi18nc("@info:placeholder", "Click <interface>Open File…</interface> to use an existing file or <interface>Create New…</interface> to start a new file.")
            helpfulAction: Kirigami.Action {
                icon.name: "add"
                text: i18nc("@button", "Create New…")
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
            icon.name: "korg-todo"
            text: i18nc("@info:placeholder", "No todos found.")
        }

        model: KSortFilterProxyModel {
            id: filteredModel
            sourceModel: TodoModel
            filterString: "default"
            sortRoleName: "description"
            filterRegularExpression: RegExp(searchField.text.replace("+", "\\+"), "gi")
            filterCaseSensitivity: Qt.CaseInsensitive
            filterRowCallback: function (source_row, source_parent) {
                switch (filterString) {
                case "default":
                    return true;
                case "hasDueDate":
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.DueDateRole) != "";
                case "isNotCompleted":
                    return !sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.CompletionRole);
                case "isCompleted":
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.CompletionRole);
                default:
                    console.warn("This filter is not handled yet!", filterString);
                    return true;
                }
            }
        }

        delegate: TodoDelegate {
            currentItem: cardsListView.currentItem == this
        }

        Keys.onEscapePressed: {
            cardsListView.currentIndex = -1;
        }

        Keys.onLeftPressed: {
            decrementCurrentIndex();
        }

        Keys.onRightPressed: {
            incrementCurrentIndex();
        }

        Keys.onPressed: event => {
            if (event.key == Qt.Key_PageDown) {
                for (let i = 0; i < 3; i++) {
                    incrementCurrentIndex();
                }
                event.accepted = true;
            }
            if (event.key == Qt.Key_PageUp) {
                for (let i = 0; i < 3; i++) {
                    decrementCurrentIndex();
                }
                event.accepted = true;
            }
        }
    }
}
