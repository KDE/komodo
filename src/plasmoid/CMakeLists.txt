# SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
# SPDX-License-Identifier: BSD-2-Clause

plasma_add_applet(org.kde.${CMAKE_PROJECT_NAME}.widget
    CPP_SOURCES
        komodowidgetplugin.cpp
        komodowidgetplugin.h
    QML_SOURCES
        main.qml
        CompactRepresentation.qml
        FullRepresentation.qml
        config.qml
        configGeneral.qml
    RESOURCES
        main.xml
)

target_link_libraries(org.kde.${CMAKE_PROJECT_NAME}.widget PRIVATE
    Plasma::Plasma
    ${CMAKE_PROJECT_NAME}_models
    ${CMAKE_PROJECT_NAME}_ui
)

