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

    Connections {
        target: TodoModel
        function onFileChanged() {
            const fileExists = TodoModel.fileExists();
            fileDeletedMessage.visible = !fileExists;
            fileChangedMessage.visible = fileExists;
            cardsListView.enabled = fileExists;
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

    Kirigami.Dialog {
        id: deletePrompt
        property string description
        property var index
        anchors.centerIn: parent
        title: i18n("Delete Todo")
        modal: true
        width: parent.width - Kirigami.Units.largeSpacing * 8
        maximumHeight: parent.height - Kirigami.Units.largeSpacing * 4
        padding: Kirigami.Units.largeSpacing
        showCloseButton: false

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
                text: deletePrompt.description
            }
        }

        standardButtons: Kirigami.Dialog.Discard | Kirigami.Dialog.Cancel

        onDiscarded: {
            const originalIndex = filteredModel.index(deletePrompt.index, 0);
            TodoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
            deletePrompt.close();
        }
    }

    Kirigami.Dialog {
        id: addNewPrompt
        property var model
        property var index
        property alias text: addNewPromptText.text
        anchors.centerIn: parent
        title: i18n("Add New Todo")
        modal: true
        width: parent.width - Kirigami.Units.largeSpacing * 8
        maximumHeight: parent.height - Kirigami.Units.largeSpacing * 4
        padding: Kirigami.Units.largeSpacing
        showCloseButton: false
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
                    addNewPrompt.standardButton(Kirigami.Dialog.Ok).enabled = text.length > 0;
                }
                Keys.onReturnPressed: {
                    addNewPrompt.standardButton(Kirigami.Dialog.Ok).click();
                }
            }
            RowLayout {
                QQC2.Button {
                    action: Kirigami.Action {
                        id: insertDateAction
                        text: i18nc("@button", "Insert Date")
                        icon.name: "view-calendar-symbolic"
                        tooltip: i18n("Inserts timestamp, such as 2025-12-31")
                        onTriggered: {
                            addNewPromptText.insert(addNewPromptText.cursorPosition, getDate());
                        }
                    }
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    QQC2.ToolTip.text: insertDateAction.tooltip
                }

                Kirigami.UrlButton {
                    text: i18nc("@info", "Syntax Help")
                    url: "https://github.com/todotxt/todo.txt/blob/master/README.md"
                }
            }
        }

        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: {
            TodoModel.addTodo(addNewPrompt.text);
            addNewPrompt.close();
        }
        onRejected: {
            addNewPrompt.close();
        }
    }

    titleDelegate: Kirigami.Heading {
        text: TodoModel.filePath.toString().replace("file://", "").split('/').pop()
        elide: Text.ElideMiddle
        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            QQC2.ToolTip.visible: containsMouse
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            QQC2.ToolTip.text: TodoModel.filePath.toString().replace("file://", "")
        }
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
                    currentIndex: TodoModel.filterIndex
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
                    onCurrentIndexChanged: {
                        TodoModel.filterIndex = currentIndex;
                    }
                    onCurrentValueChanged: {
                        cardsListView.currentIndex = -1;
                        filteredModel.secondaryFilter = filterComboBox.currentValue;
                        TodoModel.loadFile();
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
            icon.name: "list-add-symbolic"
            text: i18nc("@action:inmenu", "New Todo…")
            enabled: TodoModel.filePath != ""
            onTriggered: {
                addNewPrompt.text = "";
                addNewPrompt.open();
                addNewPromptText.focus = true;
            }
            shortcut: StandardKey.New
        },
        Kirigami.Action {
            icon.name: "document-open-symbolic"
            text: i18nc("@action:inmenu", "Open File…")
            onTriggered: {
                openDialog.open();
            }
            shortcut: StandardKey.Open
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "Help…")
            icon.name: "help-contents-symbolic"
            onTriggered: pageStack.layers.push(helpPage)
            enabled: pageStack.layers.depth <= 1
            shortcut: StandardKey.HelpContents
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About KomoDo")
            icon.name: "help-about-symbolic"
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
        // For some reason the content width is too wide and this causes issues
        // that allows us to scroll with arrow keys from side to side???
        // IDK why this fixes it but whatever
        contentWidth: contentItem.childrenRect.width

        Kirigami.PlaceholderMessage {
            id: noTodosLoaded
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
            visible: TodoModel.filePath == ""
            icon.name: "org.kde.komodo"
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
            icon.name: "org.kde.komodo"
            text: i18nc("@info:placeholder", "No todos found.")
        }

        model: KSortFilterProxyModel {
            id: filteredModel
            property var secondaryFilter: "default"
            sourceModel: TodoModel
            filterRoleName: "description"
            sortRoleName: "description"
            filterRegularExpression: RegExp(searchField.text.replace("+", "\\+").replace("(", "\\(").replace(")", "\\)"), "gi")
            filterRowCallback: function (source_row, source_parent) {
                if (searchField.text.length > 0) {
                    if (!sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.DescriptionRole).match(filterRegularExpression)) {
                        return false;
                    }
                }

                switch (secondaryFilter) {
                case "default":
                    return true;
                case "hasDueDate":
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.DueDateRole) != "";
                case "isNotCompleted":
                    return !sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.CompletionRole);
                case "isCompleted":
                    return sourceModel.data(sourceModel.index(source_row, 0, source_parent), TodoModel.CompletionRole);
                default:
                    return false;
                }
            }
        }

        delegate: TodoDelegate {
            // Focus automatically on an item being edited, in case
            // there is multiple edited items and user moves between them with keys
            onFocusChanged: {
                cardsListView.keyNavigationEnabled = !editMode;
                textEditField.focus = editMode;
            }
            onEditModeChanged: {
                if (editMode) {
                    cardsListView.currentIndex = index;
                }
                cardsListView.keyNavigationEnabled = !editMode;
            }
        }

        Keys.onEscapePressed: {
            cardsListView.currentIndex = -1;
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
