import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configRoot
    
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_temperatureWarningThreshold: tempWarningSpinBox.value
    property alias cfg_temperatureCriticalThreshold: tempCriticalSpinBox.value
    property alias cfg_showDetailedAttributes: showAttributesCheckBox.checked
    
    Kirigami.FormLayout {
        
        RowLayout {
            Kirigami.FormData.label: "Update interval:"
            
            QQC2.SpinBox {
                id: updateIntervalSpinBox
                from: 30
                to: 3600
                stepSize: 30
                editable: true
                
                textFromValue: function(value) {
                    if (value < 60) {
                        return value + " seconds"
                    } else if (value === 60) {
                        return "1 minute"
                    } else {
                        return Math.round(value / 60) + " minutes"
                    }
                }
                
                valueFromText: function(text) {
                    var match = text.match(/(\d+)/)
                    if (match) {
                        var num = parseInt(match[1])
                        if (text.includes("minute")) {
                            return num * 60
                        }
                        return num
                    }
                    return 300
                }
            }
        }
        
        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }
        
        RowLayout {
            Kirigami.FormData.label: "Temperature warning:"
            
            QQC2.SpinBox {
                id: tempWarningSpinBox
                from: 40
                to: 80
                stepSize: 5
                editable: true
                
                textFromValue: function(value) {
                    return value + "°C"
                }
                
                valueFromText: function(text) {
                    return parseInt(text)
                }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: "Temperature critical:"
            
            QQC2.SpinBox {
                id: tempCriticalSpinBox
                from: 45
                to: 85
                stepSize: 5
                editable: true
                
                textFromValue: function(value) {
                    return value + "°C"
                }
                
                valueFromText: function(text) {
                    return parseInt(text)
                }
            }
        }
        
        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }
        
        QQC2.CheckBox {
            id: showAttributesCheckBox
            text: "Show detailed SMART attributes"
            Kirigami.FormData.label: "Display:"
        }
    }
}
