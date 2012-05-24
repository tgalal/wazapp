#ifndef WAACCOUNT_H
#define WAACCOUNT_H

#include <QDebug>

#include <AccountSetup/ProviderPluginProcess>
#include <accounts-qt/Accounts/Account>
#include <accounts-qt/Accounts/Manager>

class WaAccount:public QObject
{
    Q_OBJECT

public:
    explicit WaAccount();



    void showData();

     void init(int initType);

    Q_INVOKABLE void createAccount(QVariant phoneNumber,
                                   QVariant cc);

    Q_INVOKABLE void saveAccount(QString phoneNumber,
                                 QString cc,
                                 QString password,
                                 QString accountId,
                                 QString imsi);

     Q_INVOKABLE void deleteAccount();

    Accounts::Account *accountx;
    Accounts::Service *service;
    Accounts::Service *mainservice;
    Accounts::Manager *manager;
    
signals:
    
public slots:

     void onAccountxCreated(Accounts::AccountId id);
    
};

#endif // WAACCOUNT_H
