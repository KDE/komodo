// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras

import org.kde.komodo.ui

PlasmaExtras.Representation {
    id: fullRepresentation

    Layout.minimumWidth: Kirigami.Units.gridUnit * 25
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.preferredHeight: Kirigami.Units.gridUnit * 24
    Layout.maximumWidth: Kirigami.Units.gridUnit * 80
    Layout.maximumHeight: Kirigami.Units.gridUnit * 40

    function updateSearch() {
        // Not necessary, but it's nice being able to set the
        // search phrase phrase as the fixed search term
        // immediately upon entering settings.
        plasmoid.configuration.searchTerm = searchField.text;

        filteredModel.primaryFilter = searchField.text;
        cardsListView.currentIndex = -1;
        searchField.forceActiveFocus();
    }

    header: PlasmaExtras.PlasmoidHeading {
        id: heading
        visible: root.isLoaded && plasmoid.configuration.searchBarEnabled

        RowLayout {
            anchors.fill: parent
            
            PlasmaExtras.SearchField {
                id: searchField
                Layout.fillWidth: true
                onTextChanged: Qt.callLater(fullRepresentation.updateSearch)
                KeyNavigation.tab: filterComboBox
                text: plasmoid.configuration.searchTerm
                visible: plasmoid.configuration.searchBarEnabled
            }

            QQC2.ComboBox {
                id: filterComboBox
                KeyNavigation.tab: cardsListView
                editable: false
                textRole: "text"
                valueRole: "value"
                currentIndex: plasmoid.configuration.filterIndex
                model: [
                    {
                        value: "default",
                        text: i18nc("@item:inmenu Secondary filter, show all tasks", "Show All")
                    },
                    {
                        value: "hasDueDate",
                        text: i18nc("@item:inmenu Secondary filter, show tasks with due date", "Due Date")
                    },
                    {
                        value: "isNotCompleted",
                        text: i18nc("@item:inmenu Secondary filter, show incomplete tasks", "Incomplete")
                    },
                    {
                        value: "isCompleted",
                        text: i18nc("@item:inmenu Secondary filter, show completed tasks", "Completed")
                    },
                ]
                onCurrentIndexChanged: {
                    plasmoid.configuration.filterIndex = currentIndex;
                }
                onCurrentValueChanged: {
                    cardsListView.currentIndex = -1;
                    filteredModel.secondaryFilter = filterComboBox.currentValue;
                }
            }
        }
    }

    Dialogs.FileDialog {
        id: openDialog
        onAccepted: {
            plasmoid.configuration.filePath = selectedFile;
            // This change will propogate to the onFilePathChanged connection in main.qml,
            // which will load the file for us.
            // It's okay not to call todoModel.loadFile here.
        }
        modality: Qt.ApplicationModal
        nameFilters: [i18nc("Filename filter", "Text files (*.txt)")]
    }

    PlasmaComponents3.ScrollView {
        id: scrollView
        anchors.fill: parent

        TodoListView {
            id: cardsListView

            model: filteredModel
            backtab: heading.visible ? searchField : null
            inApp: false
            onEditInAppClicked: taskText => plasmoid.launchKomodo(todoModel.filePath, taskText)

            topMargin: Kirigami.Units.largeSpacing
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
            bottomMargin: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            emptyMessage: Kirigami.PlaceholderMessage {
                type: Kirigami.PlaceholderMessage.Actionable
                icon.name: "org.kde.komodo"
                text: i18nc("@info:placeholder", "No To-Dos found.")

                helpfulAction: QQC2.Action {
                    icon.name: "story-editor"
                    text: i18nc("@action:button Shown when the to-do list is empty", "Edit in KomoDo…")
                    onTriggered: plasmoid.launchKomodo(todoModel.filePath)
                }
            }

            showNotLoadedMessage: !root.isLoaded
            notLoadedMessage: Kirigami.PlaceholderMessage {
                type: Kirigami.PlaceholderMessage.Actionable
                icon.name: "org.kde.komodo"
                text: i18nc("@info:placeholder", "Welcome to KomoDo!")

                helpfulAction: QQC2.Action {
                    icon.name: "document-open-symbolic"
                    text: i18nc("@action:button", "Open To-Do List…")
                    onTriggered: {
                        openDialog.open();
                    }
                }
            }
        }
    }
}

