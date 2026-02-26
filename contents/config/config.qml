import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-system"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Drives")
        icon: "drive-harddisk"
        source: "configDrives.qml"
    }
}
