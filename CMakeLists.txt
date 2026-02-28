cmake_minimum_required(VERSION 3.16)
project(ksmartmonitor)

set(QT_MIN_VERSION "6.6.0")
set(KF_MIN_VERSION "6.0.0")

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEPackageAppTemplates)
include(FeatureSummary)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Core
    Gui
)

find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Auth
    CoreAddons
)

add_subdirectory(kauth)
add_subdirectory(cli-invoker)

# Install the plasmoid manually
install(DIRECTORY contents DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/com.github.vertimyst.ksmartmonitor)
install(FILES metadata.json DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/com.github.vertimyst.ksmartmonitor)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
