#ifndef SMSHANDLER_H
#define SMSHANDLER_H

#include <QMessage>
#include <QMessageManager>
#include <QObject>
#include <QPointer>
#include <QThread>

QTM_USE_NAMESPACE

class SmsHandler :  public QObject
{
    Q_OBJECT
public:
    explicit SmsHandler(QObject *parent =0);


    bool isActive;
    bool managerStarted;

signals:
    void gotCode(QString);
    void initialized();
    void managerCreated();

private slots:
    void processIncomingSMS();
    // Listening signals from QMessageManager
    void messageAdded(const QMessageId&,
    const QMessageManager::NotificationFilterIdSet&);


private:
    QPointer<QMessageManager> m_manager;
    QMessageManager::NotificationFilterIdSet m_notifFilterSet;
    QMessageId m_messageId;



public slots:
    void stopListener();
    void initManager();
    void run();
};

#endif // SMSHANDLER_H
