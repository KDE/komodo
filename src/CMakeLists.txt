add_executable(todoapp)

ecm_add_qml_module(todoapp
    URI
    org.kde.todoapp
)

target_sources(todoapp
    PRIVATE
    main.cpp
)

ecm_target_qml_sources(todoapp
    SOURCES
    Main.qml
)

target_link_libraries(todoapp
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

install(TARGETS todoapp ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
