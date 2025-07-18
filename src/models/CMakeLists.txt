# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

add_library(models)

kconfig_target_kcfg_file(models FILE komodo_config.kcfg CLASS_NAME KomodoConfig MUTATORS GENERATE_PROPERTIES GENERATE_MOC DEFAULT_VALUE_GETTERS QML_REGISTRATION SINGLETON)

ecm_add_qml_module(models
    URI
    org.kde.${CMAKE_PROJECT_NAME}.models
    GENERATE_PLUGIN_SOURCE
)

target_sources(models
    PRIVATE
    Todo.cpp
    TodoModel.cpp
    Todo.h
    TodoModel.h
)

target_link_libraries(models
    PUBLIC
    KF6::ConfigGui
    KF6::ConfigCore
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    KF6::GuiAddons
    KF6::ColorScheme
    KF6::CoreAddons
    logging
)

ecm_finalize_qml_module(models)

install(TARGETS models ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})