cmake_minimum_required(VERSION 3.16)
project(ksmartmonitor-cli)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)

find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(KF6 REQUIRED COMPONENTS Auth)

add_executable(ksmartmonitor-cli main.cpp)
target_link_libraries(ksmartmonitor-cli Qt6::Core KF6::AuthCore)

install(TARGETS ksmartmonitor-cli DESTINATION ${KDE_INSTALL_BINDIR})