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

constexpr auto APPLICATION_ID = "org.kde.komodo";
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("komodo");

    KAboutData aboutData(
        // The program name used internally.
        QStringLiteral("komodo"),
        // A displayable program name string.
        i18nc("@title", "KomoDo"),
        // The program version string.
        QStringLiteral(KOMODO_VERSION_STRING),
        // Short description of what the app does.
        i18n("Work on To-Do lists"),
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
    aboutData.setOtherText(i18nc("Longer description in about page",
                                 "<p>KomoDo is a todo manager that uses todo.txt specification. It parses any compliant todo.txt files and turns them into "
                                 "easy to use list of tasks.</p>"));
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
