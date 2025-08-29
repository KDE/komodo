# SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.20)
project(komodo VERSION 1.0.0)

string(TOUPPER ${CMAKE_PROJECT_NAME} CMAKE_PROJECT_NAME_UPPERCASE)
include(FeatureSummary)

set(QT_MIN_VERSION 6.6)
set(KF_MIN_VERSION 6.13)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMQtDeclareLoggingCategory)
include(ECMDeprecationSettings)
include(ECMQmlModule)
include(ECMCheckOutboundLicense)
include(KDEClangFormat)
include(KDEGitCommitHooks)

ecm_setup_version(PROJECT
    VARIABLE_PREFIX ${CMAKE_PROJECT_NAME_UPPERCASE}
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/version-${CMAKE_PROJECT_NAME}.h"
)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml QuickControls2 Widgets)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS ColorScheme Kirigami CoreAddons Config I18n ItemModels QQC2DesktopStyle GuiAddons IconThemes DocTools)

set(USE_DBUS OFF)
if(UNIX AND NOT APPLE AND NOT ANDROID AND NOT HAIKU)
    set(USE_DBUS ON)
endif()
if(USE_DBUS)
    find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS DBusAddons)
    add_compile_definitions(-DUSE_DBUS)
endif()

find_package(KF6KirigamiAddons 1.9 REQUIRED)
set_package_properties(KF6QQC2DesktopStyle PROPERTIES TYPE RUNTIME)

add_subdirectory(src)

install(PROGRAMS org.kde.${CMAKE_PROJECT_NAME}.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.${CMAKE_PROJECT_NAME}.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.${CMAKE_PROJECT_NAME}.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

add_subdirectory(doc)

ki18n_install(po)
kdoctools_install(po)

ecm_qt_install_logging_categories(
    EXPORT ${CMAKE_PROJECT_NAME}_EXPORT
    FILE ${CMAKE_PROJECT_NAME}.categories
    DESTINATION ${KDE_INSTALL_LOGGINGCATEGORIESDIR}
)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

file(GLOB_RECURSE ALL_SOURCE_FILES *.cpp *.h *.qml)
ecm_check_outbound_license(LICENSES GPL-2.0-or-later FILES ${ALL_SOURCE_FILES})
