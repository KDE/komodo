# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

add_library(${CMAKE_PROJECT_NAME}_models STATIC)

ecm_add_qml_module(${CMAKE_PROJECT_NAME}_models
    URI
    org.kde.${CMAKE_PROJECT_NAME}.models
    GENERATE_PLUGIN_SOURCE
)

kconfig_target_kcfg_file(${CMAKE_PROJECT_NAME}_models FILE komodo_config.kcfg CLASS_NAME KomodoConfig MUTATORS GENERATE_PROPERTIES GENERATE_MOC DEFAULT_VALUE_GETTERS QML_REGISTRATION SINGLETON)

target_sources(${CMAKE_PROJECT_NAME}_models
    PRIVATE
    Todo.cpp
    TodoModel.cpp
    Todo.h
    TodoModel.h
)

target_link_libraries(${CMAKE_PROJECT_NAME}_models
    PUBLIC
    KF6::ConfigGui
    KF6::ConfigCore
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    KF6::GuiAddons
    KF6::ColorScheme
    KF6::CoreAddons
)

ecm_finalize_qml_module(${CMAKE_PROJECT_NAME}_models DESTINATION ${KDE_INSTALL_QMLDIR})
