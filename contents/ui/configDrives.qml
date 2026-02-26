import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasma5support as Plasma5Support

KCM.SimpleKCM {
    id: drivesConfigRoot
    
    property alias cfg_enabledDrives: enabledDrivesField.text
    property alias cfg_driveNames: driveNamesField.text
    property var allDrives: []
    property var driveNameMap: ({})
    
    // Hidden fields to store the actual config values
    QQC2.TextField {
        id: enabledDrivesField
        visible: false
    }
    
    QQC2.TextField {
        id: driveNamesField
        visible: false
    }
    
    Component.onCompleted: {
        // Parse existing drive names
        try {
            if (cfg_driveNames) {
                driveNameMap = JSON.parse(cfg_driveNames)
            }
        } catch (e) {
            driveNameMap = {}
        }
        
        // Load drives
        loadDrives()
    }
    
    // DataSource for executing shell commands
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: function(source, data) {
            var stdout = data["stdout"]
            disconnectSource(source)
            
            if (stdout) {
                var lines = stdout.trim().split('\n')
                allDrives = lines.filter(function(line) { return line.length > 0 })
                driveListModel.clear()
                
                // Parse enabled drives
                var enabledList = cfg_enabledDrives ? cfg_enabledDrives.split(',') : []
                
                for (var i = 0; i < allDrives.length; i++) {
                    var drive = allDrives[i]
                    driveListModel.append({
                        device: drive,
                        enabled: enabledList.length === 0 || enabledList.indexOf(drive) >= 0,
                        customName: driveNameMap[drive] || ""
                    })
                }
            }
        }
    }
    
    function loadDrives() {
        var cmd = "smartctl --scan | awk '{print $1}'"
        executable.connectSource(cmd)
    }
    
    function saveConfig() {
        var enabledDrives = []
        var nameMap = {}
        
        for (var i = 0; i < driveListModel.count; i++) {
            var item = driveListModel.get(i)
            if (item.enabled) {
                enabledDrives.push(item.device)
            }
            if (item.customName) {
                nameMap[item.device] = item.customName
            }
        }
        
        cfg_enabledDrives = enabledDrives.join(',')
        cfg_driveNames = JSON.stringify(nameMap)
    }
    
    ListModel {
        id: driveListModel
    }
    
    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "Select which drives to monitor and optionally give them custom display names"
            visible: true
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            Kirigami.Heading {
                level: 3
                text: "Detected Drives"
                Layout.fillWidth: true
            }
            
            QQC2.Button {
                icon.name: "view-refresh"
                text: "Refresh"
                onClicked: loadDrives()
            }
        }
        
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 15
            
            ListView {
                id: driveListView
                model: driveListModel
                spacing: Kirigami.Units.smallSpacing
                
                delegate: Kirigami.AbstractCard {
                    width: ListView.view.width
                    
                    contentItem: RowLayout {
                        spacing: Kirigami.Units.largeSpacing
                        
                        QQC2.CheckBox {
                            checked: model.enabled
                            onToggled: {
                                driveListModel.setProperty(index, "enabled", checked)
                                saveConfig()
                            }
                        }
                        
                        Kirigami.Icon {
                            source: model.device.includes("nvme") ? "drive-harddisk-solidstate" : "drive-harddisk"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            QQC2.Label {
                                text: model.device
                                font.bold: true
                            }
                            
                            RowLayout {
                                spacing: Kirigami.Units.smallSpacing
                                
                                QQC2.Label {
                                    text: "Display name:"
                                    opacity: 0.7
                                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                }
                                
                                QQC2.TextField {
                                    Layout.fillWidth: true
                                    placeholderText: "Optional custom name..."
                                    text: model.customName
                                    onTextChanged: {
                                        driveListModel.setProperty(index, "customName", text)
                                        saveConfig()
                                    }
                                }
                            }
                        }
                    }
                }
                
                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.largeSpacing * 4)
                    visible: driveListModel.count === 0
                    text: "No drives detected"
                    explanation: "Click Refresh or check that smartmontools is installed"
                    icon.name: "drive-harddisk"
                }
            }
        }
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            text: "Tip: Unchecked drives will be hidden from the widget. Custom names only change the display label."
            visible: true
        }
    }
}
