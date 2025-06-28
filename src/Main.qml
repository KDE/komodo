// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.config as KConfig
import org.kde.coreaddons

import org.kde.komodo.ui

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: root

    title: i18n("KomoDo")

    width: Kirigami.Units.gridUnit * 48
    height: Kirigami.Units.gridUnit * 36
    minimumWidth: Kirigami.Units.gridUnit * 30
    minimumHeight: Kirigami.Units.gridUnit * 36

    KConfig.WindowStateSaver {
        configGroupName: "MainWindow"
    }

    Component {
        id: aboutPage
        FormCard.AboutPage {
            aboutData: AboutData
        }
    }

    pageStack.initialPage: TodoPage {}


}
