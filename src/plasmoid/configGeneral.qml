// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_filePath: filePathField.text
    property alias cfg_searchTerm: fixedSearchTermField.text
    property alias cfg_filterIndex: filterComboBox.currentIndex
    property bool cfg_searchBarEnabled
    property alias cfg_showBadge: showBadgeCheckBox.checked

    Kirigami.FormLayout {
        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.CheckBox {
                id: showBadgeCheckBox
                text: i18nc("@option:check", "Show number of incomplete tasks when on a panel")
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18nc("@info:tooltip Near the 'show badge' checkbox", "Tasks which are hidden by the search filter are not counted.");
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18nc("@label", "File path:")

            Kirigami.ActionTextField {
                id: filePathField

                Layout.fillWidth: true
                placeholderText: i18nc("@info:placeholder", "Path to To-Do list…")
                readOnly: true
            }

            QQC2.Button {
                id: filePathButton

                icon.name: "document-open"
                text: i18nc("@action:button", "Choose To-Do list…")
                display: QQC2.Button.IconOnly
                QQC2.ToolTip.text: text
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

                onClicked: fileDialog.open()

                Dialogs.FileDialog {
                    id: fileDialog
                    title: i18nc("@label:filedialog", "Choose a To-Do list")
                    nameFilters: [i18nc("Filename filter", "Text files (*.txt)")]
                    onAccepted: {
                        filePathField.text = selectedFile.toString()
                    }
                }
            }
        }

        QQC2.ButtonGroup {
            id: searchBarGroup
            buttons: [showSearchBar, hideSearchBar]
        }

        QQC2.RadioButton {
            id: showSearchBar
            Kirigami.FormData.label: i18nc("@label:group, followed by 'show' or 'hide, use ... instead'", "Search bar:")
            text: i18nc("@option:check, show search bar, following 'search bar'", "Show")
            checked: cfg_searchBarEnabled
            onClicked: cfg_searchBarEnabled = true
        }

        QQC2.RadioButton {
            id: hideSearchBar
            text: i18nc("@option:check, hide search bar, following 'search bar'", "Hide, use these values instead:")
            checked: !cfg_searchBarEnabled
            onClicked: cfg_searchBarEnabled = false
        }

        RowLayout {
            enabled: !cfg_searchBarEnabled

            // Indentation for child
            Item {
                implicitWidth: Application.layoutDirection === Qt.RightToLeft ? hideSearchBar.contentItem.rightPadding : hideSearchBar.contentItem.leftPadding
            }

            ColumnLayout {
                Kirigami.ActionTextField {
                    id: fixedSearchTermField
                    placeholderText: i18nc("@info:placeholder", "Search term…")

                    rightActions: Kirigami.Action {
                        icon.name: "edit-clear"
                        visible: fixedSearchTermField.text.length > 0
                        onTriggered: {
                            fixedSearchTermField.clear();
                            fixedSearchTermField.accepted();
                        }
                    }
                }

                QQC2.ComboBox {
                    id: filterComboBox
                    editable: false
                    textRole: "text"
                    valueRole: "value"
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
                }
            }
        }
    }
}
