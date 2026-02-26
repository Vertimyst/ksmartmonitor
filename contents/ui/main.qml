import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "../code/smart.js" as Smart

PlasmoidItem {
    id: root
    
    property var driveData: []
    property bool hasError: false
    property string errorMessage: ""
    property var lastUpdateTime: new Date()
    property var driveNameMap: ({})
    property var enabledDrivesList: []
    
    // Update interval in seconds (from config, default 5 minutes)
    property int updateIntervalSeconds: plasmoid.configuration.updateInterval || 300
    
    Component.onCompleted: {
        updateDriveData()
        loadDriveConfig()
    }
    
    onVisibleChanged: {
        if (visible) {
            loadDriveConfig()
        }
    }
    
    // Watch for config changes
    Connections {
        target: plasmoid.configuration
        function onDriveNamesChanged() {
            loadDriveConfig()
        }
        function onEnabledDrivesChanged() {
            loadDriveConfig()
        }
    }
    
    function loadDriveConfig() {
        // Parse custom drive names
        try {
            if (plasmoid.configuration.driveNames) {
                driveNameMap = JSON.parse(plasmoid.configuration.driveNames)
            } else {
                driveNameMap = {}
            }
        } catch (e) {
            driveNameMap = {}
        }
        
        // Parse enabled drives list
        if (plasmoid.configuration.enabledDrives) {
            enabledDrivesList = plasmoid.configuration.enabledDrives.split(',')
        } else {
            enabledDrivesList = []
        }
    }
    
    // Automatically detect if in panel or on desktop
    // Show compact in panel, full on desktop
    preferredRepresentation: {
        // Check if widget is in a panel (top, bottom, left, or right edge)
        if (Plasmoid.location === PlasmaCore.Types.TopEdge ||
            Plasmoid.location === PlasmaCore.Types.BottomEdge ||
            Plasmoid.location === PlasmaCore.Types.LeftEdge ||
            Plasmoid.location === PlasmaCore.Types.RightEdge) {
            return compactRepresentation
        }
        // Otherwise show full representation (desktop, floating)
        return fullRepresentation
    }
    
    // Compact representation (shown in panel)
    compactRepresentation: Item {
        id: compactRoot
        
        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        Layout.preferredWidth: compactLayout.implicitWidth
        Layout.preferredHeight: compactLayout.implicitHeight
        
        RowLayout {
            id: compactLayout
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing
            
            Item {
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                Layout.minimumWidth: Kirigami.Units.iconSizes.small
                Layout.minimumHeight: Kirigami.Units.iconSizes.small
                
                Kirigami.Icon {
                    id: icon
                    anchors.fill: parent
                    
                    source: {
                        if (root.hasError) return "data-error"
                        
                        var hasWarning = false
                        var hasFailing = false
                        
                        for (var i = 0; i < root.driveData.length; i++) {
                            var drive = root.driveData[i]
                            if (drive.health === "FAILING") {
                                hasFailing = true
                                break
                            }
                            if (drive.temperature > 55 || drive.health === "WARNING") {
                                hasWarning = true
                            }
                        }
                        
                        if (hasFailing) return "data-error"
                        if (hasWarning) return "data-warning"
                        return "drive-harddisk"
                    }
                }
                
                // Colored overlay rectangle
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: {
                        if (root.hasError) return Kirigami.Theme.negativeTextColor
                        
                        var hasWarning = false
                        var hasFailing = false
                        
                        for (var i = 0; i < root.driveData.length; i++) {
                            var drive = root.driveData[i]
                            if (drive.health === "FAILING") {
                                hasFailing = true
                                break
                            }
                            if (drive.temperature > 55 || drive.health === "WARNING") {
                                hasWarning = true
                            }
                        }
                        
                        if (hasFailing) return Kirigami.Theme.negativeTextColor
                        if (hasWarning) return Kirigami.Theme.neutralTextColor
                        return Kirigami.Theme.positiveTextColor
                    }
                    opacity: 0.3
                }
            }
            
            Text {
                id: driveCount
                text: root.driveData.length
                color: Kirigami.Theme.textColor
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                visible: root.driveData.length > 0
            }
        }
        
        MouseArea {
            anchors.fill: parent
            z: 999
            onClicked: root.expanded = !root.expanded
        }
    }
    
    // Full representation (shown when expanded)
    fullRepresentation: Item {
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
                    clip: true
                    
                    delegate: DriveItem {}
                    
                    PlasmaExtras.PlaceholderMessage {
                        anchors.centerIn: parent
                        width: parent.width - (Kirigami.Units.largeSpacing * 4)
                        visible: root.driveData.length === 0 && !root.hasError
                        text: "No drives detected"
                        explanation: "Make sure smartmontools is installed and you have permission to access SMART data"
                        iconName: "drive-harddisk"
                    }
                    
                    PlasmaExtras.PlaceholderMessage {
                        anchors.centerIn: parent
                        width: parent.width - (Kirigami.Units.largeSpacing * 4)
                        visible: root.hasError
                        text: "Error reading SMART data"
                        explanation: root.errorMessage
                        iconName: "data-error"
                        
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
    
    // Timer for periodic updates
    Timer {
        id: updateTimer
        interval: root.updateIntervalSeconds * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updateDriveData()
        }
    }
    
    // DataSource for executing shell commands
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: function(source, data) {
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            var exitCode = data["exit code"]
            
            disconnectSource(source)
            
            if (exitCode === 0) {
                Smart.parseSmartData(stdout)
                root.lastUpdateTime = new Date()
            } else {
                root.hasError = true
                root.errorMessage = "Error reading SMART data: " + stderr
                console.log("SMART error:", stderr)
            }
        }
    }
    
    function updateDriveData() {
        // Command to get SMART data for all drives
        // Detects NVMe drives and uses appropriate flags
        var cmd = "smartctl --scan | awk '{print $1}' | while read drive; do " +
                  "echo \"DRIVE:$drive\"; " +
                  "if [[ \"$drive\" == *\"nvme\"* ]]; then " +
                  "  sudo smartctl -A -H \"$drive\" 2>/dev/null || echo \"ERROR\"; " +
                  "else " +
                  "  sudo smartctl -A -H \"$drive\" 2>/dev/null || echo \"ERROR\"; " +
                  "fi; " +
                  "done"
        
        executable.connectSource(cmd)
    }
}
