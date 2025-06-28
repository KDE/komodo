# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

add_library(ui)

ecm_add_qml_module(ui
    URI
    org.kde.${CMAKE_PROJECT_NAME}.ui
    GENERATE_PLUGIN_SOURCE
    DEPENDENCIES
    org.kde.kitemmodels
    org.kde.${CMAKE_PROJECT_NAME}.models
)

ecm_target_qml_sources(ui
    SOURCES
    TodoPage.qml
)

ecm_finalize_qml_module(ui)

install(TARGETS ui ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

