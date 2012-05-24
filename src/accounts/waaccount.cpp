/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 3 of the License, or
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
#include "waaccount.h"

WaAccount::WaAccount():
    QObject()
{

}

void WaAccount::init(int initType)
{
    manager = new Accounts::Manager(QString("IM"));
    service = manager->service(QString("waxmpp"));


    switch(initType)
    {
        case 1:
            createAccount("12345678","20");
        break;


    }

}


void WaAccount::deleteAccount()
{
    if(accountx != NULL)
    {
        accountx->remove();
        accountx->sync();
    }
}

void WaAccount::createAccount(QVariant phoneNumber, QVariant cc)
{
    qDebug()<<"SHOULD CREATE"<<endl;

    connect(manager,
            SIGNAL(accountCreated(Accounts::AccountId)),
            SLOT(onAccountxCreated(Accounts::AccountId)));

    accountx = manager->createAccount(QString("waxmpp"));
    accountx->sync();
}

void WaAccount::saveAccount(QString phoneNumber, QString cc, QString password, QString accountId,QString imsi)
{
     qDebug()<<"SHOULD CREATE"<<endl;
}


void WaAccount::showData()
{
    mainservice = accountx->selectedService();
    accountx->selectService(service);
    QString uid = accountx->valueAsString("tmc-uid");
}

void WaAccount::onAccountxCreated(Accounts::AccountId id)
{
    qDebug()<<"ACCOUNT CREATED"<<endl;

    accountx->setValue("name", "whatsapp");
    accountx->setValue("username", "201001116688@s.whatsapp.net");
    accountx->setValue("password", "PASSWD");
    accountx->setEnabled(true);
    accountx->selectService(service);
    accountx->setEnabled(true);
    accountx->setValue("imsi", "IMSIVALUE");
    accountx->sync();
}
