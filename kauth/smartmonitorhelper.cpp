#include "smartmonitorhelper.h"
#include <KAuth/HelperSupport>
#include <QProcess>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

KAUTH_HELPER_MAIN("com.github.vertimyst.ksmartmonitor", SmartMonitorHelper)

SmartMonitorHelper::SmartMonitorHelper()
{
}

ActionReply SmartMonitorHelper::getsmart(const QVariantMap &args)
{
    Q_UNUSED(args);
    qDebug() << "SmartMonitorHelper::getsmart called";
    
    ActionReply reply;
    
    // First, get list of drives
    QProcess scanProcess;
    scanProcess.start(QStringLiteral("smartctl"), QStringList() << QStringLiteral("--scan"));
    scanProcess.waitForFinished();
    
    if (scanProcess.exitCode() != 0) {
        reply = ActionReply::HelperErrorReply();
        reply.setErrorDescription(QStringLiteral("Failed to scan for drives"));
        return reply;
    }
    
    QString scanOutput = QString::fromUtf8(scanProcess.readAllStandardOutput());
    QStringList lines = scanOutput.split(QStringLiteral("\n"), Qt::SkipEmptyParts);
    
    QJsonArray drivesArray;
    
    // For each drive, get SMART data
    for (const QString &line : lines) {
        QStringList parts = line.split(QStringLiteral(" "), Qt::SkipEmptyParts);
        if (parts.isEmpty()) continue;
        
        QString device = parts[0];
        qDebug() << "Checking device:" << device;
        
        QJsonObject driveData;
        driveData[QStringLiteral("device")] = device;
        
        // Run smartctl to get SMART data
        QProcess smartProcess;
        smartProcess.start(QStringLiteral("smartctl"), 
                          QStringList() << QStringLiteral("-A") << QStringLiteral("-H") << device);
        smartProcess.waitForFinished();
        
        if (smartProcess.exitCode() == 0) {
            QString output = QString::fromUtf8(smartProcess.readAllStandardOutput());
            driveData[QStringLiteral("output")] = output;
            driveData[QStringLiteral("success")] = true;
        } else {
            driveData[QStringLiteral("success")] = false;
            driveData[QStringLiteral("error")] = QString::fromUtf8(smartProcess.readAllStandardError());
        }
        
        drivesArray.append(driveData);
    }
    
    // Package the results
    QJsonObject result;
    result[QStringLiteral("drives")] = drivesArray;
    
    QJsonDocument doc(result);
    QByteArray jsonBytes = doc.toJson(QJsonDocument::Compact);
    
    reply.addData(QStringLiteral("result"), QString::fromUtf8(jsonBytes));
    return reply;
}