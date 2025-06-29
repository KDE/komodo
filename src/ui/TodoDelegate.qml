// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
	id: todoDelegate
	clip: true

	property var todoModel
	property var projects: model.projects
	property var contexts: model.contexts
	property var keyValuePairs: model.keyValuePairs


	header: RowLayout {
		width: parent.width

		QQC2.CheckBox {
			id: completionStatus
			Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
			checked: model.completion
			onToggled: model.completion = !model.completion
		}

		Kirigami.SelectableLabel {
			Layout.fillWidth: true
			wrapMode: Text.WordWrap
			text: model.prettyDescription
			font.strikeout: model.completion
			font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.35
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
				QQC2.Label {
					visible: model.priority
					text: i18nc("Task priority", "Priority: ")
					font.bold: true
				}

				Kirigami.Chip {
					visible: model.priority
					text: model.priority
					font.bold: true
					closable: false
					checkable: false
					//TODO Set color by priority status?
				}
			}

			RowLayout {
				QQC2.Label {
					visible: model.creationDate
					text: i18nc("Task creation date", "Created: ")
					font.bold: true
				}
				Kirigami.Chip {
					visible: model.creationDate
					text: model.creationDate
					font.bold: false
					closable: false
					checkable: false
					// TODO clicking this will add the date to search
				}
			}

			RowLayout {

				Kirigami.SelectableLabel {
					visible: model.completionDate
					text: i18nc("Task completion date", "Completed: ")
					font.bold: true
				}
				Kirigami.Chip {
					visible: model.completionDate
					text: model.completionDate
					font.bold: false
					closable: false
					checkable: false
				}
			}

			Repeater {
				model: keyValuePairs
				RowLayout {
					id: keyValPair
					property var textData: modelData.split(":")
					property var textUrl: {
						let value = ""
						// Split the value like this in case its URL
						if (textData[1].startsWith("http")){
							const url = modelData.split(":").slice(1).join(":");
							value = url;
						}
						return value;
					}

					Kirigami.SelectableLabel {
						id: keyLabel
						text: parent.textData[0] + ": "
						font.bold: true
						Layout.alignment: Qt.AlignLeft
					}

					Kirigami.SelectableLabel {
						text: parent.textData[1]
						wrapMode: Qt.TextWrapAnywhere
						visible: !textUrl
						Layout.alignment: Qt.AlignLeft
					}

					Kirigami.UrlButton {
						Layout.maximumWidth: delegateLayout.width - keyLabel.width - Kirigami.Units.smallSpacing
						Layout.alignment: Qt.AlignLeft
						visible: textUrl
						wrapMode: Qt.TextWrapAnywhere
						elide: Text.ElideRight
						text: textUrl
						url: textUrl
					}
				}
			}

			Kirigami.Separator {
				Layout.fillWidth: true
			}
		}
	}

	footer: Kirigami.ActionToolBar {
		id: actionsToolBar
		alignment: Qt.AlignRight
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
					todoModel.deleteTodo(filteredModel.mapToSource(originalIndex));
				}
			}
		]
		position: QQC2.ToolBar.Footer
	}

}
