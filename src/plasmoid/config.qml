// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nc("@title:tab Configuration category", "General")
        icon: "configure"
        source: "configGeneral.qml"
    }
}
