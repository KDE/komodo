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
		onAccepted: { TodoModel.filePath = selectedFile; }
		modality: Qt.ApplicationModal
		nameFilters: ["Text files (*.txt)"]
	}

	Dialogs.FileDialog {
		id: createNewDialog
		onAccepted: { TodoModel.filePath = selectedFile; }
		fileMode: Qt.SaveFile
		modality: Qt.ApplicationModal
		nameFilters: ["Text files (*.txt)"]
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
			id: addPromptText
			anchors.fill: parent
			placeholderText: "(A) 2024-01-01 description +project @context key:value"
		}

		footer: QQC2.DialogButtonBox {
			standardButtons: QQC2.DialogButtonBox.Ok
			onAccepted: {
				TodoModel.addTodo(addPromptText.text);
				addPromptText.text = ""; // Clear TextField every time it's done
				addPrompt.close();
			}
		}
	}


	header: Kirigami.SearchField {
		id: searchField
		visible: true
	}

	actions: [
		Kirigami.Action {
			icon.name: "document-open"
			text: i18nc("@action:button", "Open File…")
			onTriggered: {
				openDialog.open();
			}
		},
		Kirigami.Action {
			icon.name: "add"
			text: i18nc("@action:button","Add New Todo…")
			enabled: TodoModel.filePath != ""
			onTriggered: {
				addPrompt.open();
			}
		},
		Kirigami.Action {
			text: i18nc("@action:inmenu", "About KomoDo")
			icon.name: "help-about"
			shortcut: StandardKey.HelpContents
			displayHint: Kirigami.DisplayHint.AlwaysHide
			onTriggered: pageStack.layers.push(aboutPage)
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
			explanation: xi18nc("@info:placeholder", "Click <interface>Open File…</interface> to start or create new one")
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

		delegate: Kirigami.AbstractCard {
			id: todoDelegate
			// TODO: clicking on card starts editing it

			property var projects: model.projects
			property var contexts: model.contexts
			property var keyValuePairs: model.keyValuePairs

			contentItem: Item {
				implicitWidth: delegateLayout.implicitWidth
				implicitHeight: delegateLayout.implicitHeight

				GridLayout {
					id: delegateLayout
					anchors {
						left: parent.left
						top: parent.top
						right: parent.right
					}
					rowSpacing: Kirigami.Units.largeSpacing
					columnSpacing: Kirigami.Units.largeSpacing
					columns: width > Kirigami.Units.gridUnit * 20 ? 4 : 2
					ColumnLayout {
						QQC2.CheckBox {
							id: completionStatus
							Layout.alignment: Qt.AlignCenter
							checked: model.completion
							onToggled: model.completion = !model.completion
						}
					}

					ColumnLayout {
						RowLayout {
							width: parent.width

							QQC2.Label {
								visible: model.priority
								text: model.priority
								font.bold: true
								//TODO Set color by priority status?
							}

							Kirigami.Heading {
								Layout.fillWidth: true
								wrapMode: Text.WordWrap
								text: model.prettyDescription
								level: 1
							}
						}

						Kirigami.Separator {
							Layout.fillWidth: true
						}
						RowLayout {
							QQC2.Label {
								visible: projects.length > 0
								text: "Projects:"
								font.bold: true
							}
							Repeater {
								Layout.fillWidth: true
								model: projects
								Kirigami.Chip {
									id: projectChip
									closable: false
									text: modelData
								}
							}
						}

						RowLayout {
							QQC2.Label {
								visible: contexts.length > 0
								text: "Contexts:"
								font.bold: true
							}
							Repeater {
								Layout.fillWidth: true
								model: contexts
								Kirigami.Chip {
									id: contextChip
									closable: false
									text: modelData
								}
							}
						}

						RowLayout {
							QQC2.Label {
								visible: keyValuePairs.length > 0
								text: "MetaData:"
								font.bold: true
							}
							Repeater {
								Layout.fillWidth: true
								model: keyValuePairs
								Kirigami.Chip {
									id: keyValuePairChip
									closable: false
									text: modelData
								}
							}
						}

						QQC2.Label {
							visible: false
							Layout.fillWidth: true
							anchors.margins: Kirigami.Units.smallSpacing
							wrapMode: Text.WordWrap
							text: model.description
						}

						Kirigami.Separator {
							Layout.fillWidth: true
						}

						Kirigami.ActionToolBar {
							id: actionsToolBar
							actions: [
								Kirigami.Action {
									text: i18nc("@button","Edit")
									icon.name: "edit-entry"
									onTriggered: {
										editPrompt.text = model.description;
										editPrompt.model = model;
										editPrompt.open();
									}
								},
								Kirigami.Action {
									text: i18nc("@button","Delete")
									icon.name: "delete"
									onTriggered: {
										const originalIndex = filteredModel.index(index, 0);
										TodoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
									}
								}
							]
							position: QQC2.ToolBar.Footer
						}
					}
				}
			}
		}
	}
}