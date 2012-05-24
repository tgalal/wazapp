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
#include "waregrequest.h"
#include <QDebug>
#include "utilities.h"
using namespace Utilities;

WARegRequest::WARegRequest(QString cc, QString number, QString method)
{

    this->addParam("cc",cc);
    this->addParam("in",number);
   // this->addParam("me",cc+number);
    this->addParam("udid",getChatPassword());
    this->addParam("method",method);

    connect(this,SIGNAL(trigger(QString)),this,SLOT(sendRequest(QString)));
    connect(this,SIGNAL(done(QString)),this,SLOT(onDone(QString)));
}

void WARegRequest::go(QString code)
{
    this->addParam("code",code);
    this->start();
}

void WARegRequest::onDone(QString data)
{
    QDomDocument document;
    document.setContent(data);

    QDomElement response= document.elementsByTagName("response").at(0).toElement();

    QString login = response.attribute("login");
    QString status = response.attribute("status");

    if(status == "ok")
        emit success(login);
    else
        emit fail("Unkown Reason");

   // qDebug() << data;
    qDebug()<<status<<" ::::: "<<login;

}
void WARegRequest::run(){}

void WARegRequest::launched()
{
    //emit success("201006960035");
    emit trigger("https://r.whatsapp.net/v1/register.php");
}
