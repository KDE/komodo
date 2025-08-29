// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.config as KConfig
import org.kde.coreaddons

import org.kde.komodo.ui

Kirigami.ApplicationWindow {
    id: root

    title: i18n("KomoDo")

    width: Kirigami.Units.gridUnit * 48
    height: Kirigami.Units.gridUnit * 36
    minimumWidth: Kirigami.Units.gridUnit * 32
    minimumHeight: Kirigami.Units.gridUnit * 20

    KConfig.WindowStateSaver {
        configGroupName: "MainWindow"
    }

    Component {
        id: aboutPage
        FormCard.AboutPage {
            horizontalScrollBarPolicy: QQC2.ScrollBar.AlwaysOff
            horizontalScrollBarInteractive: false
            aboutData: AboutData
        }
    }

    pageStack.initialPage: TodoPage {}
}
