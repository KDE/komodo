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

    function deleteTodo(index) {
        const originalIndex = filteredModel.index(index, 0);
        TodoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
    }

    function updateSearch() {
        filteredModel.filterRegularExpression = RegExp(searchField.text.replace("+", "\\+").replace("(", "\\(").replace(")", "\\)"), "gi");
        cardsListView.currentIndex = -1;
        searchField.forceActiveFocus();
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
        defaultSuffix: "txt"
        nameFilters: ["Text files (*.txt)"]
    }

    Kirigami.Dialog {
        id: deletePrompt
        property string description
        property var index
        anchors.centerIn: parent
        title: i18n("Delete To-Do")
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
                text: i18n("Are you sure you wish to delete this To-Do?")
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
            page.deleteTodo(deletePrompt.index);
            deletePrompt.close();
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
                    onFocusChanged: {
                        if (focus) {
                            cardsListView.currentIndex = -1;
                        }
                    }
                    onTextChanged: Qt.callLater(page.updateSearch);
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
                    Component.onCompleted: {
                        currentIndex = TodoModel.filterIndex;
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
            text: i18n("This To-Do list has been changed externally. Reloading it is strongly advised!")
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
            text: i18n("This To-Do list has been deleted! Open another To-Do list or create new one.")
            type: Kirigami.MessageType.Error
            showCloseButton: false
            actions: [
                Kirigami.Action {
                    icon.name: "document-new-symbolic"
                    text: i18nc("@button", "Create New To-Do List…")
                    onTriggered: {
                        createNewDialog.open();
                    }
                },
                Kirigami.Action {
                    icon.name: "document-open-symbolic"
                    text: i18nc("@action:button", "Open To-Do List…")
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
            text: i18nc("@action:inmenu", "New To-Do…")
            enabled: TodoModel.filePath != ""
            onTriggered: {
                filterComboBox.currentIndex = 0;
                cardsListView.currentIndex = filteredModel.mapFromSource(TodoModel.indexFromQUuid(TodoModel.addTodo(""))).row;
                cardsListView.currentItem.editMode = true;
                cardsListView.currentItem.autoInsertCreationDate = TodoModel.autoInsertCreationDate;
            }
            shortcut: StandardKey.New
        },
        Kirigami.Action {
            icon.name: "document-open-symbolic"
            text: i18nc("@action:inmenu", "Open To-Do List…")
            onTriggered: {
                openDialog.open();
            }
            shortcut: StandardKey.Open
        },
        Kirigami.Action {
            icon.name: "document-new-symbolic"
            text: i18nc("@button", "Create New To-Do List…")
            onTriggered: {
                createNewDialog.open();
            }
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "Help…")
            icon.name: "help-contents-symbolic"
            onTriggered: Qt.openUrlExternally("help:/komodo")
            enabled: pageStack.layers.depth <= 1
            shortcut: StandardKey.HelpContents
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "Auto-insert creation date")
            icon.name: "view-calendar-symbolic"
            checkable: true
            checked: TodoModel.autoInsertCreationDate
            tooltip: i18nc("A checkbox for toggling this setting", "Insert a creation date for any new task automatically")
            displayHint: Kirigami.DisplayHint.AlwaysHide
            onTriggered: {
                TodoModel.autoInsertCreationDate = checked;
            }
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
            type: Kirigami.PlaceholderMessage.Actionable
            icon.name: "org.kde.komodo"
            text: i18nc("@info:placeholder", "Welcome to KomoDo!")
            explanation: i18nc("Welcome introduction text", "<p>KomoDo is a To-Do list application that uses <a href='https://github.com/todotxt/todo.txt'>todo.txt</a> rules.</p><p>The rules are fairly quick to learn and KomoDo has help sections for it: <br>On the toolbar, click the <i><interface>Help…</interface></i> button.<br>While editing a task, click the <i><interface>Syntax Information…</interface></i> button.</p><p>You can follow the rules as much or as little as you wish.<br> Feel free to experiment to find out your ideal way of managing tasks.</p><p>Click <i><interface>Open To-Do list…</interface></i> to use an existing list or <i><interface>Create New To-Do list…</interface></i> to start a new list.</p>")
            onLinkActivated: link => {
                Qt.openUrlExternally(link);
            }
        }

        Kirigami.PlaceholderMessage {
            id: noTodosFound
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            anchors.centerIn: parent
            visible: !noTodosLoaded.visible && filteredModel.count === 0
            icon.name: "org.kde.komodo"
            text: i18nc("@info:placeholder", "No To-Dos found.")
        }
        model: KSortFilterProxyModel {
            id: filteredModel
            property var secondaryFilter: "default"
            sourceModel: TodoModel
            filterRoleName: "description"
            sortRoleName: "description"
            filterRowCallback: function (source_row, source_parent) {
                const item = sourceModel.index(source_row, 0, source_parent);
                if (searchField.text.length > 0) {
                    const itemText = sourceModel.data(item, TodoModel.DescriptionRole);
                    if (!itemText.match(filterRegularExpression) && itemText.length > 0) {
                        return false;
                    }
                }

                switch (secondaryFilter) {
                case "default":
                    return true;
                case "hasDueDate":
                    return sourceModel.data(item, TodoModel.DueDateRole) != "";
                case "isNotCompleted":
                    return !sourceModel.data(item, TodoModel.CompletionRole);
                case "isCompleted":
                    return sourceModel.data(item, TodoModel.CompletionRole);
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
