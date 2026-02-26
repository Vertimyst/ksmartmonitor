import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: driveItem
    
    width: ListView.view.width
    
    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Kirigami.Icon {
                source: {
                    if (modelData.type === "NVME") return "drive-harddisk-solidstate"
                    if (modelData.type === "SSD") return "drive-harddisk-solidstate"
                    return "drive-harddisk"
                }
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: {
                    if (modelData.health === "FAILING") return Kirigami.Theme.negativeTextColor
                    if (modelData.health === "WARNING") return Kirigami.Theme.neutralTextColor
                    return Kirigami.Theme.positiveTextColor
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                
                QQC2.Label {
                    text: modelData.displayName || modelData.device
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                QQC2.Label {
                    text: modelData.displayName ? modelData.device : (modelData.model || "Unknown model")
                    opacity: 0.6
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
            
            ColumnLayout {
                spacing: 0
                
                QQC2.Label {
                    text: {
                        if (modelData.health === "FAILING") return "FAILING"
                        if (modelData.health === "WARNING") return "WARNING"
                        return "PASSED"
                    }
                    font.bold: true
                    color: {
                        if (modelData.health === "FAILING") return Kirigami.Theme.negativeTextColor
                        if (modelData.health === "WARNING") return Kirigami.Theme.neutralTextColor
                        return Kirigami.Theme.positiveTextColor
                    }
                }
                
                QQC2.Label {
                    text: modelData.temperature > 0 ? modelData.temperature + "°C" : "N/A"
                    opacity: 0.8
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: {
                        if (modelData.temperature > 60) return Kirigami.Theme.negativeTextColor
                        if (modelData.temperature > 55) return Kirigami.Theme.neutralTextColor
                        return Kirigami.Theme.textColor
                    }
                }
            }
        }
        
        // SMART attributes
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing
            columns: 2
            rowSpacing: 2
            columnSpacing: Kirigami.Units.smallSpacing
            visible: modelData.attributes && modelData.attributes.length > 0
            
            Repeater {
                model: modelData.attributes || []
                
                QQC2.Label {
                    text: modelData.name + ":"
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    opacity: 0.6
                    Layout.row: index
                    Layout.column: 0
                    Layout.alignment: Qt.AlignRight
                }
            }
            
            Repeater {
                model: modelData.attributes || []
                
                QQC2.Label {
                    text: modelData.value
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    Layout.row: index
                    Layout.column: 1
                    Layout.fillWidth: true
                }
            }
        }
    }
}
