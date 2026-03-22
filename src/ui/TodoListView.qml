// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import org.kde.kirigami as Kirigami

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

    property alias model: cardsListView.model
    property var backtab: null

    property bool inApp: true
    signal editInAppClicked(taskText: string)

    property alias notLoadedMessage: noTodosLoaded.sourceComponent
    property bool showNotLoadedMessage: false

    property alias emptyMessage: noTodosFound.sourceComponent

    Loader {
        id: noTodosLoaded
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        anchors.centerIn: parent
        visible: showNotLoadedMessage
    }

    Loader {
        id: noTodosFound
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        anchors.centerIn: parent
        visible: !showNotLoadedMessage && model.count === 0
    }

    delegate: TodoDelegate {
        id: delegate
        backtab: cardsListView.backtab
        inApp: cardsListView.inApp
        onEditInAppClicked: taskText => cardsListView.editInAppClicked(taskText)

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

