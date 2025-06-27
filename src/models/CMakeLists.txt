
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
    KF6::ConfigCore
    KF6::ConfigGui
    logging
)


ecm_finalize_qml_module(models)

install(TARGETS models ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
