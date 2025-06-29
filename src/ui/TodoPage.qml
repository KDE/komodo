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

		delegate: TodoDelegate { }
	}
}