
add_library(models)

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
    logging
)

ecm_finalize_qml_module(models)

install(TARGETS models ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
