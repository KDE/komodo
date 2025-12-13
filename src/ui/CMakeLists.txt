# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
# SPDX-License-Identifier: BSD-2-Clause

add_library(${CMAKE_PROJECT_NAME}_ui SHARED)

ecm_add_qml_module(${CMAKE_PROJECT_NAME}_ui
    URI
    org.kde.${CMAKE_PROJECT_NAME}.ui
    GENERATE_PLUGIN_SOURCE
)

ecm_target_qml_sources(${CMAKE_PROJECT_NAME}_ui
    SOURCES
    TodoDelegate.qml
)

install(TARGETS ${CMAKE_PROJECT_NAME}_ui ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

