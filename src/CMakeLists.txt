# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

add_executable(${CMAKE_PROJECT_NAME}
    main.cpp
)

ecm_qt_declare_logging_category(${CMAKE_PROJECT_NAME}
    HEADER ${CMAKE_PROJECT_NAME}_debug.h
    IDENTIFIER ${CMAKE_PROJECT_NAME_UPPERCASE}_LOG
    CATEGORY_NAME org.kde.${CMAKE_PROJECT_NAME}
    DESCRIPTION "komodo"
    EXPORT ${CMAKE_PROJECT_NAME}_EXPORT
)

ecm_add_qml_module(${CMAKE_PROJECT_NAME}
    URI
    org.kde.${CMAKE_PROJECT_NAME}
    DEPENDENCIES
    org.kde.${CMAKE_PROJECT_NAME}.ui
)

ecm_target_qml_sources(${CMAKE_PROJECT_NAME}
    SOURCES
    Main.qml
)

target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::WindowSystem
    KF6::I18n
    KF6::I18nQml
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::GuiAddons
    KF6::ColorScheme
    KF6::DBusAddons
    ${CMAKE_PROJECT_NAME}_uiplugin
    ${CMAKE_PROJECT_NAME}_modelsplugin
)

install(TARGETS ${CMAKE_PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

add_subdirectory(models)
add_subdirectory(ui)

if(BUILD_TESTING)
    add_subdirectory(autotests)
endif()
