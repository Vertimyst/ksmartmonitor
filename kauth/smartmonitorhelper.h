#ifndef SMARTMONITORHELPER_H
#define SMARTMONITORHELPER_H

#include <KAuth/ActionReply>
#include <QObject>

using namespace KAuth;

class SmartMonitorHelper : public QObject
{
    Q_OBJECT

    public:
        SmartMonitorHelper();

    public Q_SLOTS:
        ActionReply getsmart(const QVariantMap &args);
};

#endif