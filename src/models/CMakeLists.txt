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
    Todo.h
    Todo.cpp
    TodoModel.h
    TodoModel.cpp
)

target_link_libraries(models
    PRIVATE
    Qt6::Core
    Qt6::Gui
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::GuiAddons
    logging
)


ecm_finalize_qml_module(models)

install(TARGETS models ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
