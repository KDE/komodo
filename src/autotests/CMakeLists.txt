# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

add_library(models_test STATIC ../models/Todo.cpp ../models/TodoModel.cpp)

kconfig_target_kcfg_file(models_test FILE ../models/komodo_config.kcfg CLASS_NAME KomodoConfig MUTATORS GENERATE_PROPERTIES GENERATE_MOC DEFAULT_VALUE_GETTERS QML_REGISTRATION SINGLETON)

target_link_libraries(models_test
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

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})

find_package(Qt6Test CONFIG REQUIRED)
include(ECMAddTests)

ecm_add_test(todomodel_test.cpp LINK_LIBRARIES models_test Qt6::Test)
target_compile_definitions(todomodel_test PRIVATE TODO_TXT_FILE="todo.txt")