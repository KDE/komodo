// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
	id: todoDelegate
	clip: true

	property var projects: model.projects
	property var contexts: model.contexts
	property var keyValuePairs: model.keyValuePairs

	header: RowLayout {
		width: parent.width

		Kirigami.Chip {
			visible: model.priority
			text: model.priority
			font.bold: true
			closable: false
			checkable: false
			//TODO Set color by priority status?
		}

		Kirigami.Heading {
			Layout.fillWidth: true
			wrapMode: Text.WordWrap
			text: model.prettyDescription
			level: 1
			// TODO: we could parse this description and then colorize/chip-ify any + and @
		}
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
				Kirigami.Chip {
					visible: model.creationDate
					text: i18nc("Task creation date", "Created: ") +  model.creationDate
					font.bold: false
					closable: false
					checkable: false
				}

				Kirigami.Chip {
					visible: model.completionDate
					text: i18nc("Task completion date", "Completed: ") +  model.completionDate
					font.bold: false
					closable: false
					checkable: false
					// TODO: allow changing these dates?
				}
			}

			Repeater {
				model: keyValuePairs
				Kirigami.SelectableLabel {
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignLeft
					onLinkActivated: Qt.openUrlExternally(link)
					text: {
						const textData = modelData.split(":");
						const key = textData[0];
						let value = textData[1]
						// Split the value like this in case its URL
						if (textData[1].startsWith("http")){
							const url = modelData.split(":").slice(1).join(":");
							value = "<a href='" + url +"'>" + url + "</a>";
						}
						return key + ": " + value;
					}
				}
			}
		}
	}

	footer: Kirigami.ActionToolBar {
		id: actionsToolBar
		actions: [
			Kirigami.Action {
				checkable: true
				checked: model.completion
				text: ""
				icon.name: model.completion ? "emblem-checked" : "emblem-unavailable"
				onTriggered: {
					model.completion = !model.completion
				}
			},

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
