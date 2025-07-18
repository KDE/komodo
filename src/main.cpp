// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "version-komodo.h"
#include <KAboutData>
#include <KDBusService>
#include <KLocalizedQmlContext>
#include <KLocalizedString>
#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QUrl>

constexpr auto APPLICATION_ID = "org.kde.komodo";
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("komodo");
    QApplication::setOrganizationName(QStringLiteral("KDE"));
    QApplication::setOrganizationDomain(QStringLiteral("kde.org"));
    QApplication::setApplicationName(QStringLiteral("KomoDo"));
    QApplication::setDesktopFileName(QStringLiteral("org.kde.komodo"));

    KAboutData aboutData(
        // The program name used internally.
        QStringLiteral("komodo"),
        // A displayable program name string.
        i18nc("@title", "KomoDo"),
        // The program version string.
        QStringLiteral(KOMODO_VERSION_STRING),
        // Short description of what the app does.
        i18n("todo.txt GUI application"),
        // The license this code is released under.
        KAboutLicense::GPL_V2,
        // Copyright Statement.
        i18n("© 2025 Akseli Lahtinen"));
    aboutData.addAuthor(i18nc("@info:credit", "Akseli Lahtinen"),
                        i18nc("@info:credit", "Author"),
                        QStringLiteral("komodo@akselmo.dev"),
                        QStringLiteral("https://akselmo.dev"));
    aboutData.setBugAddress("https://bugs.kde.org/describecomponents.cgi?product=KomoDo");
    aboutData.setProgramLogo(QIcon(QStringLiteral(":/komodo.png")));
    KAboutData::setApplicationData(aboutData);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.komodo")));

    KDBusService service(KDBusService::Unique);

    QApplication::setStyle(QStringLiteral("breeze"));
    QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));

    QQmlApplicationEngine engine;

    KLocalization::setupLocalizedContext(&engine);
    engine.loadFromModule(APPLICATION_ID, "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
