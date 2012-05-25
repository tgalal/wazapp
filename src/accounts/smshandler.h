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
