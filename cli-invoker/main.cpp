#include <QCoreApplication>
#include <QTextStream>
#include <KAuth/Action>
#include <KAuth/ExecuteJob>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    KAuth::Action action(QStringLiteral("com.github.vertimyst.ksmartmonitor.getsmart"));
    action.setHelperId(QStringLiteral("com.github.vertimyst.ksmartmonitor"));
    
    KAuth::ExecuteJob *job = action.execute();
    
    if (!job->exec()) {
        QTextStream(stderr) << "Error: " << job->errorString() << "\n";
        return 1;
    }
    
    QString result = job->data().value(QStringLiteral("result")).toString();
    QTextStream(stdout) << result;
    
    return 0;
}