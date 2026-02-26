import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

Item {
    id: fullRoot
    
    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 15
    Layout.preferredWidth: Kirigami.Units.gridUnit * 25
    Layout.preferredHeight: Kirigami.Units.gridUnit * 20
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            PlasmaExtras.Heading {
                level: 3
                text: "Drive Health Monitor"
                Layout.fillWidth: true
            }
            
            QQC2.Button {
                icon.name: "view-refresh"
                onClicked: root.updateDriveData()
                QQC2.ToolTip.text: "Refresh SMART data"
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
        }
        
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: driveListView
                
                model: root.driveData
                spacing: Kirigami.Units.smallSpacing
                
                delegate: DriveItem {}
                
                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.largeSpacing * 4)
                    visible: root.driveData.length === 0 && !root.hasError
                    text: "No drives detected"
                    explanation: "Make sure smartmontools is installed and you have permission to access SMART data"
                    icon.name: "drive-harddisk"
                }
                
                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.largeSpacing * 4)
                    visible: root.hasError
                    text: "Error reading SMART data"
                    explanation: root.errorMessage
                    icon.name: "data-error"
                    
                    helpfulAction: Kirigami.Action {
                        text: "Retry"
                        icon.name: "view-refresh"
                        onTriggered: root.updateDriveData()
                    }
                }
            }
        }
        
        // Footer with last update time
        QQC2.Label {
            Layout.fillWidth: true
            text: "Last updated: " + Qt.formatDateTime(root.lastUpdateTime, "hh:mm:ss")
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            opacity: 0.6
            horizontalAlignment: Text.AlignRight
        }
    }
}
