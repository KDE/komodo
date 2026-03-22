// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Applet>

class KomodoWidgetPlugin : public Plasma::Applet
{
    Q_OBJECT

public:
    KomodoWidgetPlugin(QObject *parent, const KPluginMetaData &data, const QVariantList &args);

    Q_INVOKABLE void launchKomodo(QUrl path);
    Q_INVOKABLE void launchKomodo(QUrl path, QString searchText);
};
