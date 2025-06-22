// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels
import TodoModel 1.0
import org.kde.todoapp.ui

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: root

    TodoModel {
        id: todoModel
    }


    QQC2.Dialog {
        id: editPrompt
        title: "Edit Todo"
        padding: 10
        anchors.centerIn: parent
        modal: true
        property var model
        property alias text: editPromptText.text

        ColumnLayout {
            anchors.fill: parent
            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: editPrompt.model.description
            }

            QQC2.TextField {
                id: editPromptText
                Layout.fillWidth: true
                placeholderText: editPrompt.model.description
            }

        }
        footer: QQC2.DialogButtonBox {
            standardButtons: QQC2.DialogButtonBox.Ok
            onAccepted: {
                const model = editPrompt.model;
                model.description = editPromptText.text;
                editPrompt.close();
            }
        }
    }

    QQC2.Dialog {
        id: addPrompt
        anchors.centerIn: parent
        title: "Add New Todo"
        modal: true
        QQC2.TextField {
            anchors.fill: parent
            id: addPromptText
            placeholderText: "(A) 2024-01-01 description +project @context key:value"
        }

        footer: QQC2.DialogButtonBox {
            standardButtons: QQC2.DialogButtonBox.Ok
            onAccepted: {
                todoModel.addTodo(addPromptText.text);
                addPromptText.text = ""; // Clear TextField every time it's done
                addPrompt.close();
            }
        }
    }


    pageStack.initialPage: Kirigami.ScrollablePage {

        id: page

        header: Kirigami.SearchField {
            id: searchField
            visible: true
        }

        actions: [
            Kirigami.Action {
                icon.name: "add"
                text: "Add New Todo"
                onTriggered: {
                    addPrompt.open();
                }
            }
        ]
        ColumnLayout {
            Repeater {
                model: KSortFilterProxyModel {
                    id: filteredModel
                    sourceModel: todoModel
                    filterRoleName: "description"
                    sortRoleName: "description"
                    filterString: searchField.text
                    filterCaseSensitivity: Qt.CaseInsensitive
                }


                delegate: Kirigami.Card {
                    anchors.margins: Kirigami.Units.smallSpacing
                    implicitWidth: root.width
                    header: RowLayout {
                        width: parent.width
                        QQC2.CheckBox {
                            id: completionStatus
                            checked: model.completion
                            onToggled: model.completion = !model.completion
                        }

                        Kirigami.Heading {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: model.prettyDescription
                            level: 2
                        }

                    }
                    contentItem: QQC2.Label {
                        anchors.margins: Kirigami.Units.smallSpacing
                        wrapMode: Text.WordWrap
                        text: model.description
                    }

                    actions: [
                        Kirigami.Action {
                            text: "Edit"
                            icon.name: "edit-entry"
                            onTriggered: {
                                editPrompt.text = model.description;
                                editPrompt.model = model;
                                editPrompt.open();
                            }
                        },
                        Kirigami.Action {
                            text: "Delete"
                            icon.name: "delete"
                            onTriggered: {
                                const originalIndex = filteredModel.index(index, 0)
                                todoModel.deleteTodo(filteredModel.mapToSource(originalIndex))
                            }
                        }
                    ]
                }
            }
        }
    }
}
