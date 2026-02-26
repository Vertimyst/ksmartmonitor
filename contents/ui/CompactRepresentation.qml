import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
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
        onClicked: root.expanded = !root.expanded
    }
}
