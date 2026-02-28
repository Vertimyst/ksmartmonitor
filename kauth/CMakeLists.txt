add_executable(smartmonitorhelper smartmonitorhelper.cpp)
target_link_libraries(smartmonitorhelper 
    Qt6::Core 
    KF6::AuthCore
)

install(TARGETS smartmonitorhelper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})

kauth_install_helper_files(smartmonitorhelper com.github.vertimyst.ksmartmonitor root)
kauth_install_actions(com.github.vertimyst.ksmartmonitor com.github.vertimyst.ksmartmonitor.actions)