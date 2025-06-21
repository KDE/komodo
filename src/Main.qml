// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import TodoModel 1.0

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: root

    TodoModel {
        id: todoModel
    }

    Kirigami.OverlaySheet {
        id: editPrompt

        property var model
        property alias text: editPromptText.text

        title: "Edit Todo"

        Controls.TextField {
            id: editPromptText
        }

        footer: Controls.DialogButtonBox {
            standardButtons: Controls.DialogButtonBox.Ok
            onAccepted: {
                const model = editPrompt.model;
                model.description = editPromptText.text;
                editPrompt.close();
            }
        }
    }

    Kirigami.OverlaySheet {
        id: addPrompt

        title: "Add New Todo"

        Controls.TextField {
            id: addPromptText
        }

        footer: Controls.DialogButtonBox {
            standardButtons: Controls.DialogButtonBox.Ok
            onAccepted: {
                todoModel.addTodo(addPromptText.text);
                addPromptText.text = ""; // Clear TextField every time it's done
                addPrompt.close();
            }
        }
    }


    pageStack.initialPage: Kirigami.ScrollablePage {
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
                model: todoModel
                delegate: Kirigami.AbstractCard {
                    Layout.fillHeight: true
                    header: Kirigami.Heading {
                        text: model.completion
                        level: 2
                    }
                    contentItem: Item {
                        implicitWidth: delegateLayout.implicitWidth
                        implicitHeight: delegateLayout.implicitHeight
                        ColumnLayout {
                            id: delegateLayout
                            Controls.Label {
                                text: model.description
                            }
                            Controls.Button {
                                text: "Edit"
                                onClicked: {
                                    editPrompt.text = model.description;
                                    editPrompt.model = model;
                                    editPrompt.open();
                                }
                            }
                            Controls.Button {
                                text: "Delete"
                                onClicked: {
                                    todoModel.deleteTodo(model.lineNumber, index);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
