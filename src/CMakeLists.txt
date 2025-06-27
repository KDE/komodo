add_executable(${CMAKE_PROJECT_NAME})

ecm_add_qml_module(todoapp
    URI
    org.kde.todoapp
)

target_sources(todoapp
    PRIVATE
    main.cpp
    Todo.cpp
    TodoModel.cpp
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
    Qt6::Core
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)


install(TARGETS ${CMAKE_PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})