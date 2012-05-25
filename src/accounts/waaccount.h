/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
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
