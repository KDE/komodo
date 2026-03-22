// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "komodowidgetplugin.h"

#include <QProcess>

KomodoWidgetPlugin::KomodoWidgetPlugin(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Applet(parent, data, args)
{
}

void KomodoWidgetPlugin::launchKomodo(QUrl path)
{
    auto m_process = new QProcess(this);
    m_process->start(QStringLiteral("komodo"), {QStringLiteral("--filename"), path.toLocalFile()});
}

void KomodoWidgetPlugin::launchKomodo(QUrl path, QString searchText)
{
    auto m_process = new QProcess(this);
    m_process->start(QStringLiteral("komodo"), {QStringLiteral("--filename"), path.toLocalFile(), QStringLiteral("--search-text"), searchText});
}

K_PLUGIN_CLASS_WITH_JSON(KomodoWidgetPlugin, "metadata.json")

#include "komodowidgetplugin.moc"
