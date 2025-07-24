# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

add_library(${CMAKE_PROJECT_NAME}_ui)

ecm_add_qml_module(${CMAKE_PROJECT_NAME}_ui
    URI
    org.kde.${CMAKE_PROJECT_NAME}.ui
    GENERATE_PLUGIN_SOURCE
    DEPENDENCIES
    org.kde.kitemmodels
    org.kde.${CMAKE_PROJECT_NAME}.models
)

ecm_target_qml_sources(${CMAKE_PROJECT_NAME}_ui
    SOURCES
    TodoPage.qml
    TodoDelegate.qml
    KomoDoHelp.qml
)

ecm_finalize_qml_module(${CMAKE_PROJECT_NAME}_ui)

install(TARGETS ${CMAKE_PROJECT_NAME}_ui ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

