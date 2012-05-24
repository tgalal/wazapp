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
#include "waexistsrequest.h"
#include <QDebug>

WAExistsRequest::WAExistsRequest(QString cc, QString number)
{
    this->addParam("cc",cc);
    this->addParam("in",number);
    this->addParam("udid","abcd");

    connect(this,SIGNAL(trigger(QString)),this,SLOT(sendRequest(QString)));
    connect(this,SIGNAL(done(QString)),this,SLOT(onDone(QString)));

}

void WAExistsRequest::runTests()
{
    qDebug() << this->encodeUrl(params);
}

void WAExistsRequest::onDone(QString data)
{
    QDomDocument document;
    document.setContent(data);

    QDomElement response= document.elementsByTagName("response").at(0).toElement();

    QString status = response.attribute("status");
    QString result = response.attribute("result");

    if(status == "success")
        emit exists();
    else
        emit notExists();

    qDebug()<<status<<" ::::: "<<result;

}

void WAExistsRequest::run(){}

void WAExistsRequest::launched()
{
    emit trigger("https://r.whatsapp.net/v1/exist.php");
}
