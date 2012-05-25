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
#include "smshandler.h"
#include <QTimer>
#include <QDebug>

SmsHandler::SmsHandler(QObject *parent)
    :QObject(parent)
{
    managerStarted = false;
    isActive = true;

}



void SmsHandler::run(){
     qDebug()<<"handler init";


     m_manager = new QMessageManager(this->parent());
    managerStarted = true;

    qDebug()<<"INITiALIZED!!!";
    this->initManager();
   // emit this->managerCreated();
}

void SmsHandler::initManager(){

       // Manager for listening messages


        qDebug()<<"handler init";

       // Listen new added messages
       connect(m_manager, SIGNAL(messageAdded(const QMessageId&,
                                 const QMessageManager::NotificationFilterIdSet&)),
               this, SLOT(messageAdded(const QMessageId&,
                          const QMessageManager::NotificationFilterIdSet&)));
        qDebug()<<"handler init";
       // Create 2 filers set for filtering messages
       // - SMS filter
       // - InboxFolder filter
       m_notifFilterSet.insert(m_manager->registerNotificationFilter(
           QMessageFilter::byType(QMessage::Sms) &
           QMessageFilter::byStandardFolder(QMessage::InboxFolder)));

       if(this->isActive)
            emit this->initialized();
       qDebug()<<"handler init";
}

void SmsHandler::stopListener(){
    qDebug()<<"Listener stopped";
    disconnect(m_manager, SIGNAL(messageAdded(const QMessageId&,
                              const QMessageManager::NotificationFilterIdSet&)),
            this, SLOT(messageAdded(const QMessageId&,
                       const QMessageManager::NotificationFilterIdSet&)));


    isActive = false;
    qDebug()<<"Manager killed";
}

void SmsHandler::messageAdded(const QMessageId& id,
    const QMessageManager::NotificationFilterIdSet& matchingFilterIds)
{
    qDebug()<<"MESSAGE ADDED, current state "+isActive;
    if(isActive)
    {
    qDebug()<<"MESSAGEADDED FUNCTION";
    // Message added...
    if (matchingFilterIds.contains(m_notifFilterSet)) {

        qDebug()<<"INSIDE FILTER";
        // ...and it fits into our filters, lets process it
        m_messageId = id;
        QTimer::singleShot(0, this, SLOT(processIncomingSMS()));


    }
}
}

void SmsHandler::processIncomingSMS()
{
    qDebug()<<"SENDING MESSAGE";

   // QString message = "WhatsApp code abc";

    //QStringList tmp = message.split(' ');

    //emit gotCode(tmp[2]);
    QMessage message = m_manager->message(m_messageId);
    // SMS message body
    QString messageString = message.textContent();

    qDebug()<<messageString;

    QStringList tmp = messageString.split(' ');
    if(tmp.length() == 3 && tmp[0].toLower()=="whatsapp" && tmp[1].toLower() == "code"){
    //m_manager->removeMessage(m_messageId);
     emit gotCode(tmp[2]);

    }else{
        qDebug()<<"ignored a wrong message message";
    }


     //Remove message from inbox

}
