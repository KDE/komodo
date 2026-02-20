# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
# SPDX-License-Identifier: BSD-2-Clause

add_library(${CMAKE_PROJECT_NAME}_models SHARED)

ecm_add_qml_module(${CMAKE_PROJECT_NAME}_models
    URI "org.kde.komodo.models"
    org.kde.${CMAKE_PROJECT_NAME}.models
    GENERATE_PLUGIN_SOURCE
)

target_sources(${CMAKE_PROJECT_NAME}_models
    PRIVATE
    Todo.cpp
    TodoModel.cpp
    Todo.h
    TodoModel.h
)

target_link_libraries(${CMAKE_PROJECT_NAME}_models
    PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    KF6::GuiAddons
    KF6::ColorScheme
    KF6::CoreAddons
)

ecm_finalize_qml_module(${CMAKE_PROJECT_NAME}_models DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT ${CMAKE_PROJECT_NAME})

install(TARGETS ${CMAKE_PROJECT_NAME}_models ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

