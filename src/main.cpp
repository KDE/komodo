// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "version-komodo.h"
#include <KAboutData>
#include <KIconTheme>
#include <KLocalizedQmlContext>
#include <KLocalizedString>
#include <QApplication>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#ifdef USE_DBUS
#include <KDBusService>
#endif

constexpr auto APPLICATION_ID = "org.kde.komodo";
int main(int argc, char *argv[])
{
    KIconTheme::initTheme();

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
    QCommandLineParser parser;

    auto searchArgName = QStringLiteral("search-text");
    auto filenameArgName = QStringLiteral("filename");

    parser.addOption(QCommandLineOption(searchArgName, i18nc("@info:shell", "Inserts the given text in the search bar."), searchArgName));
    parser.addOption(
        QCommandLineOption(filenameArgName, i18nc("@info:shell", "Open the given filename. The one in the config will be ignored."), filenameArgName));
    aboutData.setupCommandLine(&parser);
    parser.process(app);
    aboutData.processCommandLine(&parser);

    if (parser.isSet(searchArgName)) {
        app.instance()->setProperty(searchArgName.toStdString().c_str(), parser.value(searchArgName));
    }
    if (parser.isSet(filenameArgName)) {
        app.instance()->setProperty(filenameArgName.toStdString().c_str(), parser.value(filenameArgName));
    }

    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.komodo")));

#ifdef USE_DBUS
    KDBusService service(KDBusService::Unique);
#endif

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
